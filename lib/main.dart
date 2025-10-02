import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'app/app.dart';
import 'data/services/alarm_service.dart';
import 'data/services/audio_player_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initLogger();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    logger.fine('Error loading .env file: $e');
  }

  // Initialize Indonesian locale data
  await initializeDateFormatting('id_ID', null);

  ApiClient.setupInterceptors();

  // Initialize alarm service
  try {
    await AlarmService().initialize();
  } catch (e) {
    logger.fine('Error initializing alarm service: $e');
  }

  // Initialize audio service
  try {
    await QuranAudioService.init();
  } catch (e) {
    logger.fine('Error initializing audio service: $e');
  }

  runApp(ProviderScope(child: const MyApp()));
}
