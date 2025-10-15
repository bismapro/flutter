// main.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hanya init yang benar-benar wajib sebelum runApp
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env"); // cepat, aman dibiarkan

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('id'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('id'),
      useOnlyLangCode: true,
      child: const ProviderScope(child: MyApp()),
    ),
  );
}
