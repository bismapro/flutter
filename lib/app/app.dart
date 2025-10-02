import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_flutter/core/constants/app_config.dart';
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
    // Watch auth state to determine which screen to show
    // final authState = ref.watch(authProvider);

    // Debug auth state
    // logger.fine('Current auth state: ${authState['status']}');
    // if (authState['user'] != null) {
    //   logger.fine('User data: ${authState['user']}');
    // }

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  // Widget _buildHome(Map<String, dynamic> authState) {
  //   final status = authState['status'];

  //   // Show loading screen while checking authentication
  //   if (status == AuthState.initial || status == AuthState.loading) {
  //     return Scaffold(body: Center(child: CircularProgressIndicator()));
  //   }

  //   // Show home screen if authenticated, otherwise login screen
  //   if (status == AuthState.authenticated) {
  //     return const HomePage();
  //   } else {
  //     return const SplashScreen();
  //   }
  // }
}
