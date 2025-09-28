import 'package:flutter/material.dart';
import '../features/auth/pages/splash_screen.dart';
import '../features/auth/pages/welcome_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/signup_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/worship/pages/qibla_compass_page.dart';
import '../features/worship/pages/quran_page.dart';
import '../features/worship/pages/surah_detail_page.dart';
import '../features/worship/pages/sholat_page.dart';
import '../features/worship/pages/puasa_page.dart';
import '../features/worship/pages/zakat_page.dart';
import '../features/articles/pages/article_detail_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String qiblaCompass = '/qibla-compass';
  static const String quran = '/quran';
  static const String surahDetail = '/surah-detail';
  static const String sholat = '/sholat';
  static const String puasa = '/puasa';
  static const String zakat = '/zakat';
  static const String articleDetail = '/article-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
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
      case quran:
        return MaterialPageRoute(builder: (_) => const QuranPage());
      case surahDetail:
        return MaterialPageRoute(
          builder: (_) => SurahDetailPage(surah: settings.arguments as dynamic),
        );
      case sholat:
        return MaterialPageRoute(builder: (_) => const SholatPage());
      case puasa:
        return MaterialPageRoute(builder: (_) => const PuasaPage());
      case zakat:
        return MaterialPageRoute(builder: (_) => const ZakatPage());
      case articleDetail:
        return MaterialPageRoute(
          builder: (_) =>
              ArticleDetailPage(article: settings.arguments as dynamic),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
