import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'dart:async';

import 'package:test_flutter/core/utils/logger.dart';

// Import theme from your app
class AppTheme {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color backgroundWhite = Color(0xFFFAFAFA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);
  static const Color errorColor = Color(0xFFD32F2F);
}

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  bool _hasPermission = false;
  Position? _currentPosition;
  double _qiblaDirection = 0;
  bool _isLoading = true;
  String _status = 'Memuat...';
  double _distanceToKaaba = 0;
  String _cityName = '';
  bool _isCompassCalibrated = false;
  double _compassHeading = 0.0;
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _locationSubscription;

  // Kaaba coordinates (Mecca, Saudi Arabia)
  static const double _kaabaLatitude = 21.4224779;
  static const double _kaabaLongitude = 39.8251832;

  @override
  void initState() {
    super.initState();
    _checkCompassAvailability();
    _initializeCompass();
    _initializeCompassSensor();
  }

  void _checkCompassAvailability() async {
    if (FlutterCompass.events == null) {
      setState(() {
        _status = 'Sensor kompas tidak tersedia pada perangkat ini';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _initializeCompassSensor() {
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted && event.heading != null) {
        double heading = event.heading!;

        heading = heading < 0 ? heading + 360 : heading;
        heading = heading >= 360 ? heading - 360 : heading;

        double difference = (heading - _compassHeading).abs();
        if (difference > 180) difference = 360 - difference;

        if (difference > 1.0 || _compassHeading == 0.0) {
          setState(() {
            _compassHeading = heading;
            _isCompassCalibrated =
                event.accuracy != null && event.accuracy! > 0.3;
          });
        }
      }
    });
  }

  Future<void> _initializeCompass() async {
    setState(() {
      _isLoading = true;
      _hasPermission = false;
      _currentPosition = null;
      _qiblaDirection = 0.0;
      _status = 'Memulai kompas Kiblat...';
    });

    _locationSubscription?.cancel();
    _compassSubscription?.cancel();

    try {
      await _checkLocationPermissions();
      if (_hasPermission) {
        await _getCurrentLocation();
      }
      _initializeCompassSensor();
    } catch (e) {
      setState(() {
        _status = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
        _hasPermission = false;
      });
    }
  }

  Future<void> _checkLocationPermissions() async {
    setState(() {
      _status = 'Memeriksa layanan lokasi...';
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _status =
            'Layanan lokasi tidak aktif.\nSilakan aktifkan GPS di pengaturan perangkat.';
        _isLoading = false;
        _hasPermission = false;
      });
      return;
    }

    setState(() {
      _status = 'Memeriksa izin lokasi...';
    });

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      setState(() {
        _status = 'Meminta izin lokasi...';
      });

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _status =
              'Izin lokasi ditolak.\nAplikasi memerlukan akses lokasi untuk menentukan arah Kiblat.';
          _isLoading = false;
          _hasPermission = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _status =
            'Izin lokasi ditolak secara permanen.\nSilakan aktifkan di Pengaturan > Privasi > Layanan Lokasi.';
        _isLoading = false;
        _hasPermission = false;
      });
      return;
    }

    setState(() {
      _hasPermission = true;
      _status = 'Mendapatkan lokasi Anda...';
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1,
          timeLimit: Duration(seconds: 30),
        ),
      );

      setState(() {
        _currentPosition = position;
        _status = 'Menghitung arah Kiblat...';
      });

      _calculateQiblaDirection();
      _startLocationUpdates();
    } catch (e) {
      setState(() {
        _status = 'Gagal mendapatkan lokasi: ${e.toString()}';
        _isLoading = false;
        _hasPermission = false;
      });
    }
  }

  void _startLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
            timeLimit: Duration(seconds: 10),
          ),
        ).listen(
          (Position position) {
            if (mounted) {
              setState(() {
                _currentPosition = position;
              });
              _calculateQiblaDirection();
            }
          },
          onError: (error) {
            logger.fine('Location update error: $error');
          },
        );
  }

  void _calculateQiblaDirection() {
    if (_currentPosition == null) return;

    double lat1 = _degreeToRadian(_currentPosition!.latitude);
    double lon1 = _degreeToRadian(_currentPosition!.longitude);
    double lat2 = _degreeToRadian(_kaabaLatitude);
    double lon2 = _degreeToRadian(_kaabaLongitude);

    double dLon = lon2 - lon1;

    double y = math.sin(dLon) * math.cos(lat2);
    double x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x);
    double qiblaBearing = _radianToDegree(bearing);
    qiblaBearing = (qiblaBearing + 360) % 360;

    double distance = _calculateDistanceToKaaba();
    String city = _getCityFromCoordinates();

    setState(() {
      _qiblaDirection = qiblaBearing;
      _distanceToKaaba = distance;
      _cityName = city;
      _isLoading = false;
      _status = 'Arah Kiblat telah ditemukan';
    });
  }

  double _calculateDistanceToKaaba() {
    if (_currentPosition == null) return 0;

    const double earthRadius = 6371;

    double lat1 = _degreeToRadian(_currentPosition!.latitude);
    double lon1 = _degreeToRadian(_currentPosition!.longitude);
    double lat2 = _degreeToRadian(_kaabaLatitude);
    double lon2 = _degreeToRadian(_kaabaLongitude);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  String _getCityFromCoordinates() {
    if (_currentPosition == null) return 'Lokasi Tidak Diketahui';

    double lat = _currentPosition!.latitude;
    double lng = _currentPosition!.longitude;

    if (lat >= -6.35 && lat <= -5.95 && lng >= 106.5 && lng <= 107.2) {
      return 'Jakarta';
    } else if (lat >= -7.05 && lat <= -6.75 && lng >= 110.25 && lng <= 110.55) {
      return 'Semarang';
    } else if (lat >= -7.95 && lat <= -7.65 && lng >= 110.25 && lng <= 110.55) {
      return 'Yogyakarta';
    } else if (lat >= -7.45 && lat <= -7.15 && lng >= 112.5 && lng <= 112.9) {
      return 'Surabaya';
    } else if (lat >= -6.95 && lat <= -6.85 && lng >= 107.5 && lng <= 107.7) {
      return 'Bandung';
    } else if (lat >= -8.75 && lat <= -8.55 && lng >= 115.1 && lng <= 115.3) {
      return 'Denpasar';
    } else if (lat >= -11 && lat <= 6 && lng >= 95 && lng <= 141) {
      return 'Indonesia';
    } else {
      return 'Lokasi di luar Indonesia';
    }
  }

  double _degreeToRadian(double degree) => degree * (math.pi / 180);
  double _radianToDegree(double radian) => radian * (180 / math.pi);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.03),
              AppTheme.backgroundWhite,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryBlue.withValues(alpha: 0.1),
                            AppTheme.accentGreen.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.explore_rounded,
                        color: AppTheme.primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Arah Kiblat',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Temukan arah kiblat',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentGreen.withValues(alpha: 0.1),
                            AppTheme.primaryBlue.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: _initializeCompass,
                        icon: const Icon(Icons.refresh_rounded),
                        color: AppTheme.accentGreen,
                        tooltip: 'Refresh Lokasi',
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                    AppTheme.accentGreen.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryBlue,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _status,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (!_hasPermission || _currentPosition == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade50, Colors.red.shade100],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off_rounded,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Izin Lokasi Diperlukan',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _status,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _initializeCompass,
                icon: const Icon(Icons.refresh_rounded, size: 22),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildLocationInfo(),
          const SizedBox(height: 30),
          _buildCompass(),
          const SizedBox(height: 24),
          _buildQiblaInfo(),
          const SizedBox(height: 20),
          _buildDisclaimer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.1),
            AppTheme.accentGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppTheme.accentGreen,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Lokasi Real-time',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _cityName.isNotEmpty ? _cityName : 'Mencari lokasi...',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'INDONESIA',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceVariant,
              letterSpacing: 2.0,
            ),
            textAlign: TextAlign.center,
          ),
          if (_currentPosition != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'GPS: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompass() {
    double qiblaAngle = (_qiblaDirection - _compassHeading) * math.pi / 180;

    return Center(
      child: SizedBox(
        width: 320,
        height: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer border with gradient
            Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.accentGreen, AppTheme.primaryBlue],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),

            // Inner blue ring
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue,
              ),
            ),

            // White compass face (rotates with heading)
            Transform.rotate(
              angle: -_compassHeading * math.pi / 180,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: CustomPaint(
                  size: const Size(280, 280),
                  painter: CompassFacePainter(),
                ),
              ),
            ),

            // Cardinal directions (rotate with compass)
            Transform.rotate(
              angle: -_compassHeading * math.pi / 180,
              child: _buildCardinalDirections(),
            ),

            // Qibla needle (points to Kaaba)
            Transform.rotate(
              angle: qiblaAngle,
              child: CustomPaint(
                size: const Size(280, 280),
                painter: QiblaNeedlePainter(),
              ),
            ),

            // Kaaba emoji indicator
            Transform.rotate(
              angle: qiblaAngle,
              child: Transform.translate(
                offset: const Offset(0, -100),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.onSurface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('🕋', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),

            // Center dot
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),

            // Calibration warning
            if (!_isCompassCalibrated)
              Positioned(
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade400,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sync_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      const Text(
                        'Kalibrasi kompas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardinalDirections() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // North
          Positioned(
            top: 15,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlue.withValues(alpha: 0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Text(
                'N',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          // South
          Positioned(
            bottom: 15,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Text(
                'S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          // East
          Positioned(
            right: 15,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Text(
                'E',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          // West
          Positioned(
            left: 15,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Text(
                'W',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentGreen.withValues(alpha: 0.15),
                      AppTheme.accentGreen.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.explore_rounded,
                  color: AppTheme.accentGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_qiblaDirection.toStringAsFixed(1)}°',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'dari Utara',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.0),
                  AppTheme.primaryBlue.withValues(alpha: 0.2),
                  AppTheme.primaryBlue.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mosque_rounded,
                size: 18,
                color: AppTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Jarak ke Ka\'bah ± ${_distanceToKaaba.toStringAsFixed(0)} KM',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isCompassCalibrated
                  ? AppTheme.accentGreen.withValues(alpha: 0.1)
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isCompassCalibrated
                    ? AppTheme.accentGreen.withValues(alpha: 0.3)
                    : Colors.orange.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isCompassCalibrated
                      ? Icons.check_circle_rounded
                      : Icons.warning_rounded,
                  size: 16,
                  color: _isCompassCalibrated
                      ? AppTheme.accentGreen
                      : Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  _isCompassCalibrated
                      ? 'Kompas terkalibrasi'
                      : 'Goyang perangkat untuk kalibrasi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isCompassCalibrated
                        ? AppTheme.accentGreen
                        : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.05),
            AppTheme.accentGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Jauhkan perangkat dari objek berbahan besi atau logam agar lebih akurat.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompassFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 360; i += 10) {
      final angle = (i - 90) * math.pi / 180;
      final startRadius = i % 30 == 0 ? radius - 25 : radius - 15;
      final endRadius = radius - 8;

      final startX = center.dx + startRadius * math.cos(angle);
      final startY = center.dy + startRadius * math.sin(angle);
      final endX = center.dx + endRadius * math.cos(angle);
      final endY = center.dy + endRadius * math.sin(angle);

      final linePaint = Paint()
        ..color = i % 30 == 0
            ? AppTheme.onSurface.withValues(alpha: 0.6)
            : AppTheme.onSurfaceVariant.withValues(alpha: 0.3)
        ..strokeWidth = i % 30 == 0 ? 2.5 : 1.5;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class QiblaNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Gradient for needle
    final needlePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.accentGreen,
          AppTheme.accentGreen.withValues(alpha: 0.8),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: 100))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - 100);
    path.lineTo(center.dx - 10, center.dy - 65);
    path.lineTo(center.dx - 4, center.dy - 65);
    path.lineTo(center.dx - 4, center.dy + 65);
    path.lineTo(center.dx + 4, center.dy + 65);
    path.lineTo(center.dx + 4, center.dy - 65);
    path.lineTo(center.dx + 10, center.dy - 65);
    path.close();

    canvas.drawPath(path, needlePaint);

    // White outline
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(path, outlinePaint);

    // Needle tip highlight
    final tipPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final tipPath = Path();
    tipPath.moveTo(center.dx, center.dy - 100);
    tipPath.lineTo(center.dx - 10, center.dy - 65);
    tipPath.lineTo(center.dx + 10, center.dy - 65);
    tipPath.close();

    canvas.drawPath(tipPath, tipPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
