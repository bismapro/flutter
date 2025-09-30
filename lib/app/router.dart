import 'package:flutter/material.dart';
import 'package:test_flutter/features/alarm/pages/alarm_settings_page.dart';
import 'package:test_flutter/features/artikel/pages/artikel_detail_page.dart';
import 'package:test_flutter/features/auth/pages/login_page.dart';
import 'package:test_flutter/features/auth/pages/signup_page.dart';
import 'package:test_flutter/features/auth/pages/splash_screen.dart';
import 'package:test_flutter/features/auth/pages/welcome_page.dart';
import 'package:test_flutter/features/compass/pages/compass_page.dart';
import 'package:test_flutter/features/home/pages/home_page.dart';
import 'package:test_flutter/features/monitoring/pages/monitoring_page.dart';
import 'package:test_flutter/features/ngaji/pages/ngaji_online_page.dart';
import 'package:test_flutter/features/profile/pages/profile_page.dart';
import 'package:test_flutter/features/puasa/pages/puasa_page.dart';
import 'package:test_flutter/features/quran/pages/quran_page.dart';
import 'package:test_flutter/features/quran/pages/surah_detail_page.dart';
import 'package:test_flutter/features/sedekah/pages/sedekah_page.dart';
import 'package:test_flutter/features/sholat/pages/sholat_page.dart';
import 'package:test_flutter/features/tahajud/pages/tahajud_page.dart';

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
  static const String ngajiOnline = '/ngaji-online';
  static const String monitoring = '/monitoring';
  static const String tahajud = '/tahajud';
  static const String articleDetail = '/article-detail';
  static const String alarmSettings = '/alarm-settings';
  static const String profile = '/profile';

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
        return MaterialPageRoute(builder: (_) => const CompassPage());
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
        return MaterialPageRoute(builder: (_) => const SedekahPage());
      case ngajiOnline:
        return MaterialPageRoute(builder: (_) => const NgajiOnlinePage());
      case monitoring:
        return MaterialPageRoute(builder: (_) => const MonitoringPage());
      case tahajud:
        return MaterialPageRoute(builder: (_) => const TahajudPage());
      case articleDetail:
        return MaterialPageRoute(
          builder: (_) =>
              ArtikelDetailPage(article: settings.arguments as dynamic),
        );
      case alarmSettings:
        return MaterialPageRoute(builder: (_) => const AlarmSettingsPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
