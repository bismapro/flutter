import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';

class QuranService {
  static const String _baseUrl = 'http://api.alquran.cloud/v1';

  // Get all surahs
  static Future<List<Surah>> getAllSurahs() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/surah'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> surahsData = data['data'];
        
        return surahsData.map((surahData) => Surah.fromJson(surahData)).toList();
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
      final response = await http.get(Uri.parse('$_baseUrl/surah/$surahNumber'));
      
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

  // Get surah with Indonesian translation
  static Future<Map<String, dynamic>> getSurahWithTranslation(int surahNumber) async {
    try {
      // Get Arabic text
      final arabicResponse = await http.get(Uri.parse('$_baseUrl/surah/$surahNumber'));
      // Get Indonesian translation
      final translationResponse = await http.get(Uri.parse('$_baseUrl/surah/$surahNumber/id.indonesian'));
      
      if (arabicResponse.statusCode == 200 && translationResponse.statusCode == 200) {
        final Map<String, dynamic> arabicData = json.decode(arabicResponse.body);
        final Map<String, dynamic> translationData = json.decode(translationResponse.body);
        
        return {
          'surah': arabicData['data'],
          'translation': translationData['data'],
        };
      } else {
        throw Exception('Failed to load surah with translation');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}