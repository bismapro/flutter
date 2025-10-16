import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/data/models/quran/surah.dart';
import 'package:test_flutter/features/quran/services/quran_audio_service.dart';
import 'package:test_flutter/features/quran/services/quran_download_manager.dart';
import 'package:test_flutter/features/quran/widgets/ayah_card.dart';
import 'package:test_flutter/features/quran/widgets/modern_audio_player.dart';
import 'package:test_flutter/features/quran/widgets/download_audio_sheet.dart';

class SurahDetailPage extends StatefulWidget {
  final Surah surah;
  final List<Surah> allSurahs;

  const SurahDetailPage({
    super.key,
    required this.surah,
    this.allSurahs = const [],
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage>
    with SingleTickerProviderStateMixin {
  bool _isLoadingAudio = false;
  bool _isDownloaded = false;
  int _selectedQoriId = 1;
  int _currentPlayingVerse = 0;
  String? _qariName;
  int _currentSurahIndex = 0;

  late TabController _tabController;
  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};

  bool get _showTabs =>
      widget.allSurahs.isNotEmpty && widget.allSurahs.length > 1;

  @override
  void initState() {
    super.initState();

    // Debug: Print allSurahs info
    print('📋 allSurahs length: ${widget.allSurahs.length}');
    print('📋 _showTabs: $_showTabs');

    if (_showTabs) {
      final initialIndex = widget.allSurahs.indexWhere(
        (s) => s.nomor == widget.surah.nomor,
      );

      _currentSurahIndex = initialIndex >= 0 ? initialIndex : 0;

      print('📖 Initializing with surah: ${widget.surah.namaLatin}');
      print('📖 Initial index: $_currentSurahIndex');
      print('📖 Total surahs: ${widget.allSurahs.length}');

      _tabController = TabController(
        length: widget.allSurahs.length,
        vsync: this,
        initialIndex: _currentSurahIndex,
      );
      _pageController = PageController(initialPage: _currentSurahIndex);

      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          _pageController.animateToPage(
            _tabController.index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    } else {
      print('📖 Single surah mode: ${widget.surah.namaLatin}');
      print('📖 Reason: allSurahs.length = ${widget.allSurahs.length}');
    }

    _loadSelectedQori();
    _checkDownloadStatus();
    _listenToCurrentVerse();
  }

  @override
  void dispose() {
    QuranAudioService.stop();
    if (_showTabs) {
      _tabController.dispose();
      _pageController.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Surah get _currentSurah =>
      _showTabs ? widget.allSurahs[_currentSurahIndex] : widget.surah;

  Future<void> _loadSelectedQori() async {
    final prefs = await SharedPreferences.getInstance();
    final savedQoriId = prefs.getInt('selected_qori_${_currentSurah.nomor}');

    if (savedQoriId != null) {
      setState(() {
        _selectedQoriId = savedQoriId;
      });
      print(
        '📖 Loaded saved qori ID: $savedQoriId for ${_currentSurah.namaLatin}',
      );
    }

    await _checkDownloadStatus();
  }

  Future<void> _saveSelectedQori(int qoriId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_qori_${_currentSurah.nomor}', qoriId);
    print('💾 Saved qori ID: $qoriId for ${_currentSurah.namaLatin}');
  }

  Future<void> _checkDownloadStatus() async {
    final isDownloaded = await QuranDownloadManager.isDownloaded(
      _currentSurah.nomor,
      _selectedQoriId,
    );

    if (mounted) {
      setState(() {
        _isDownloaded = isDownloaded;
      });
    }

    if (isDownloaded) {
      final localPath = await QuranDownloadManager.getLocalPath(
        _currentSurah.nomor,
        _selectedQoriId,
      );

      final file = File(localPath);
      final exists = await file.exists();

      if (!exists) {
        setState(() {
          _isDownloaded = false;
          _qariName = null;
        });
      } else {
        final qariName = await QuranDownloadManager.getQoriName(
          _selectedQoriId,
        );
        setState(() {
          _qariName = qariName;
        });
        print('✅ Loaded qari name: $qariName');
      }
    }
  }

  void _listenToCurrentVerse() {
    QuranAudioService.currentVerseStream.listen((verseNumber) {
      if (mounted && verseNumber != _currentPlayingVerse) {
        setState(() {
          _currentPlayingVerse = verseNumber;
        });
        _scrollToVerse(verseNumber);
      }
    });
  }

  void _scrollToVerse(int verseNumber) {
    final key = _verseKeys[verseNumber];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    }
  }

  Future<void> _playPause() async {
    try {
      final isCurrentlyPlaying = QuranAudioService.isPlaying;

      if (isCurrentlyPlaying) {
        await QuranAudioService.pause();
        return;
      }

      setState(() => _isLoadingAudio = true);

      if (_isDownloaded) {
        final localPath = await QuranDownloadManager.getLocalPath(
          _currentSurah.nomor,
          _selectedQoriId,
        );

        final qoriName =
            await QuranDownloadManager.getQoriName(_selectedQoriId) ??
            'Unknown Qori';

        await QuranAudioService.playFromFile(
          localPath,
          _currentSurah.namaLatin,
          qoriName,
          _currentSurah.nama,
          _currentSurah.jumlahAyat,
        );
      } else {
        _showDownloadDialog();
        setState(() => _isLoadingAudio = false);
        return;
      }
    } catch (e) {
      print('❌ Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAudio = false);
    }
  }

  void _showDownloadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DownloadAudioSheet(
        surah: _currentSurah,
        selectedQoriId: _selectedQoriId,
        onDownloadComplete: (int qoriId) async {
          setState(() {
            _selectedQoriId = qoriId;
          });
          await _saveSelectedQori(qoriId);
          await _checkDownloadStatus();
        },
      ),
    );
  }

  Future<void> _seekTo(double value) async {
    final duration = QuranAudioService.duration;
    final position = Duration(
      milliseconds: (value * duration.inMilliseconds).round(),
    );
    await QuranAudioService.seek(position);
  }

  Future<void> _deleteDownload() async {
    final success = await QuranDownloadManager.deleteSurah(
      _currentSurah.nomor,
      _selectedQoriId,
    );

    if (success && mounted) {
      setState(() {
        _isDownloaded = false;
        _qariName = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Download deleted successfully'),
            ],
          ),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentSurahIndex = index;
    });
    _tabController.animateTo(index);

    _loadSelectedQori();
    _checkDownloadStatus();

    print('📖 Changed to surah: ${_currentSurah.namaLatin}');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withOpacity(0.03),
              AppTheme.backgroundWhite,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isTablet, isDesktop),
              if (_showTabs) _buildTabBar(),
              Expanded(
                child: _showTabs
                    ? PageView.builder(
                        controller: _pageController,
                        itemCount: widget.allSurahs.length,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) {
                          final currentSurah = widget.allSurahs[index];
                          return _buildAyahsList(
                            currentSurah,
                            isTablet,
                            isDesktop,
                          );
                        },
                      )
                    : _buildAyahsList(_currentSurah, isTablet, isDesktop),
              ),
              ModernAudioPlayer(
                isLoading: _isLoadingAudio,
                onPlayPause: _playPause,
                onSeek: _seekTo,
                isDownloaded: _isDownloaded,
                onDownload: _showDownloadDialog,
                onDelete: _deleteDownload,
                qariName: _qariName,
                surahName: _currentSurah.namaLatin,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 14 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop
                ? 48
                : isTablet
                ? 44
                : 40,
            height: isDesktop
                ? 48
                : isTablet
                ? 44
                : 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.accentGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppTheme.primaryBlue,
              iconSize: isTablet ? 20 : 18,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _currentSurah.namaLatin,
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop
                              ? 22
                              : isTablet
                              ? 21
                              : 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (_isDownloaded) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.download_done_rounded,
                              size: 14,
                              color: AppTheme.accentGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Downloaded',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${_currentSurah.jumlahAyat} Ayat • ${_currentSurah.tempatTurun == 'Mekah' ? 'Makkiyah' : 'Madaniyyah'}',
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 14 : 13,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _currentSurah.nama,
            style: GoogleFonts.amiriQuran(
              fontSize: isDesktop
                  ? 28
                  : isTablet
                  ? 26
                  : 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppTheme.accentGreen,
        indicatorWeight: 3,
        labelColor: AppTheme.primaryBlue,
        unselectedLabelColor: AppTheme.onSurfaceVariant,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start, // ← Add this for better scrolling
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        tabs: widget.allSurahs.map((surah) {
          return Tab(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min, // ← Important for centering
                mainAxisAlignment: MainAxisAlignment.center, // ← Center content
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.1),
                          AppTheme.accentGreen.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${surah.nomor}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(surah.namaLatin),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAyahsList(Surah surah, bool isTablet, bool isDesktop) {
    final totalVerses = quran.getVerseCount(surah.nomor);

    _verseKeys.clear();
    for (int i = 1; i <= totalVerses; i++) {
      _verseKeys[i] = GlobalKey();
    }

    return ListView.builder(
      key: ValueKey('surah_${surah.nomor}'),
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20,
        vertical: isTablet ? 12 : 8,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: totalVerses,
      itemBuilder: (context, index) {
        final verseNumber = index + 1;
        final arabicText = quran.getVerse(
          surah.nomor,
          verseNumber,
          verseEndSymbol: false,
        );
        final translation = quran.getVerseTranslation(
          surah.nomor,
          verseNumber,
          translation: quran.Translation.indonesian,
        );
        final verseEndSymbol = quran.getVerseEndSymbol(verseNumber);
        final isCurrentlyPlaying = _currentPlayingVerse == verseNumber;

        return AyahCard(
          key: _verseKeys[verseNumber],
          verseNumber: verseNumber,
          arabicText: arabicText,
          translation: translation,
          verseEndSymbol: verseEndSymbol,
          onPlayVerse: () {},
          isTablet: isTablet,
          isDesktop: isDesktop,
          isPlaying: isCurrentlyPlaying,
        );
      },
    );
  }
}
