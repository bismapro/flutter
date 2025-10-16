import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_flutter/app/theme.dart';

class AyahCard extends StatelessWidget {
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
    required this.verseNumber,
    required this.arabicText,
    required this.translation,
    required this.verseEndSymbol,
    required this.onPlayVerse,
    this.isTablet = false,
    this.isDesktop = false,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
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
          color: isPlaying
              ? AppTheme.accentGreen
              : AppTheme.primaryBlue.withOpacity(0.1),
          width: isPlaying ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlaying
                ? AppTheme.accentGreen.withOpacity(0.2)
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
          // Ayah number badge
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
                    colors: isPlaying
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
                      isPlaying ? Icons.graphic_eq : Icons.circle,
                      size: isTablet ? 9 : 8,
                      color: isPlaying
                          ? AppTheme.accentGreen
                          : AppTheme.primaryBlue,
                    ),
                    SizedBox(width: isTablet ? 10 : 8),
                    Text(
                      'Ayat $verseNumber',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w600,
                        color: isPlaying
                            ? AppTheme.accentGreen
                            : AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              // Play verse button
              Container(
                width: isTablet ? 42 : 40,
                height: isTablet ? 42 : 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                ),
                child: IconButton(
                  onPressed: onPlayVerse,
                  icon: const Icon(Icons.play_arrow_rounded),
                  iconSize: isTablet ? 22 : 20,
                  color: AppTheme.accentGreen,
                  padding: EdgeInsets.zero,
                ),
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
