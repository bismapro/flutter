import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'router.dart';
import '../features/auth/pages/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: tr('app.name'),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
