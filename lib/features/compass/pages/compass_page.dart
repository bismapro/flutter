import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'dart:async';

// Mock AppTheme for testing
class AppTheme {
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color primaryBlueDark = Color(0xFF1565C0);
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
        
        // Normalize heading to 0-360 range
        heading = heading < 0 ? heading + 360 : heading;
        heading = heading >= 360 ? heading - 360 : heading;

        // Apply smoothing to reduce jitter
        double difference = (heading - _compassHeading).abs();
        if (difference > 180) difference = 360 - difference;

        if (difference > 1.0 || _compassHeading == 0.0) {
          setState(() {
            _compassHeading = heading;
            _isCompassCalibrated = event.accuracy != null && event.accuracy! > 0.3;
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
        _status = 'Layanan lokasi tidak aktif.\nSilakan aktifkan GPS di pengaturan perangkat.';
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
          _status = 'Izin lokasi ditolak.\nAplikasi memerlukan akses lokasi untuk menentukan arah Kiblat.';
          _isLoading = false;
          _hasPermission = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _status = 'Izin lokasi ditolak secara permanen.\nSilakan aktifkan di Pengaturan > Privasi > Layanan Lokasi.';
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
    _locationSubscription = Geolocator.getPositionStream(
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
        debugPrint('Location update error: $error');
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
    double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

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

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);

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
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Arah Qiblat',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _initializeCompass,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Lokasi',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.accentGreen),
            const SizedBox(height: 24),
            Text(
              _status,
              style: const TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant),
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off,
                  size: 60,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Error:',
                style: TextStyle(
                  fontSize: 20,
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _status,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _initializeCompass,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildLocationInfo(),
          const SizedBox(height: 30),
          _buildCompass(),
          const SizedBox(height: 20),
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: AppTheme.accentGreen, size: 16),
              const SizedBox(width: 4),
              const Text(
                'Lokasi Real-time',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _cityName.isNotEmpty ? _cityName : 'Mencari lokasi...',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'INDONESIA',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
              letterSpacing: 2.0,
            ),
            textAlign: TextAlign.center,
          ),
          if (_currentPosition != null) ...[
            const SizedBox(height: 8),
            Text(
              'GPS: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 10, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompass() {
    // Calculate the angle for Qibla needle
    double qiblaAngle = (_qiblaDirection - _compassHeading) * math.pi / 180;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer green ring
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentGreen, width: 10),
                ),
              ),

              // Blue middle ring
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue,
                ),
              ),

              // Main white compass circle with rotating compass face
              Transform.rotate(
                angle: -_compassHeading * math.pi / 180, // Rotate compass face
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surfaceWhite,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    size: const Size(260, 260),
                    painter: CompassFacePainter(),
                  ),
                ),
              ),

              // Cardinal directions (rotate with compass)
              Transform.rotate(
                angle: -_compassHeading * math.pi / 180,
                child: _buildCardinalDirections(),
              ),

              // Qibla arrow (points to Qibla, stays fixed relative to north)
              Transform.rotate(
                angle: qiblaAngle,
                child: CustomPaint(
                  size: const Size(260, 260),
                  painter: QiblaNeedlePainter(),
                ),
              ),

              // Kaaba icon
              Transform.rotate(
                angle: qiblaAngle,
                child: Transform.translate(
                  offset: const Offset(0, -80),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.onSurface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('🕋', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),

              // Center dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),

              // Calibration status indicator
              if (!_isCompassCalibrated)
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Kalibrasi kompas',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardinalDirections() {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // North (top)
          Positioned(
            top: 10,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Text(
                'N',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          // South
          Positioned(
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Text(
                'S',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          // East
          Positioned(
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Text(
                'E',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          // West
          Positioned(
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Text(
                'W',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Qiblat ${_qiblaDirection.toStringAsFixed(1)}° dari Utara',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jarak ke Ka\'bah ± ${_distanceToKaaba.toStringAsFixed(0)} KM',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isCompassCalibrated ? Icons.check_circle : Icons.warning,
                size: 16,
                color: _isCompassCalibrated ? AppTheme.accentGreen : Colors.orange,
              ),
              const SizedBox(width: 6),
              Text(
                _isCompassCalibrated ? 'Kompas terkalibrasi' : 'Goyang perangkat untuk kalibrasi',
                style: TextStyle(
                  fontSize: 12,
                  color: _isCompassCalibrated ? AppTheme.accentGreen : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Jauhkan perangkat dari objek yang berbahan besi atau logam, agar lebih akurat.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for compass face
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
        ..color = i % 30 == 0 ? Colors.grey.shade700 : Colors.grey.shade400
        ..strokeWidth = i % 30 == 0 ? 2 : 1;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for qibla needle
class QiblaNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final needlePaint = Paint()
      ..color = AppTheme.accentGreen
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - 90); // Top point
    path.lineTo(center.dx - 8, center.dy - 60); // Left point
    path.lineTo(center.dx - 3, center.dy - 60); // Left inner
    path.lineTo(center.dx - 3, center.dy + 60); // Left bottom
    path.lineTo(center.dx + 3, center.dy + 60); // Right bottom
    path.lineTo(center.dx + 3, center.dy - 60); // Right inner
    path.lineTo(center.dx + 8, center.dy - 60); // Right point
    path.close();

    canvas.drawPath(path, needlePaint);

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}