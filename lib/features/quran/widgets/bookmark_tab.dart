import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/connection/connection_provider.dart';
import 'package:test_flutter/features/quran/quran_provider.dart';
import 'package:test_flutter/features/quran/quran_state.dart';
import 'package:test_flutter/features/quran/services/quran_service.dart';
import 'package:test_flutter/features/quran/pages/surah_detail_page.dart';

class BookmarkTab extends ConsumerStatefulWidget {
  const BookmarkTab({super.key});

  @override
  ConsumerState<BookmarkTab> createState() => _BookmarkTabState();
}

class _BookmarkTabState extends ConsumerState<BookmarkTab> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Load progress on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProgress();
    });
  }

  Future<void> _loadProgress() async {
    // First load from local
    await ref.read(quranProvider.notifier).init();

    // Then try to sync from API (will fail silently if offline)
    final connectionState = ref.read(connectionProvider);
    if (connectionState.isOnline) {
      try {
        await ref.read(quranProvider.notifier).fetchTerakhirBaca();
      } catch (e) {
        print('📱 Offline mode: Using local storage');
      }
    } else {
      print('📱 No internet: Using local storage');
    }
  }

  Future<void> _refreshProgress() async {
    setState(() => _isRefreshing = true);

    final connectionState = ref.read(connectionProvider);

    if (!connectionState.isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('No internet connection')),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() => _isRefreshing = false);
      return;
    }

    try {
      await ref.read(quranProvider.notifier).fetchTerakhirBaca();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Progress updated'),
              ],
            ),
            backgroundColor: AppTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to update: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    final quranState = ref.watch(quranProvider);
    final connectionState = ref.watch(connectionProvider);
    final progress = quranState.progresBacaQuran;
    final isOffline = !connectionState.isOnline;

    return RefreshIndicator(
      onRefresh: _refreshProgress,
      color: AppTheme.accentGreen,
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop
              ? 32.0
              : isTablet
              ? 28.0
              : 24.0,
          vertical: isTablet ? 12 : 8,
        ),
        children: [
          // Header Card
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.accentGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.bookmark_rounded,
                    color: AppTheme.accentGreen,
                    size: isTablet ? 28 : 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Reading',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      Text(
                        'Continue where you left off',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 14 : 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isRefreshing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    onPressed: _refreshProgress,
                    icon: const Icon(Icons.refresh_rounded),
                    color: AppTheme.primaryBlue,
                    tooltip: 'Refresh',
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Status indicator - Watch dari ConnectionState
          if (isOffline)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Offline mode: Showing cached data',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Progress Content
          if (quranState.status == QuranStatus.loading && progress == null)
            _buildLoadingState(isTablet)
          else if (progress == null || progress.suratId == 0)
            _buildEmptyState(isTablet, isDesktop)
          else
            _buildProgressCard(progress, isTablet, isDesktop),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isTablet) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            CircularProgressIndicator(color: AppTheme.accentGreen),
            const SizedBox(height: 16),
            Text(
              'Loading progress...',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 15 : 14,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet, bool isDesktop) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: isDesktop
                    ? 64
                    : isTablet
                    ? 56
                    : 48,
                color: AppTheme.primaryBlue.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Reading Progress',
              style: GoogleFonts.poppins(
                fontSize: isDesktop
                    ? 22
                    : isTablet
                    ? 20
                    : 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start reading to bookmark your progress',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 15 : 14,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(dynamic progress, bool isTablet, bool isDesktop) {
    final surahId = progress.suratId as int;
    final ayahNumber = progress.ayat as int;
    final surah = QuranService.getSurahById(surahId);

    if (surah == null) return _buildEmptyState(isTablet, isDesktop);

    final surahName = QuranService.getSurahNameLatin(surahId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahDetailPage(
              surah: surah.copyWith(namaLatin: surahName),
              allSurahs: QuranService.getAllSurahs(),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 22 : 20),
          border: Border.all(
            color: AppTheme.accentGreen.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentGreen.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(
            isDesktop
                ? 24
                : isTablet
                ? 22
                : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Surah Number Badge
                  Container(
                    width: isDesktop
                        ? 56
                        : isTablet
                        ? 52
                        : 48,
                    height: isDesktop
                        ? 56
                        : isTablet
                        ? 52
                        : 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentGreen,
                          AppTheme.accentGreen.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                    ),
                    child: Center(
                      child: Text(
                        '$surahId',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop
                              ? 22
                              : isTablet
                              ? 20
                              : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 18 : 16),

                  // Surah Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surahName,
                          style: GoogleFonts.poppins(
                            fontSize: isDesktop
                                ? 20
                                : isTablet
                                ? 19
                                : 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Ayah $ayahNumber',
                                style: GoogleFonts.poppins(
                                  fontSize: isTablet ? 13 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentGreen,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${surah.jumlahAyat} Ayat',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 14 : 13,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arabic Name
                  Text(
                    surah.nama,
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

              const SizedBox(height: 20),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahDetailPage(
                          surah: surah.copyWith(namaLatin: surahName),
                          allSurahs: QuranService.getAllSurahs(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    'Continue Reading',
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
