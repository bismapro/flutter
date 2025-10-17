import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/features/quran/quran_provider.dart';

class AyahCard extends ConsumerWidget {
  final int surahNumber;
  final int verseNumber;
  final String arabicText;
  final String translation;
  final String verseEndSymbol;
  final VoidCallback onPlayVerse;
  final bool isTablet;
  final bool isDesktop;
  final bool isPlaying;

  const AyahCard({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
    required this.arabicText,
    required this.translation,
    required this.verseEndSymbol,
    required this.onPlayVerse,
    this.isTablet = false,
    this.isDesktop = false,
    this.isPlaying = false,
  });

  void _showBookmarkModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentGreen.withOpacity(0.2),
                    AppTheme.accentGreen.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_rounded,
                size: 32,
                color: AppTheme.accentGreen,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'Bookmark This Ayah?',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Mark Surah $surahNumber, Ayah $verseNumber as your last reading position',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      // Show loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text('Saving bookmark...'),
                            ],
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: AppTheme.primaryBlue,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      // Save bookmark
                      await ref
                          .read(quranProvider.notifier)
                          .addProgresQuran(
                            suratId: surahNumber.toString(),
                            ayat: verseNumber.toString(),
                          );

                      // Show success
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Surah $surahNumber, Ayah $verseNumber bookmarked!',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppTheme.accentGreen,
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'View',
                              textColor: Colors.white,
                              onPressed: () {
                                // Navigate to bookmark tab
                                DefaultTabController.of(context)?.animateTo(2);
                              },
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Bookmark',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quranState = ref.watch(quranProvider);

    // ✅ FIX: Check both surahNumber AND verseNumber
    final isBookmarked =
        quranState.progresBacaQuran?.suratId == surahNumber &&
        quranState.progresBacaQuran?.ayat == verseNumber;

    // Debug log
    if (quranState.progresBacaQuran != null) {
      print('🔖 Bookmark check:');
      print('   Current: Surah $surahNumber, Ayah $verseNumber');
      print(
        '   Bookmarked: Surah ${quranState.progresBacaQuran?.suratId}, Ayah ${quranState.progresBacaQuran?.ayat}',
      );
      print('   Is Bookmarked: $isBookmarked');
    }

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      padding: EdgeInsets.all(
        isDesktop
            ? 24
            : isTablet
            ? 22
            : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 22 : 20),
        border: Border.all(
          color: isBookmarked
              ? AppTheme.accentGreen
              : isPlaying
              ? AppTheme.accentGreen.withOpacity(0.5)
              : AppTheme.primaryBlue.withOpacity(0.1),
          width: isBookmarked
              ? 2
              : isPlaying
              ? 2
              : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isBookmarked
                ? AppTheme.accentGreen.withOpacity(0.2)
                : isPlaying
                ? AppTheme.accentGreen.withOpacity(0.15)
                : AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah number badge and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 14 : 12,
                  vertical: isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isBookmarked
                        ? [
                            AppTheme.accentGreen.withOpacity(0.2),
                            AppTheme.accentGreen.withOpacity(0.1),
                          ]
                        : isPlaying
                        ? [
                            AppTheme.accentGreen.withOpacity(0.2),
                            AppTheme.accentGreen.withOpacity(0.1),
                          ]
                        : [
                            AppTheme.primaryBlue.withOpacity(0.15),
                            AppTheme.accentGreen.withOpacity(0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBookmarked
                          ? Icons.bookmark
                          : isPlaying
                          ? Icons.graphic_eq
                          : Icons.circle,
                      size: isTablet ? 9 : 8,
                      color: isBookmarked
                          ? AppTheme.accentGreen
                          : isPlaying
                          ? AppTheme.accentGreen
                          : AppTheme.primaryBlue,
                    ),
                    SizedBox(width: isTablet ? 10 : 8),
                    Text(
                      isBookmarked
                          ? 'Bookmarked • $verseNumber'
                          : 'Ayat $verseNumber',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w600,
                        color: isBookmarked
                            ? AppTheme.accentGreen
                            : isPlaying
                            ? AppTheme.accentGreen
                            : AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                children: [
                  // Bookmark button
                  Container(
                    width: isTablet ? 42 : 40,
                    height: isTablet ? 42 : 40,
                    decoration: BoxDecoration(
                      color: isBookmarked
                          ? AppTheme.accentGreen.withOpacity(0.15)
                          : AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                    ),
                    child: IconButton(
                      onPressed: () => _showBookmarkModal(context, ref),
                      icon: Icon(
                        isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border_rounded,
                      ),
                      iconSize: isTablet ? 22 : 20,
                      color: isBookmarked
                          ? AppTheme.accentGreen
                          : AppTheme.primaryBlue,
                      padding: EdgeInsets.zero,
                      tooltip: isBookmarked
                          ? 'Bookmarked'
                          : 'Bookmark this ayah',
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: isTablet ? 20 : 16),

          // Arabic Text with end symbol
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  arabicText,
                  style: GoogleFonts.amiriQuran(
                    fontSize: isDesktop
                        ? 30
                        : isTablet
                        ? 28
                        : 26,
                    height: 2.0,
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                verseEndSymbol,
                style: GoogleFonts.amiriQuran(
                  fontSize: isDesktop
                      ? 30
                      : isTablet
                      ? 28
                      : 26,
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 20 : 16),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.0),
                  AppTheme.primaryBlue.withOpacity(0.2),
                  AppTheme.primaryBlue.withOpacity(0.0),
                ],
              ),
            ),
          ),

          SizedBox(height: isTablet ? 20 : 16),

          // Indonesian translation
          Text(
            translation,
            style: TextStyle(
              fontSize: isDesktop
                  ? 17
                  : isTablet
                  ? 16
                  : 15,
              height: 1.7,
              color: AppTheme.onSurface.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
