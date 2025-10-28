import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:test_flutter/app/theme.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/data/services/location/location_service.dart';

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
  bool _isCompassCalibrated = false;
  double _compassHeading = 0.0;
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _locationSubscription;

  String _cityName = '';
  String _countryName = '';
  Timer? _reverseGeocodeDebouncer;
  String _location = '';

  // Koordinat Ka'bah (Makkah, Saudi Arabia)
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
    _reverseGeocodeDebouncer?.cancel();
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
      _location = '';
      _cityName = '';
      _countryName = '';
    });

    _locationSubscription?.cancel();
    _compassSubscription?.cancel();

    try {
      // Load lokasi dari LocationService
      await _loadLocationFromService();

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

  /// Load lokasi dari LocationService
  Future<void> _loadLocationFromService() async {
    setState(() => _status = 'Mengambil lokasi dari cache...');

    try {
      // Coba ambil dari cache dulu
      final cachedLocation = await LocationService.getLocation();

      if (cachedLocation != null) {
        setState(() {
          _location = cachedLocation['name'] as String;
          _cityName = (cachedLocation['name'] as String)
              .split(',')
              .first
              .trim();
          _countryName = (cachedLocation['name'] as String)
              .split(',')
              .last
              .trim()
              .toUpperCase();

          // Set position dari cache
          _currentPosition = Position(
            latitude: cachedLocation['lat'] as double,
            longitude: cachedLocation['long'] as double,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );

          _hasPermission = true;
        });

        // Calculate qibla dari cached location
        _calculateQiblaDirection();
      }

      // Kemudian request lokasi terbaru
      setState(() => _status = 'Memperbarui lokasi...');
      await _checkLocationPermissions();
    } catch (e) {
      logger.warning('Error loading location from service: $e');
      await _checkLocationPermissions();
    }
  }

  Future<void> _checkLocationPermissions() async {
    setState(() => _status = 'Memeriksa layanan lokasi...');
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

    setState(() => _status = 'Memeriksa izin lokasi...');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      setState(() => _status = 'Meminta izin lokasi...');
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
            'Izin lokasi ditolak permanen.\nAktifkan di Pengaturan > Privasi > Layanan Lokasi.';
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
      // Gunakan LocationService untuk mendapatkan lokasi
      final locationData = await LocationService.getCurrentLocation();

      setState(() {
        _location = locationData['name'] as String;
        _cityName = (locationData['name'] as String).split(',').first.trim();
        _countryName = (locationData['name'] as String)
            .split(',')
            .last
            .trim()
            .toUpperCase();

        _currentPosition = Position(
          latitude: locationData['lat'] as double,
          longitude: locationData['long'] as double,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );

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
        ).listen((Position position) async {
          if (mounted) {
            setState(() => _currentPosition = position);

            // Update reverse geocode jika posisi berubah signifikan
            await _reverseGeocodeCurrentPosition();

            _calculateQiblaDirection();
          }
        }, onError: (error) => logger.fine('Location update error: $error'));
  }

  Future<void> _reverseGeocodeCurrentPosition() async {
    if (_currentPosition == null) return;

    try {
      // Debounce agar tidak spam kalau stream lokasi sering update
      _reverseGeocodeDebouncer?.cancel();
      _reverseGeocodeDebouncer = Timer(
        const Duration(milliseconds: 600),
        () async {
          final placemarks = await placemarkFromCoordinates(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );

          if (placemarks.isNotEmpty && mounted) {
            final p = placemarks.first;

            // Urutan fallback: locality (kota) → subAdministrativeArea (kab) → administrativeArea (prov)
            final city = (p.locality?.trim().isNotEmpty == true)
                ? p.locality!.trim()
                : (p.subAdministrativeArea?.trim().isNotEmpty == true)
                ? p.subAdministrativeArea!.trim()
                : (p.administrativeArea?.trim().isNotEmpty == true)
                ? p.administrativeArea!.trim()
                : 'Lokasi Tidak Diketahui';

            setState(() {
              _cityName = city;
              _countryName = (p.country ?? '').toUpperCase();
              _location = '$_cityName, $_countryName';
            });
          }
        },
      );
    } catch (e) {
      // Kalau reverse geocode gagal, jangan crash—cukup tampilkan fallback
      if (mounted) {
        setState(() {
          _cityName = 'Lokasi Tidak Diketahui';
          // _countryName = _isInIndonesia() ? 'INDONESIA' : '—';
          _location = _cityName;
        });
      }
    }
  }

  // bool _isInIndonesia() {
  //   if (_currentPosition == null) return false;
  //   final lat = _currentPosition!.latitude;
  //   final lng = _currentPosition!.longitude;
  //   return (lat >= -11 && lat <= 6 && lng >= 95 && lng <= 141);
  // }

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

    setState(() {
      _qiblaDirection = qiblaBearing;
      _distanceToKaaba = distance;
      _isLoading = false;
      _status = 'Arah Kiblat telah ditemukan';
    });
  }

  double _calculateDistanceToKaaba() {
    if (_currentPosition == null) return 0;
    const double earthRadius = 6371; // KM

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

  double _degreeToRadian(double degree) => degree * (math.pi / 180);
  double _radianToDegree(double radian) => radian * (180 / math.pi);

  // ======= Responsiveness helpers =======
  double _compassSize(BuildContext context) {
    final w = ResponsiveHelper.getScreenWidth(context);
    double factor;
    if (ResponsiveHelper.isSmallScreen(context)) {
      factor = 0.7;
    } else if (ResponsiveHelper.isMediumScreen(context)) {
      factor = 0.55;
    } else if (ResponsiveHelper.isLargeScreen(context)) {
      factor = 0.45;
    } else {
      factor = 0.4;
    }
    final size = w * factor;
    return size.clamp(240, 420);
  }

  EdgeInsets _pagePadding(BuildContext context) =>
      ResponsiveHelper.getResponsivePadding(context);

  @override
  Widget build(BuildContext context) {
    final pagePad = _pagePadding(context);
    final titleSize = ResponsiveHelper.adaptiveTextSize(context, 28);
    final subtitleSize = ResponsiveHelper.adaptiveTextSize(context, 15);
    final useTwoColumns =
        MediaQuery.of(context).size.width >= ResponsiveHelper.largeScreenSize;

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
          child: Padding(
            padding: EdgeInsets.only(
              left: pagePad.left,
              right: pagePad.right,
              top: 8,
              bottom: 0,
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: pagePad.left / 2,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppTheme.onSurface,
                        tooltip: 'Kembali',
                      ),
                      const SizedBox(width: 12),
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
                          size: ResponsiveHelper.adaptiveTextSize(context, 26),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arah Kiblat',
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Temukan arah kiblat',
                              style: TextStyle(
                                fontSize: subtitleSize,
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

                Expanded(
                  child: useTwoColumns
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: pagePad.right / 2,
                                  top: 8,
                                ),
                                child: _buildBody(compact: false),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: pagePad.left / 2,
                                  top: 8,
                                ),
                                child: _buildSideInfo(),
                              ),
                            ),
                          ],
                        )
                      : _buildBody(compact: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====== BODY ======
  Widget _buildBody({required bool compact}) {
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
              child: const SizedBox(
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
              style: TextStyle(
                fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
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
          padding: EdgeInsets.all(compact ? 24 : 32),
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
                  size: ResponsiveHelper.adaptiveTextSize(context, 64),
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Izin Lokasi Diperlukan',
                style: TextStyle(
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 20),
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _status,
                style: TextStyle(
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 15),
                  color: AppTheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeCompass,
                icon: const Icon(Icons.refresh_rounded, size: 22),
                label: Text(
                  'Coba Lagi',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
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
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isSmallScreen(context) ? 12 : 24,
      ),
      child: Column(
        children: [
          if (compact) ...[_buildLocationInfo(), const SizedBox(height: 24)],
          _buildCompass(),
          const SizedBox(height: 24),
          if (compact) ...[
            _buildQiblaInfo(),
            const SizedBox(height: 16),
            _buildDisclaimer(),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildSideInfo() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLocationInfo(),
          const SizedBox(height: 24),
          _buildQiblaInfo(),
          const SizedBox(height: 16),
          _buildDisclaimer(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ====== UI Sections ======
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
                size: ResponsiveHelper.adaptiveTextSize(context, 18),
              ),
              const SizedBox(width: 6),
              Text(
                'Lokasi Real-time',
                style: TextStyle(
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 13),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _location.isNotEmpty ? _location : 'Mencari lokasi...',
            style: TextStyle(
              fontSize: ResponsiveHelper.adaptiveTextSize(context, 22),
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _countryName.isNotEmpty ? _countryName : '—',
            style: TextStyle(
              fontSize: ResponsiveHelper.adaptiveTextSize(context, 13),
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
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 11),
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
    final size = _compassSize(context);
    final ring = size;
    final innerBlue = size - 20;
    final face = size - 40;
    final cardinalsBox = size - 40;

    final qiblaAngle = (_qiblaDirection - _compassHeading) * math.pi / 180;

    return Center(
      child: SizedBox(
        width: ring,
        height: ring,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer gradient ring
            Container(
              width: ring,
              height: ring,
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
              width: innerBlue,
              height: innerBlue,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue,
              ),
            ),

            // White compass face (rotate with heading)
            Transform.rotate(
              angle: -_compassHeading * math.pi / 180,
              child: Container(
                width: face,
                height: face,
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
                  size: Size(face, face),
                  painter: CompassFacePainter(),
                ),
              ),
            ),

            // Cardinal marks (rotate with compass)
            Transform.rotate(
              angle: -_compassHeading * math.pi / 180,
              child: _buildCardinalDirections(cardinalsBox),
            ),

            // Qibla needle (points to Ka'bah)
            Transform.rotate(
              angle: qiblaAngle,
              child: CustomPaint(
                size: Size(face, face),
                painter: QiblaNeedlePainter(),
              ),
            ),

            // Kaaba indicator
            Transform.rotate(
              angle: qiblaAngle,
              child: Transform.translate(
                offset: Offset(0, -(face / 2) + 40),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.onSurface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '🕋',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.adaptiveTextSize(context, 20),
                    ),
                  ),
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
                      const Icon(
                        Icons.sync_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Kalibrasi kompas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.adaptiveTextSize(
                            context,
                            11,
                          ),
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

  Widget _buildCardinalDirections(double box) {
    final labelSize = ResponsiveHelper.adaptiveTextSize(context, 14);
    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _cardinal('N', Alignment.topCenter, primary: true, size: labelSize),
          _cardinal('S', Alignment.bottomCenter, size: labelSize),
          _cardinal('E', Alignment.centerRight, size: labelSize),
          _cardinal('W', Alignment.centerLeft, size: labelSize),
        ],
      ),
    );
  }

  Widget _cardinal(
    String t,
    Alignment align, {
    bool primary = false,
    required double size,
  }) {
    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: primary
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlue.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: primary
              ? null
              : AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Text(
          t,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size,
          ),
        ),
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
                  size: ResponsiveHelper.adaptiveTextSize(context, 24),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_qiblaDirection.toStringAsFixed(1)}°',
                style: TextStyle(
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 32),
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
              fontSize: ResponsiveHelper.adaptiveTextSize(context, 15),
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
                size: ResponsiveHelper.adaptiveTextSize(context, 18),
                color: AppTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Jarak ke Ka\'bah ± ${_distanceToKaaba.toStringAsFixed(0)} KM',
                style: TextStyle(
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 15),
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
                  size: ResponsiveHelper.adaptiveTextSize(context, 16),
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
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 12),
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
              size: ResponsiveHelper.adaptiveTextSize(context, 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Jauhkan perangkat dari objek berbahan besi/logam agar hasil lebih akurat.',
              style: TextStyle(
                fontSize: ResponsiveHelper.adaptiveTextSize(context, 13),
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

// ===== Painters =====
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

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(path, outlinePaint);

    final tipPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final tipPath = Path()
      ..moveTo(center.dx, center.dy - 100)
      ..lineTo(center.dx - 10, center.dy - 65)
      ..lineTo(center.dx + 10, center.dy - 65)
      ..close();

    canvas.drawPath(tipPath, tipPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
