import 'package:quran/quran.dart' as quran;

class ReciterConfig {
  static const Map<String, quran.Reciter> reciterMap = {
    'arAlafasy': quran.Reciter.arAlafasy,
    'arHusary': quran.Reciter.arHusary,
    'arAhmedAjamy': quran.Reciter.arAhmedAjamy,
    'arHudhaify': quran.Reciter.arHudhaify,
    'arMaherMuaiqly': quran.Reciter.arMaherMuaiqly,
    'arMuhammadAyyoub': quran.Reciter.arMuhammadAyyoub,
    'arMuhammadJibreel': quran.Reciter.arMuhammadJibreel,
    'arMinshawi': quran.Reciter.arMinshawi,
    'arShaatree': quran.Reciter.arShaatree,
  };

  static const Map<String, String> reciterNames = {
    'arAlafasy': 'Mishari Alafasy',
    'arHusary': 'Mahmoud Husary',
    'arAhmedAjamy': 'Ahmed al-Ajamy',
    'arHudhaify': 'Ali Hudhaify',
    'arMaherMuaiqly': 'Maher Al Muaiqly',
    'arMuhammadAyyoub': 'Muhammad Ayyoub',
    'arMuhammadJibreel': 'Muhammad Jibreel',
    'arMinshawi': 'Mohamed Siddiq al-Minshawi',
    'arShaatree': 'Abu Bakr Ash-Shaatree',
  };

  static const List<int> bitrateOptions = [64, 128, 192];
}
