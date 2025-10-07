import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/services/cache_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app/app.dart';
import 'data/services/alarm_service.dart';
import 'data/services/audio_player_service.dart';

Future<void> main() async {
  // Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Load all timezone data
  tz.initializeTimeZones();

  // Easy Localization init (wajib sebelum runApp)
  await EasyLocalization.ensureInitialized();

  // Initialize cache service
  await CacheService.init();

  // Logger
  initLogger();

  // Env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    logger.fine('Error loading .env file: $e');
  }

  // Locale data Intl (tanggal/angka) — contoh: Indonesia
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    logger.fine('Error initializeDateFormatting: $e');
  }

  // Interceptors
  ApiClient.setupInterceptors();

  // Services
  try {
    await AlarmService().initialize();
  } catch (e) {
    logger.fine('Error initializing alarm service: $e');
  }

  try {
    await QuranAudioService.init();
  } catch (e) {
    logger.fine('Error initializing audio service: $e');
  }

  // Jalankan app dengan EasyLocalization membungkus ProviderScope + MyApp
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('id'),
        Locale('en'),
      ], // hanya English & Indonesia
      path: 'assets/translations', // sesuaikan dgn folder JSON kamu
      fallbackLocale: const Locale('id'),
      useOnlyLangCode: true, // pakai en.json & id.json
      child: ProviderScope(child: const MyApp()),
    ),
  );
}
