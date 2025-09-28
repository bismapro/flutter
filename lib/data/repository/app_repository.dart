import '../models/surah.dart';
import '../services/quran_service.dart';
import '../../mock/mock_data.dart';

class AppRepository {
  // Quran related methods
  Future<List<Surah>> getAllSurahs() async {
    try {
      return await QuranService.getAllSurahs();
    } catch (e) {
      // Return mock data if service fails
      return _mockSurahs();
    }
  }

  Future<Map<String, dynamic>?> getSurahWithAyahs(int number) async {
    try {
      return await QuranService.getSurahWithAyahs(number);
    } catch (e) {
      return null;
    }
  }

  // Prayer times (using mock data for now)
  List<Map<String, dynamic>> getPrayerTimes() {
    return MockData.prayerTimes;
  }

  // Articles (using mock data)
  List<Map<String, dynamic>> getArticles() {
    return MockData.articles;
  }

  Map<String, dynamic>? getArticleById(int id) {
    try {
      return MockData.articles.firstWhere((article) => article['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Community events (using mock data)
  List<Map<String, dynamic>> getCommunityEvents() {
    return MockData.communityEvents;
  }

  // User data (using mock data)
  Map<String, dynamic> getUserData() {
    return MockData.userData;
  }

  // Private helper method to convert mock data to Surah objects
  List<Surah> _mockSurahs() {
    return MockData.surahs
        .map(
          (surahData) => Surah(
            nomor: surahData['number'],
            nama: surahData['name'],
            namaLatin: surahData['englishName'],
            jumlahAyat: surahData['verses'],
            tempatTurun: surahData['revelation'],
            arti: surahData['englishName'],
            deskripsi: 'Description for ${surahData['name']}',
            audioFull: {},
          ),
        )
        .toList();
  }
}
