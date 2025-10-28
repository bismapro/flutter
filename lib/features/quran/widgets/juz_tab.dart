import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/data/models/quran/juz.dart';
import 'package:test_flutter/features/quran/pages/juz_detail_page.dart';

class JuzTab extends StatefulWidget {
  const JuzTab({super.key});

  @override
  State<JuzTab> createState() => _JuzTabState();
}

class _JuzTabState extends State<JuzTab> {
  List<Juz> _juzList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJuzData();
  }

  Future<void> _loadJuzData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load juz.json from assets
      final String jsonString = await rootBundle.loadString(
        'assets/quran/juz.json',
      );
      final List<dynamic> juzData = json.decode(jsonString);

      final List<Juz> juzList = juzData.map((item) {
        return Juz(
          number: item['juz'],
          startSurah: item['start']['surah_number'],
          startAyah: item['start']['ayah'],
          endSurah: item['end']['surah_number'],
          endAyah: item['end']['ayah'],
          startSurahName: item['start']['surah_name'],
          endSurahName: item['end']['surah_name'],
        );
      }).toList();

      if (mounted) {
        setState(() {
          _juzList = juzList;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading juz data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading juz data: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<int> _getTotalVersesInJuz(Juz juz) async {
    int total = 0;

    try {
      // If juz starts and ends in the same surah
      if (juz.startSurah == juz.endSurah) {
        total = juz.endAyah - juz.startAyah + 1;
      } else {
        // Count verses from first surah
        final firstSurahJson = await rootBundle.loadString(
          'assets/quran/surah/${juz.startSurah}.json',
        );
        final firstSurahData = json.decode(firstSurahJson);
        final firstSurahTotalAyat = firstSurahData['jumlahAyat'] as int;
        total += (firstSurahTotalAyat - juz.startAyah + 1);

        // Count verses from middle surahs (if any)
        for (
          int surahNum = juz.startSurah + 1;
          surahNum < juz.endSurah;
          surahNum++
        ) {
          final surahJson = await rootBundle.loadString(
            'assets/quran/surah/$surahNum.json',
          );
          final surahData = json.decode(surahJson);
          total += surahData['jumlahAyat'] as int;
        }

        // Count verses from last surah
        total += juz.endAyah;
      }
    } catch (e) {
      print('❌ Error calculating verses for juz ${juz.number}: $e');
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
                  style: TextStyle(
                    fontFamily: 'Poppins',
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
                    style: TextStyle(
                      fontFamily: 'Poppins',
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
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isTablet ? 14 : 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
