import 'package:quran/quran.dart' as quran;
import 'package:test_flutter/data/models/quran/juz.dart';
import 'package:test_flutter/data/models/quran/surah.dart';

class QuranService {
  // Get all surahs
  static List<Surah> getAllSurahs() {
    List<Surah> surahs = [];

    for (int i = 1; i <= 114; i++) {
      surahs.add(
        Surah(
          nomor: i,
          nama: quran.getSurahNameArabic(i),
          namaLatin: getSurahNameLatin(i),
          jumlahAyat: quran.getVerseCount(i),
          tempatTurun: quran.getPlaceOfRevelation(i),
          arti: getSurahMeaning(i),
          deskripsi: '',
          audioFull: {},
        ),
      );
    }

    return surahs;
  }

  // Get all juz with details
  static List<Juz> getAllJuz() {
    List<Juz> juzList = [];

    for (int i = 1; i <= 30; i++) {
      final juzData = _getJuzDetails(i);
      juzList.add(juzData);
    }

    return juzList;
  }

  // Get juz details
  static Juz _getJuzDetails(int juzNumber) {
    // Mapping juz start and end
    final juzMapping = {
      1: {
        'start': [1, 1],
        'end': [2, 141],
      },
      2: {
        'start': [2, 142],
        'end': [2, 252],
      },
      3: {
        'start': [2, 253],
        'end': [3, 92],
      },
      4: {
        'start': [3, 93],
        'end': [4, 23],
      },
      5: {
        'start': [4, 24],
        'end': [4, 147],
      },
      6: {
        'start': [4, 148],
        'end': [5, 81],
      },
      7: {
        'start': [5, 82],
        'end': [6, 110],
      },
      8: {
        'start': [6, 111],
        'end': [7, 87],
      },
      9: {
        'start': [7, 88],
        'end': [8, 40],
      },
      10: {
        'start': [8, 41],
        'end': [9, 92],
      },
      11: {
        'start': [9, 93],
        'end': [11, 5],
      },
      12: {
        'start': [11, 6],
        'end': [12, 52],
      },
      13: {
        'start': [12, 53],
        'end': [14, 52],
      },
      14: {
        'start': [15, 1],
        'end': [16, 128],
      },
      15: {
        'start': [17, 1],
        'end': [18, 74],
      },
      16: {
        'start': [18, 75],
        'end': [20, 135],
      },
      17: {
        'start': [21, 1],
        'end': [22, 78],
      },
      18: {
        'start': [23, 1],
        'end': [25, 20],
      },
      19: {
        'start': [25, 21],
        'end': [27, 55],
      },
      20: {
        'start': [27, 56],
        'end': [29, 45],
      },
      21: {
        'start': [29, 46],
        'end': [33, 30],
      },
      22: {
        'start': [33, 31],
        'end': [36, 27],
      },
      23: {
        'start': [36, 28],
        'end': [39, 31],
      },
      24: {
        'start': [39, 32],
        'end': [41, 46],
      },
      25: {
        'start': [41, 47],
        'end': [45, 37],
      },
      26: {
        'start': [46, 1],
        'end': [51, 30],
      },
      27: {
        'start': [51, 31],
        'end': [57, 29],
      },
      28: {
        'start': [58, 1],
        'end': [66, 12],
      },
      29: {
        'start': [67, 1],
        'end': [77, 50],
      },
      30: {
        'start': [78, 1],
        'end': [114, 6],
      },
    };

    final data = juzMapping[juzNumber]!;
    final startSurah = data['start']![0];
    final startAyah = data['start']![1];
    final endSurah = data['end']![0];
    final endAyah = data['end']![1];

    return Juz(
      number: juzNumber,
      startSurah: startSurah,
      startAyah: startAyah,
      endSurah: endSurah,
      endAyah: endAyah,
      startSurahName: quran.getSurahNameArabic(startSurah),
      endSurahName: quran.getSurahNameArabic(endSurah),
    );
  }

  // Get total verses in juz
  static int getJuzTotalVerses(int juzNumber) {
    final juzData = _getJuzDetails(juzNumber);
    int total = 0;

    for (int surah = juzData.startSurah; surah <= juzData.endSurah; surah++) {
      if (surah == juzData.startSurah && surah == juzData.endSurah) {
        // Same surah
        total += (juzData.endAyah - juzData.startAyah + 1);
      } else if (surah == juzData.startSurah) {
        // First surah
        total += (quran.getVerseCount(surah) - juzData.startAyah + 1);
      } else if (surah == juzData.endSurah) {
        // Last surah
        total += juzData.endAyah;
      } else {
        // Middle surahs
        total += quran.getVerseCount(surah);
      }
    }

    return total;
  }

