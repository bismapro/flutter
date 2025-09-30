import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'data/services/alarm_service.dart';
import 'data/services/audio_player_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indonesian locale data
  await initializeDateFormatting('id_ID', null);

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    if (kDebugMode) {
      print('Error loading .env file: $e');
    }
  }

  // Initialize alarm service
  try {
    await AlarmService().initialize();
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing alarm service: $e');
    }
  }

  // Initialize audio service
  try {
    await QuranAudioService.init();
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing audio service: $e');
    }
  }

  runApp(const MyApp());
}
