import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../core/theme/app_theme.dart';

class QiblaCompassPage extends StatefulWidget {
  const QiblaCompassPage({super.key});

  @override
  State<QiblaCompassPage> createState() => _QiblaCompassPageState();
}

class _QiblaCompassPageState extends State<QiblaCompassPage> {
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

  // Kaaba coordinates (Mecca, Saudi Arabia)
  static const double _kaabaLatitude = 21.422487;
  static const double _kaabaLongitude = 39.826206;

  @override
  void initState() {
    super.initState();
    _initializeCompass();
    _initializeCompassSensor();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  void _initializeCompassSensor() {
    // Listen to compass events
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      setState(() {
        _compassHeading = event.heading ?? 0.0;
        _isCompassCalibrated = event.accuracy != null;
      });
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

    try {
      await _checkLocationPermissions();
      if (_hasPermission) {
        await _getCurrentLocation();
      }
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
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        _currentPosition = position;
        _status = 'Menghitung arah Kiblat...';
      });

      _calculateQiblaDirection();
    } catch (e) {
      setState(() {
        _status = 'Gagal mendapatkan lokasi: ${e.toString()}';
        _isLoading = false;
        _hasPermission = false;
      });
    }
  }

  void _calculateQiblaDirection() {
    if (_currentPosition == null) return;

    double lat1 = _degreeToRadian(_currentPosition!.latitude);
    double lon1 = _degreeToRadian(_currentPosition!.longitude);
    double lat2 = _degreeToRadian(_kaabaLatitude);
    double lon2 = _degreeToRadian(_kaabaLongitude);

    double dLon = lon2 - lon1;

    // Calculate bearing (direction)
    double y = math.sin(dLon) * math.cos(lat2);
    double x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x);
    double qiblaBearing = _radianToDegree(bearing);

    // Normalize to 0-360 degrees
    qiblaBearing = (qiblaBearing + 360) % 360;

    // Calculate distance using Haversine formula
    double distance = _calculateDistanceToKaaba();

    // Get approximate city name
    String city = _getCityFromCoordinates();

    setState(() {
      _qiblaDirection = qiblaBearing;
      _distanceToKaaba = distance;
      _cityName = city;
      _isLoading = false;
      _status = 'Arah Kiblat telah ditemukan';
      _isCompassCalibrated =
          true; // Mark as calibrated when we get good GPS data
    });
  }

  double _calculateDistanceToKaaba() {
    if (_currentPosition == null) return 0;

    const double earthRadius = 6371; // Earth radius in kilometers

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
    double distance = earthRadius * c;

    return distance;
  }

  String _getCityFromCoordinates() {
    if (_currentPosition == null) return 'Lokasi Tidak Diketahui';

    // Simplified city detection based on coordinates (for demo)
    // In real app, you would use reverse geocoding API
    double lat = _currentPosition!.latitude;
    double lng = _currentPosition!.longitude;

    if (lat >= -6.3 && lat <= -6.0 && lng >= 106.6 && lng <= 107.1) {
      return 'Jakarta, Indonesia';
    } else if (lat >= -7.0 && lat <= -6.8 && lng >= 110.3 && lng <= 110.5) {
      return 'Semarang, Indonesia';
    } else if (lat >= -7.9 && lat <= -7.7 && lng >= 110.3 && lng <= 110.5) {
      return 'Yogyakarta, Indonesia';
    } else if (lat >= -7.4 && lat <= -7.2 && lng >= 112.6 && lng <= 112.8) {
      return 'Surabaya, Indonesia';
    } else if (lat >= -0.1 && lat <= 0.1 && lng >= 109.2 && lng <= 109.4) {
      return 'Pontianak, Indonesia';
    } else if (lat >= 3.5 && lat <= 3.7 && lng >= 98.6 && lng <= 98.8) {
      return 'Medan, Indonesia';
    } else if (lat >= -5.2 && lat <= -5.0 && lng >= 119.4 && lng <= 119.6) {
      return 'Makassar, Indonesia';
    } else {
      return 'Indonesia';
    }
  }

  double _degreeToRadian(double degree) {
    return degree * (math.pi / 180);
  }

  double _radianToDegree(double radian) {
    return radian * (180 / math.pi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Kompas Kiblat',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryGreen,
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
            const CircularProgressIndicator(color: AppTheme.primaryGreen),
            const SizedBox(height: 24),
            Text(
              _status,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isLoading ? Icons.hourglass_empty : Icons.location_off,
                  size: 60,
                  color: _isLoading
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isLoading ? 'Sedang memuat...' : 'Error:',
                style: TextStyle(
                  fontSize: 20,
                  color: _isLoading
                      ? AppTheme.primaryGreen
                      : Colors.red.shade600,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _status,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!_isLoading)
                ElevatedButton.icon(
                  onPressed: _initializeCompass,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (_isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
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
          _buildLocationInfo(),
          _buildCompass(),
          _buildQiblaInfo(),
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '📍 Lokasi Anda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (_currentPosition != null) ...[
            Text(
              _cityName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latitude',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${_currentPosition!.latitude.toStringAsFixed(6)}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Longitude',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${_currentPosition!.longitude.toStringAsFixed(6)}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Arah Kiblat',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '${_qiblaDirection.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 30, color: Colors.white30),
                  Column(
                    children: [
                      const Text(
                        'Jarak ke Makkah',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '${_distanceToKaaba.toStringAsFixed(0)} km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer compass ring with degrees (rotates with device)
            Transform.rotate(
              angle: -_compassHeading * math.pi / 180,
              child: Container(
                width: 300,
                height: 300,
                child: CustomPaint(painter: CompassRingPainter()),
              ),
            ),

            // Main compass circle
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                    Colors.grey.shade100,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),

            // Cardinal directions (N, S, E, W) - rotates with device
            Transform.rotate(
              angle: -_compassHeading * math.pi / 180,
              child: _buildCardinalDirections(),
            ),

            // Qibla direction arrow (adjusting for device orientation)
            Transform.rotate(
              angle: (_qiblaDirection - _compassHeading) * math.pi / 180,
              child: Container(
                width: 200,
                height: 200,
                child: CustomPaint(painter: QiblaArrowPainter()),
              ),
            ),

            // Center dot
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // Kaaba icon (adjusting for device orientation)
            Transform.rotate(
              angle: (_qiblaDirection - _compassHeading) * math.pi / 180,
              child: Transform.translate(
                offset: const Offset(0, -70),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text('🕋', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),

            // Degree indicators
            Positioned(
              top: 15,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Kiblat: ${_qiblaDirection.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Heading: ${_compassHeading.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardinalDirections() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // North
        Positioned(
          top: 20,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 4),
              ],
            ),
            child: const Text(
              'N',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        // South
        Positioned(
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        // East
        Positioned(
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'E',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        // West
        Positioned(
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'W',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQiblaInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            '🕋 Informasi Kiblat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Koordinat Ka\'bah',
                  'Lat: ${_kaabaLatitude.toStringAsFixed(4)}°\nLng: ${_kaabaLongitude.toStringAsFixed(4)}°',
                  Icons.place,
                  Colors.black87,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Waktu di Makkah',
                  _getMakkaTime(),
                  Icons.access_time,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  '🧭 Status Kompas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getCompassStatus(),
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getMakkaTime() {
    // Simple time calculation (Makkah is UTC+3)
    DateTime now = DateTime.now().toUtc().add(const Duration(hours: 3));
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getCompassStatus() {
    if (_isCompassCalibrated && _qiblaDirection > 0) {
      return 'Kompas terkalibrasi dengan baik\nHeading: ${_compassHeading.toStringAsFixed(0)}°\nArahkan ponsel mengikuti panah hijau';
    } else if (_qiblaDirection > 0) {
      return 'Kompas bekerja\nHeading: ${_compassHeading.toStringAsFixed(0)}°\nArahkan ponsel mengikuti panah hijau';
    } else {
      return 'Menunggu kalibrasi kompas...\nPastikan GPS dan sensor kompas aktif';
    }
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Petunjuk Penggunaan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '1. Pastikan GPS/lokasi aktif pada perangkat Anda\n'
            '2. Arahkan bagian atas ponsel ke arah panah hijau\n'
            '3. Ikon 🕋 menunjukkan arah tepat menuju Kiblat\n'
            '4. Untuk akurasi terbaik, gunakan di tempat terbuka',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: AppTheme.primaryGreen, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kompas ini menghitung arah Kiblat berdasarkan lokasi Anda saat ini',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for compass ring with degrees
class CompassRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw outer circle
    canvas.drawCircle(center, radius, paint);

    // Draw degree marks
    for (int i = 0; i < 360; i += 30) {
      final angle = (i - 90) * math.pi / 180; // -90 to start from top
      final startRadius = radius - 8;
      final endRadius = radius;

      final startX = center.dx + startRadius * math.cos(angle);
      final startY = center.dy + startRadius * math.sin(angle);
      final endX = center.dx + endRadius * math.cos(angle);
      final endY = center.dy + endRadius * math.sin(angle);

      final markPaint = Paint()
        ..color = i % 90 == 0 ? Colors.red : Colors.grey.shade600
        ..strokeWidth = i % 90 == 0 ? 3 : 2;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), markPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class QiblaArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw arrow pointing to Qibla
    final path = Path();
    path.moveTo(center.dx, center.dy - 60); // Top point
    path.lineTo(center.dx - 12, center.dy - 35); // Left point
    path.lineTo(center.dx - 4, center.dy - 35); // Left inner
    path.lineTo(center.dx - 4, center.dy + 15); // Left bottom
    path.lineTo(center.dx + 4, center.dy + 15); // Right bottom
    path.lineTo(center.dx + 4, center.dy - 35); // Right inner
    path.lineTo(center.dx + 12, center.dy - 35); // Right point
    path.close();

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