  // Get surah name in Latin
  static String getSurahNameLatin(int surahNumber) {
    final latinNames = {
      1: 'Al-Fatihah',
      2: 'Al-Baqarah',
      3: 'Ali \'Imran',
      4: 'An-Nisa\'',
      5: 'Al-Ma\'idah',
      6: 'Al-An\'am',
      7: 'Al-A\'raf',
      8: 'Al-Anfal',
      9: 'At-Taubah',
      10: 'Yunus',
      11: 'Hud',
      12: 'Yusuf',
      13: 'Ar-Ra\'d',
      14: 'Ibrahim',
      15: 'Al-Hijr',
      16: 'An-Nahl',
      17: 'Al-Isra\'',
      18: 'Al-Kahf',
      19: 'Maryam',
      20: 'Taha',
      21: 'Al-Anbiya\'',
      22: 'Al-Hajj',
      23: 'Al-Mu\'minun',
      24: 'An-Nur',
      25: 'Al-Furqan',
      26: 'Ash-Shu\'ara\'',
      27: 'An-Naml',
      28: 'Al-Qasas',
      29: 'Al-\'Ankabut',
      30: 'Ar-Rum',
      31: 'Luqman',
      32: 'As-Sajdah',
      33: 'Al-Ahzab',
      34: 'Saba\'',
      35: 'Fatir',
      36: 'Ya-Sin',
      37: 'As-Saffat',
      38: 'Sad',
      39: 'Az-Zumar',
      40: 'Ghafir',
      41: 'Fussilat',
      42: 'Ash-Shura',
      43: 'Az-Zukhruf',
      44: 'Ad-Dukhan',
      45: 'Al-Jathiyah',
      46: 'Al-Ahqaf',
      47: 'Muhammad',
      48: 'Al-Fath',
      49: 'Al-Hujurat',
      50: 'Qaf',
      51: 'Adh-Dhariyat',
      52: 'At-Tur',
      53: 'An-Najm',
      54: 'Al-Qamar',
      55: 'Ar-Rahman',
      56: 'Al-Waqi\'ah',
      57: 'Al-Hadid',
      58: 'Al-Mujadila',
      59: 'Al-Hashr',
      60: 'Al-Mumtahanah',
      61: 'As-Saf',
      62: 'Al-Jumu\'ah',
      63: 'Al-Munafiqun',
      64: 'At-Taghabun',
      65: 'At-Talaq',
      66: 'At-Tahrim',
      67: 'Al-Mulk',
      68: 'Al-Qalam',
      69: 'Al-Haqqah',
      70: 'Al-Ma\'arij',
      71: 'Nuh',
      72: 'Al-Jinn',
      73: 'Al-Muzzammil',
      74: 'Al-Muddaththir',
      75: 'Al-Qiyamah',
      76: 'Al-Insan',
      77: 'Al-Mursalat',
      78: 'An-Naba\'',
      79: 'An-Nazi\'at',
      80: '\'Abasa',
      81: 'At-Takwir',
      82: 'Al-Infitar',
      83: 'Al-Mutaffifin',
      84: 'Al-Inshiqaq',
      85: 'Al-Buruj',
      86: 'At-Tariq',
      87: 'Al-A\'la',
      88: 'Al-Ghashiyah',
      89: 'Al-Fajr',
      90: 'Al-Balad',
      91: 'Ash-Shams',
      92: 'Al-Lail',
      93: 'Ad-Duha',
      94: 'Ash-Sharh',
      95: 'At-Tin',
      96: 'Al-\'Alaq',
      97: 'Al-Qadr',
      98: 'Al-Bayyinah',
      99: 'Az-Zalzalah',
      100: 'Al-\'Adiyat',
      101: 'Al-Qari\'ah',
      102: 'At-Takathur',
      103: 'Al-\'Asr',
      104: 'Al-Humazah',
      105: 'Al-Fil',
      106: 'Quraish',
      107: 'Al-Ma\'un',
      108: 'Al-Kawthar',
      109: 'Al-Kafirun',
      110: 'An-Nasr',
      111: 'Al-Masad',
      112: 'Al-Ikhlas',
      113: 'Al-Falaq',
      114: 'An-Nas',
    };

    return latinNames[surahNumber] ?? '';
  }

