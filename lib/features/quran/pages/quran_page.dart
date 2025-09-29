import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/data/models/surah.dart';
import 'package:test_flutter/data/models/sheikh.dart';
import 'package:test_flutter/data/services/quran_service.dart';
import 'package:test_flutter/data/services/audio_download_service.dart';
import 'package:test_flutter/features/quran/pages/juz_detail_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage>
    with SingleTickerProviderStateMixin {
  List<Surah> _surahs = [];
  List<Surah> _filteredSurahs = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, AudioDownload> _downloadProgress = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSurahs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSurahs() async {
    try {
      final surahs = await QuranService.getAllSurahs();
      if (mounted) {
        setState(() {
          _surahs = surahs;
          _filteredSurahs = surahs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading surahs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterSurahs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSurahs = _surahs;
      } else {
        _filteredSurahs = _surahs.where((surah) {
          return surah.nama.toLowerCase().contains(query.toLowerCase()) ||
              surah.namaLatin.toLowerCase().contains(query.toLowerCase()) ||
              surah.arti.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Al-Quran',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            decoration: const BoxDecoration(color: AppTheme.primaryBlue),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3.0,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
              tabs: const [
                Tab(text: 'SURAH'),
                Tab(text: 'JUZ'),
                Tab(text: 'BOOKMARK'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // SURAH Tab
          _buildSurahTab(),
          // JUZ Tab
          _buildJuzTab(),
          // BOOKMARK Tab
          _buildBookmarkTab(),
        ],
      ),
    );
  }

  Widget _buildSurahTab() {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _filterSurahs,
            decoration: InputDecoration(
              hintText: 'Cari surat...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        // Surahs List
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                )
              : _filteredSurahs.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada surat yang ditemukan',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredSurahs.length,
                  itemBuilder: (context, index) {
                    final surah = _filteredSurahs[index];
                    return _buildSurahCard(surah);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildJuzTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        return _buildJuzCard(juzNumber);
      },
    );
  }

  Widget _buildJuzCard(int juzNumber) {
    // Data untuk setiap Juz (ini bisa diganti dengan data real dari API)
    final juzData = _getJuzData(juzNumber);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to Juz detail
          final juzData = _getJuzData(juzNumber);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  JuzDetailPage(juzNumber: juzNumber, juzData: juzData),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Juz Number with star design
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: AppTheme.accentGreen.withValues(alpha: 0.2),
                    ),
                    Text(
                      juzNumber.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGreen,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Juz Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Juz $juzNumber',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      juzData['range']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Arabic Name and Download buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    juzData['arabic']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      fontFamily: 'Arabic',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Download button for Juz
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _showJuzDownloadDialog(juzNumber);
                      },
                      icon: const Icon(
                        Icons.download,
                        size: 16,
                        color: AppTheme.accentGreen,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, String> _getJuzData(int juzNumber) {
    // Data sederhana untuk setiap Juz
    final juzData = {
      1: {'range': 'Al-Fatihah 1 - Al-Baqarah 141', 'arabic': 'الم'},
      2: {'range': 'Al-Baqarah 142 - Al-Baqarah 252', 'arabic': 'سيقول'},
      3: {'range': 'Al-Baqarah 253 - Ali Imran 92', 'arabic': 'تلك الرسل'},
      4: {'range': 'Ali Imran 93 - An-Nisa 23', 'arabic': 'لن تنالوا'},
      5: {'range': 'An-Nisa 24 - An-Nisa 147', 'arabic': 'والمحصنات'},
      6: {'range': 'An-Nisa 148 - Al-Maidah 81', 'arabic': 'لا يحب الله'},
      7: {'range': 'Al-Maidah 82 - Al-An\'am 110', 'arabic': 'وإذا سمعوا'},
      8: {'range': 'Al-An\'am 111 - Al-A\'raf 87', 'arabic': 'ولو أننا'},
      9: {'range': 'Al-A\'raf 88 - Al-Anfal 40', 'arabic': 'قال الملأ'},
      10: {'range': 'Al-Anfal 41 - At-Tawbah 92', 'arabic': 'واعلموا'},
      11: {'range': 'At-Tawbah 93 - Hud 5', 'arabic': 'يعتذرون'},
      12: {'range': 'Hud 6 - Yusuf 52', 'arabic': 'وما من دابة'},
      13: {'range': 'Yusuf 53 - Ibrahim 52', 'arabic': 'وما أبرئ'},
      14: {'range': 'Al-Hijr 1 - An-Nahl 128', 'arabic': 'الر'},
      15: {'range': 'Al-Isra 1 - Al-Kahf 74', 'arabic': 'سبحان الذي'},
      16: {'range': 'Al-Kahf 75 - Taha 135', 'arabic': 'قال ألم'},
      17: {'range': 'Al-Anbiya 1 - Al-Hajj 78', 'arabic': 'اقترب'},
      18: {'range': 'Al-Mu\'minun 1 - Al-Furqan 20', 'arabic': 'قد أفلح'},
      19: {'range': 'Al-Furqan 21 - An-Naml 55', 'arabic': 'وقال الذين'},
      20: {'range': 'An-Naml 56 - Al-Ankabut 45', 'arabic': 'أمن خلق'},
      21: {'range': 'Al-Ankabut 46 - Al-Ahzab 30', 'arabic': 'اتل ما أوحي'},
      22: {'range': 'Al-Ahzab 31 - Ya-Sin 27', 'arabic': 'ومن يقنت'},
      23: {'range': 'Ya-Sin 28 - Az-Zumar 31', 'arabic': 'وما لي'},
      24: {'range': 'Az-Zumar 32 - Fussilat 46', 'arabic': 'فمن أظلم'},
      25: {'range': 'Fussilat 47 - Al-Jathiyah 37', 'arabic': 'إليه يرد'},
      26: {'range': 'Al-Ahqaf 1 - Adh-Dhariyat 30', 'arabic': 'حم'},
      27: {'range': 'Adh-Dhariyat 31 - Al-Hadid 29', 'arabic': 'قال فما'},
      28: {'range': 'Al-Mujadila 1 - At-Tahrim 12', 'arabic': 'قد سمع'},
      29: {'range': 'Al-Mulk 1 - Al-Mursalat 50', 'arabic': 'تبارك'},
      30: {'range': 'An-Naba 1 - An-Nas 6', 'arabic': 'عم يتساءلون'},
    };

    return juzData[juzNumber] ?? {'range': 'Unknown', 'arabic': ''};
  }

  void _showJuzDownloadDialog(int juzNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download Juz $juzNumber'),
        content: Text('Fitur download Juz $juzNumber akan segera tersedia'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkTab() {
    // Mock bookmark data - in real app, this would come from local storage/database
    final bookmarks = [
      {
        'type': 'surah',
        'name': 'Al-Fatihah',
        'arabic': 'الفاتحة',
        'info': 'Ayat 1-7 • Mekah',
        'lastRead': '2 jam yang lalu',
      },
      {
        'type': 'surah',
        'name': 'Al-Baqarah',
        'arabic': 'البقرة',
        'info': 'Ayat 255 • Madinah',
        'lastRead': '1 hari yang lalu',
      },
      {
        'type': 'juz',
        'name': 'Juz 1',
        'arabic': 'الم',
        'info': 'Al-Fatihah - Al-Baqarah 141',
        'lastRead': '3 hari yang lalu',
      },
    ];

    if (bookmarks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 80,
              color: AppTheme.onSurfaceVariant,
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada bookmark',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bookmark ayat atau surah favoritmu\nuntuk dibaca nanti',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return _buildBookmarkCard(bookmark);
      },
    );
  }

  Widget _buildBookmarkCard(Map<String, String> bookmark) {
    final isJuz = bookmark['type'] == 'juz';
    final iconColor = isJuz ? AppTheme.accentGreen : AppTheme.primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Membuka ${bookmark['name']}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Bookmark icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isJuz ? Icons.book : Icons.bookmark,
                  color: iconColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 16),

              // Bookmark Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bookmark['info']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Terakhir dibaca ${bookmark['lastRead']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Arabic Name and Options
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bookmark['arabic']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      fontFamily: 'Arabic',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Options menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'remove') {
                        _showRemoveBookmarkDialog(bookmark['name']!);
                      } else if (value == 'share') {
                        _shareBookmark(bookmark);
                      }
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 18),
                            SizedBox(width: 8),
                            Text('Bagikan'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoveBookmarkDialog(String bookmarkName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Bookmark'),
        content: Text(
          'Apakah Anda yakin ingin menghapus bookmark "$bookmarkName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bookmark "$bookmarkName" dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _shareBookmark(Map<String, String> bookmark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membagikan ${bookmark['name']}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildSurahCard(Surah surah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/surah-detail', arguments: surah);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Surah Number (with 8-pointed star design like in image)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 8-pointed star background
                    Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    ),
                    // Surah number
                    Text(
                      surah.nomor.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Surah Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Latin Name
                    Text(
                      surah.namaLatin,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Location and Ayahs Count
                    Row(
                      children: [
                        Text(
                          surah.tempatTurun.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ' | ${surah.jumlahAyat} AYAT',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arabic Name
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    surah.nama,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      fontFamily: 'Arabic',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Audio and Download buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Audio/Speaker button
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Play audio functionality
                            _showAudioPlayer(surah);
                          },
                          icon: const Icon(
                            Icons.volume_up,
                            size: 16,
                            color: AppTheme.accentGreen,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Download button
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildDownloadButton(surah),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton(Surah surah) {
    final downloadKey = '${surah.nomor}_download';
    final isDownloading = _downloadProgress.containsKey(downloadKey);
    final downloadData = _downloadProgress[downloadKey];

    if (isDownloading && downloadData != null) {
      if (downloadData.status == DownloadStatus.downloading) {
        return Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: downloadData.progress,
              strokeWidth: 2,
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryBlue,
              ),
            ),
            Text(
              '${(downloadData.progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        );
      } else if (downloadData.status == DownloadStatus.completed) {
        return IconButton(
          onPressed: () {
            _showDownloadedInfo(surah);
          },
          icon: const Icon(
            Icons.check_circle,
            size: 16,
            color: AppTheme.accentGreen,
          ),
          padding: EdgeInsets.zero,
        );
      }
    }

    return IconButton(
      onPressed: () {
        _showSheikhSelectionDialog(surah);
      },
      icon: const Icon(Icons.download, size: 16, color: AppTheme.primaryBlue),
      padding: EdgeInsets.zero,
    );
  }

  void _showAudioPlayer(Surah surah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(surah.namaLatin),
        content: const Text('Fitur audio player akan segera tersedia'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSheikhSelectionDialog(Surah surah) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isTablet = screenWidth > 600;
            final dialogWidth = isTablet ? 500.0 : screenWidth - 40;
            final maxHeight = MediaQuery.of(context).size.height * 0.8;

            return Container(
              width: dialogWidth,
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(isTablet ? 24 : 20),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.audiotrack,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pilih Qari',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                surah.namaLatin,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: isTablet ? 16 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Popular Sheikhs Section
                          Text(
                            'Qari Populer',
                            style: TextStyle(
                              color: AppTheme.onSurface,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: isTablet ? 16 : 12),

                          // Popular Sheikhs List
                          ...AudioDownloadService.getPopularSheikhs().map(
                            (sheikh) => _buildSheikhCard(
                              sheikh,
                              surah,
                              isPopular: true,
                              isTablet: isTablet,
                            ),
                          ),

                          SizedBox(height: isTablet ? 24 : 20),

                          // All Sheikhs Section
                          Text(
                            'Qari Lainnya',
                            style: TextStyle(
                              color: AppTheme.onSurface,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: isTablet ? 16 : 12),

                          // Other Sheikhs List
                          ...AudioDownloadService.getAllSheikhs()
                              .where((sheikh) => !sheikh.isPopular)
                              .map(
                                (sheikh) => _buildSheikhCard(
                                  sheikh,
                                  surah,
                                  isTablet: isTablet,
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSheikhCard(
    Sheikh sheikh,
    Surah surah, {
    bool isPopular = false,
    bool isTablet = false,
  }) {
    final cardPadding = isTablet ? 20.0 : 16.0;
    final fontSize = isTablet ? 18.0 : 16.0;
    final buttonHeight = isTablet ? 44.0 : 40.0;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPopular
            ? Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                width: 2,
              )
            : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          children: [
            // Sheikh Name and Popular Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          sheikh.name,
                          style: TextStyle(
                            color: AppTheme.onSurface,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            'POPULER',
                            style: TextStyle(
                              color: Colors.amber.shade700,
                              fontSize: isTablet ? 11 : 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (sheikh.arabicName.isNotEmpty) ...[
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      sheikh.arabicName,
                      style: TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: isTablet ? 15 : 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Download Button
            SizedBox(
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _startDownload(surah, sheikh);
                },
                icon: const Icon(Icons.download, size: 18),
                label: Text(
                  'Download',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isTablet ? 12 : 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startDownload(Surah surah, Sheikh sheikh) {
    final downloadKey = '${surah.nomor}_download';

    AudioDownloadService.downloadAudio(
      surah: surah,
      sheikh: sheikh,
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download gagal: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    ).listen((downloadData) {
      if (mounted) {
        setState(() {
          _downloadProgress[downloadKey] = downloadData;
        });

        if (downloadData.status == DownloadStatus.completed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Download Selesai!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${surah.namaLatin} - ${sheikh.name}'),
                  Text(
                    'Ukuran: ${AudioDownloadService.formatFileSize(downloadData.fileSize)}',
                  ),
                ],
              ),
              backgroundColor: AppTheme.accentGreen,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });

    // Show initial download started message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Memulai download ${surah.namaLatin} - ${sheikh.name}'),
        backgroundColor: AppTheme.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDownloadedInfo(Surah surah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audio Tersimpan'),
        content: Text(
          'Audio ${surah.namaLatin} telah tersimpan di perangkat Anda',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
