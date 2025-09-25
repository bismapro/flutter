import 'package:flutter/material.dart';
import '../../presentation/pages/welcome_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/signup_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/qibla_compass_page.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String qiblaCompass = '/qibla-compass';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case qiblaCompass:
        return MaterialPageRoute(builder: (_) => const QiblaCompassPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
