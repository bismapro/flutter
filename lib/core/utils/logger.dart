// lib/core/utils/logger.dart
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Global app logger
final Logger logger = Logger('AppLogger');

void initLogger() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;

  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '[${record.level.name}] ${record.time}: ${record.loggerName}: ${record.message}',
    );
  });
}
