import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:test_flutter/core/utils/logger.dart';

class LocationService {
  static const _latKey = 'latitude';
  static const _longKey = 'longitude';
  static const _nameKey = 'location_name';
  static const _timeKey = 'local_time';
  static const _dateKey = 'local_date';

  /// Inisialisasi timezone database (panggil sekali di app)
  static Future<void> initializeTimeZone() async {
    tzData.initializeTimeZones();
  }

  /// Simpan ke cache
  static Future<void> _saveLocation(
    double lat,
    double long,
    String name,
    String date,
    String time,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_longKey, long);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_dateKey, date);
    await prefs.setString(_timeKey, time);
  }

  /// Ambil dari cache
  static Future<Map<String, dynamic>?> getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final long = prefs.getDouble(_longKey);
    final name = prefs.getString(_nameKey);
    final date = prefs.getString(_dateKey);
    final time = prefs.getString(_timeKey);
    if (lat == null ||
        long == null ||
        name == null ||
        date == null ||
        time == null)
      return null;
    return {'lat': lat, 'long': long, 'name': name, 'date': date, 'time': time};
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latKey);
    await prefs.remove(_longKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_dateKey);
    await prefs.remove(_timeKey);
  }

  /// Cek apakah sudah ada izin lokasi
  static Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      logger.warning('Error checking location permission: $e');
      return false;
    }
  }

  /// Minta izin lokasi
  static Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      logger.warning('Error requesting location permission: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.warning('Location services are disabled');
        await Geolocator.openLocationSettings();
        return await _loadFallbackOrCachedLocation();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          logger.warning('Location permission denied');
          return await _loadFallbackOrCachedLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        logger.warning('Location permission permanently denied');
        await Geolocator.openAppSettings();
        return await _loadFallbackOrCachedLocation();
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // 🗺️ Dapatkan nama lokasi
      final locationName = await _getLocationName(
        position.latitude,
        position.longitude,
      );

      // 🕒 Dapatkan waktu lokal
      final localDateTime = await _getLocalDateTime(
        position.latitude,
        position.longitude,
      );
      final date = localDateTime['date'];
      final time = localDateTime['time'];

      // 💾 Simpan ke cache
      await _saveLocation(
        position.latitude,
        position.longitude,
        locationName,
        date!,
        time!,
      );

      logger.info(
        '📍 $locationName | $date $time '
        '(${position.latitude}, ${position.longitude})',
      );

      return {
        'lat': position.latitude,
        'long': position.longitude,
        'name': locationName,
        'date': date,
        'time': time,
      };
    } catch (e) {
      logger.severe('Error getting current location: $e');
      return await _loadFallbackOrCachedLocation();
    }
  }

  /// Fallback ke cache atau Jakarta
  static Future<Map<String, dynamic>> _loadFallbackOrCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey) ?? -6.2088;
    final long = prefs.getDouble(_longKey) ?? 106.8456;
    final name = prefs.getString(_nameKey) ?? 'Jakarta, Indonesia';
    final date =
        prefs.getString(_dateKey) ??
        DateTime.now().toIso8601String().split('T').first;
    final time =
        prefs.getString(_timeKey) ??
        '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    logger.info('Using fallback location: $name ($lat, $long)');
    return {'lat': lat, 'long': long, 'name': name, 'date': date, 'time': time};
  }

  /// Reverse geocoding: koordinat → nama lokasi
  static Future<String> _getLocationName(double lat, double long) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return [
          if (p.locality?.isNotEmpty ?? false) p.locality,
          if (p.administrativeArea?.isNotEmpty ?? false) p.administrativeArea,
          if (p.country?.isNotEmpty ?? false) p.country,
        ].where((e) => e != null).join(', ');
      }
    } catch (e) {
      logger.warning('Reverse geocoding failed: $e');
    }
    return 'Unknown Location';
  }

  /// 🕓 Ambil jam & tanggal lokal berdasarkan koordinat
  static Future<Map<String, String>> _getLocalDateTime(
    double lat,
    double long,
  ) async {
    try {
      final location = tz.getLocation(_guessTimeZone(lat, long));
      final now = tz.TZDateTime.now(location);

      return {
        'date':
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        'time':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      };
    } catch (e) {
      logger.warning('Failed to get local time: $e');
      final now = DateTime.now();
      return {
        'date': now.toIso8601String().split('T').first,
        'time': '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      };
    }
  }

  /// Perkiraan zona waktu sederhana berdasarkan koordinat
  static String _guessTimeZone(double lat, double long) {
    if (long >= 95 && long < 110) return 'Asia/Jakarta';
    if (long >= 110 && long < 125) return 'Asia/Makassar';
    if (long >= 125 && long < 140) return 'Asia/Jayapura';
    return 'UTC';
  }
}
