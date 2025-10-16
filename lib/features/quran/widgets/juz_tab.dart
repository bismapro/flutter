import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/data/models/quran/juz.dart';
import 'package:test_flutter/features/quran/pages/juz_detail_page.dart';

class JuzTab extends StatefulWidget {
  const JuzTab({super.key});

  @override
  State<JuzTab> createState() => _JuzTabState();
}

class _JuzTabState extends State<JuzTab> {
  final List<Juz> _juzList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJuzData();
  }

  void _loadJuzData() {
    setState(() {
      _isLoading = true;
    });

    try {
      for (int i = 1; i <= quran.totalJuzCount; i++) {
        final juzData = quran.getSurahAndVersesFromJuz(i);

        // Get first and last surah-verse from juz
        final firstEntry = juzData.entries.first;
        final lastEntry = juzData.entries.last;

        final firstSurah = firstEntry.key;
        final firstVerse = firstEntry.value.first;

        final lastSurah = lastEntry.key;
        final lastVerse = lastEntry.value.last;

        _juzList.add(
          Juz(
            number: i,
            startSurah: firstSurah,
            startAyah: firstVerse,
            endSurah: lastSurah,
            endAyah: lastVerse,
            startSurahName: quran.getSurahName(firstSurah),
            endSurahName: quran.getSurahName(lastSurah),
          ),
        );
      }
    } catch (e) {
      print('Error loading juz data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _getTotalVersesInJuz(int juzNumber) {
    final juzData = quran.getSurahAndVersesFromJuz(juzNumber);
    int total = 0;
    for (var verseRange in juzData.values) {
      // Calculate actual number of verses from range [start, end]
      final startVerse = verseRange.first;
      final endVerse = verseRange.last;
      total += (endVerse - startVerse + 1);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 32
            : isTablet
            ? 28
            : 24,
        vertical: isTablet ? 12 : 8,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: _juzList.length,
      itemBuilder: (context, index) {
        final juz = _juzList[index];
        return _buildJuzItem(juz, isTablet, isDesktop);
      },
    );
  }

  Widget _buildJuzItem(Juz juz, bool isTablet, bool isDesktop) {
    final totalVerses = _getTotalVersesInJuz(juz.number);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JuzDetailPage(juz: juz, allJuz: _juzList),
          ),
        );
      },
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
        padding: EdgeInsets.all(isTablet ? 18 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Juz Number Badge
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
                    AppTheme.primaryBlue.withOpacity(0.1),
                    AppTheme.accentGreen.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${juz.number}',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop
                        ? 22
                        : isTablet
                        ? 20
                        : 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
            SizedBox(width: isTablet ? 18 : 16),

            // Juz Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Juz ${juz.number}',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop
                          ? 18
                          : isTablet
                          ? 17
                          : 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${juz.startSurahName} (${juz.startAyah}) - ${juz.endSurahName} (${juz.endAyah})',
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 14 : 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalVerses Ayat',
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 13 : 12,
                      color: AppTheme.accentGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.accentGreen,
                size: isTablet ? 20 : 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
