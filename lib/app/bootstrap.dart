import 'dart:async';
import 'dart:isolate';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/services/cache/cache_service.dart';
import 'package:test_flutter/data/services/location/location_service.dart';
import 'package:test_flutter/features/sholat/services/alarm_service.dart';
import 'package:test_flutter/data/services/audio_player_service.dart';

final bootstrapProvider = FutureProvider<void>((ref) async {
  // Sinkron, cepat
  initLogger();
  ApiClient.setupInterceptors();

  // Jalankan tugas berat & I/O secara paralel
  await Future.wait([
    // timezones cukup berat → pindah ke isolate agar tidak block UI
    Isolate.run(() async => tz.initializeTimeZones()),

    // Intl locale
    initializeDateFormatting('id_ID', null),

    // Cache & services lain
    CacheService.init(),
    AlarmService().initialize(),
    QuranAudioService.init(),
  ]);

  // Lokasi: jangan block start—ambil di background
  unawaited(_warmupLocation());
});

Future<void> _warmupLocation() async {
  try {
    final location = await LocationService.getCurrentLocation();
    logger.fine(
      '📍 Lokasi: ${location['name']} '
      '(${location['lat']}, ${location['long']})',
    );
  } catch (e) {
    logger.fine('Error get location: $e');
  }
}
