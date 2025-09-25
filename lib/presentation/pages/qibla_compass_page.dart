import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
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

  // Kaaba coordinates (Mecca, Saudi Arabia)
  static const double _kaabaLatitude = 21.422487;
  static const double _kaabaLongitude = 39.826206;

  @override
  void initState() {
    super.initState();
    _initializeCompass();
  }

  Future<void> _initializeCompass() async {
    try {
      await _checkLocationPermissions();
      if (_hasPermission) {
        await _getCurrentLocation();
        if (_currentPosition != null) {
          _calculateQiblaDirection();
        }
      }
    } catch (e) {
      setState(() {
        _status = 'Error: ';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _status = 'Layanan lokasi tidak aktif. Silakan aktifkan GPS.';
        _isLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _status = 'Izin lokasi ditolak.';
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _status = 'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _hasPermission = true;
      _status = 'Mendapatkan lokasi...';
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _status = 'Menghitung arah Kiblat...';
      });
    } catch (e) {
      setState(() {
        _status = 'Gagal mendapatkan lokasi: ';
        _isLoading = false;
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

    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) - 
               math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x);
    double qiblaBearing = _radianToDegree(bearing);
    
    // Normalize to 0-360 degrees
    qiblaBearing = (qiblaBearing + 360) % 360;

    setState(() {
      _qiblaDirection = qiblaBearing;
      _isLoading = false;
      _status = 'Arah Kiblat telah ditemukan';
    });
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
            const CircularProgressIndicator(
              color: AppTheme.primaryGreen,
            ),
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
              Icon(
                Icons.location_off,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                _status,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeCompass,
                icon: const Icon(Icons.location_on),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            ' Lokasi Anda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (_currentPosition != null) ...[
            Text(
              'Lat: ',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              'Lng: ',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Arah Kiblat: ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
            // Compass circle
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
            
            // Qibla direction arrow
            Transform.rotate(
              angle: _qiblaDirection * math.pi / 180,
              child: Container(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: QiblaArrowPainter(),
                ),
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
            
            // Kaaba icon
            Transform.rotate(
              angle: _qiblaDirection * math.pi / 180,
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
                  child: const Text(
                    '',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            ' Petunjuk Penggunaan',
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
            '3. Ikon  menunjukkan arah tepat menuju Kiblat\n'
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
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
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
