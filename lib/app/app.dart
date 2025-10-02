import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_flutter/core/constants/app_config.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/features/auth/auth_provider.dart';
import 'package:test_flutter/features/home/pages/home_page.dart';
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
  void initState() {
    // Check authentication status when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state to determine which screen to show
    final authState = ref.watch(authProvider);

    // Debug auth state
    logger.fine('Current auth state: ${authState['status']}');
    if (authState['user'] != null) {
      logger.fine('User data: ${authState['user']}');
    }

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
      home: _buildHome(authState),
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildHome(Map<String, dynamic> authState) {
    final status = authState['status'];

    // Show loading screen while checking authentication
    if (status == AuthState.initial || status == AuthState.loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show home screen if authenticated, otherwise login screen
    if (status == AuthState.authenticated) {
      return const HomePage();
    } else {
      return const SplashScreen();
    }
  }
}