  // Get surah meaning
  static String getSurahMeaning(int surahNumber) {
    final meanings = {
      1: 'Pembukaan',
      2: 'Sapi Betina',
      3: 'Keluarga Imran',
      4: 'Wanita',
      5: 'Hidangan',
      6: 'Binatang Ternak',
      7: 'Tempat Tertinggi',
      8: 'Harta Rampasan',
      9: 'Pengampunan',
      10: 'Yunus',
      11: 'Hud',
      12: 'Yusuf',
      13: 'Guruh',
      14: 'Ibrahim',
      15: 'Hijr',
      16: 'Lebah',
      17: 'Perjalanan Malam',
      18: 'Gua',
      19: 'Maryam',
      20: 'Taha',
      21: 'Para Nabi',
      22: 'Haji',
      23: 'Orang-orang Mukmin',
      24: 'Cahaya',
      25: 'Pembeda',
      26: 'Para Penyair',
      27: 'Semut',
      28: 'Kisah',
      29: 'Laba-laba',
      30: 'Romawi',
      31: 'Luqman',
      32: 'Sajdah',
      33: 'Golongan yang Bersekutu',
      34: 'Saba\'',
      35: 'Pencipta',
      36: 'Yasin',
      37: 'Barisan-barisan',
      38: 'Sad',
      39: 'Rombongan',
      40: 'Yang Mengampuni',
      41: 'Yang Dijelaskan',
      42: 'Musyawarah',
      43: 'Perhiasan',
      44: 'Kabut',
      45: 'Berlutut',
      46: 'Bukit Pasir',
      47: 'Muhammad',
      48: 'Kemenangan',
      49: 'Kamar-kamar',
      50: 'Qaf',
      51: 'Angin yang Menerbangkan',
      52: 'Bukit Tursina',
      53: 'Bintang',
      54: 'Bulan',
      55: 'Yang Maha Pemurah',
      56: 'Hari Kiamat',
      57: 'Besi',
      58: 'Wanita yang Mengajukan Gugatan',
      59: 'Pengusiran',
      60: 'Wanita yang Diuji',
      61: 'Shaf',
      62: 'Jumat',
      63: 'Orang-orang Munafik',
      64: 'Hari Dinampakkan Kesalahan',
      65: 'Talak',
      66: 'Pengharaman',
      67: 'Kerajaan',
      68: 'Pena',
      69: 'Hari Kiamat',
      70: 'Tempat Naik',
      71: 'Nuh',
      72: 'Jin',
      73: 'Orang yang Berselimut',
      74: 'Orang yang Berkemul',
      75: 'Hari Kiamat',
      76: 'Manusia',
      77: 'Malaikat yang Diutus',
      78: 'Berita Besar',
      79: 'Malaikat yang Mencabut',
      80: 'Bermuka Masam',
      81: 'Menggulung',
      82: 'Terbelah',
      83: 'Orang-orang yang Curang',
      84: 'Terbelah',
      85: 'Gugusan Bintang',
      86: 'Yang Datang di Malam Hari',
      87: 'Yang Paling Tinggi',
      88: 'Hari Pembalasan',
      89: 'Fajar',
      90: 'Negeri',
      91: 'Matahari',
      92: 'Malam',
      93: 'Duha',
      94: 'Kelapangan',
      95: 'Buah Tin',
      96: 'Segumpal Darah',
      97: 'Kemuliaan',
      98: 'Bukti yang Nyata',
      99: 'Kegoncangan',
      100: 'Kuda yang Berlari Kencang',
      101: 'Hari Kiamat',
      102: 'Bermegah-megahan',
      103: 'Asar',
      104: 'Pengumpat',
      105: 'Gajah',
      106: 'Quraisy',
      107: 'Barang-barang yang Berguna',
      108: 'Nikmat yang Banyak',
      109: 'Orang-orang Kafir',
      110: 'Pertolongan',
      111: 'Api yang Bergejolak',
      112: 'Ikhlas',
      113: 'Subuh',
      114: 'Manusia',
    };

    return meanings[surahNumber] ?? '';
  }
}
