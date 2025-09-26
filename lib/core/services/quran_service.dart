import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';

class QuranService {
  static const String _baseUrl = 'https://equran.id/api/v2';

  // Get all surahs
  static Future<List<Surah>> getAllSurahs() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/surat'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> surahsData = data['data'];

        return surahsData
            .map((surahData) => Surah.fromJson(surahData))
            .toList();
      } else {
        throw Exception('Failed to load surahs');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get specific surah with ayahs
  static Future<Map<String, dynamic>> getSurahWithAyahs(int surahNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/surat/$surahNumber'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load surah');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get available reciters for audio
  static List<Map<String, String>> getReciters() {
    return [
      {'id': '01', 'name': 'Abdullah Al-Juhany'},
      {'id': '02', 'name': 'Abdul Muhsin Al-Qasim'},
      {'id': '03', 'name': 'Abdurrahman as-Sudais'},
      {'id': '04', 'name': 'Ibrahim Al-Dossari'},
      {'id': '05', 'name': 'Misyari Rasyid Al-Afasi'},
    ];
  }
}
