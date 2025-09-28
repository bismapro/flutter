import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final String appLogo = 'assets/images/logo/main-without-bg.png';
  static final String appName = dotenv.env['APP_NAME'] ?? 'Shollover';
  static final String apiUrl = dotenv.env['API_URL'] ?? '';
  static final String storageUrl = dotenv.env['STORAGE_URL'] ?? '';
}
