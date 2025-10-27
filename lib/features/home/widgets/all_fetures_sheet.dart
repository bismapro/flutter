import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';

class AllFeaturesSheet extends StatelessWidget {
  const AllFeaturesSheet({super.key});

  // semua ukuran/kolom dihitung pakai ResponsiveHelper
  int _gridColumns(BuildContext c) {
    final w = ResponsiveHelper.getScreenWidth(c);
    if (w < 360) return 3;
    if (w < ResponsiveHelper.mediumScreenSize) return 4; // <600
    if (w < ResponsiveHelper.largeScreenSize) return 5; // <900
    return 6;
  }

  double _hpad(BuildContext c) {
    if (ResponsiveHelper.isExtraLargeScreen(c)) return 48;
    if (ResponsiveHelper.isLargeScreen(c)) return 32;
    return ResponsiveHelper.getScreenWidth(c) * 0.05;
  }

  double _scale(BuildContext c) {
    if (ResponsiveHelper.isSmallScreen(c)) return .9;
    if (ResponsiveHelper.isMediumScreen(c)) return 1.0;
    if (ResponsiveHelper.isLargeScreen(c)) return 1.1;
    return 1.2;
  }

  double _px(BuildContext c, double base) => base * _scale(c);
  double _t(BuildContext c, double base) =>
      ResponsiveHelper.adaptiveTextSize(c, base);

  double _initialSheetSize(BuildContext c) {
    final h = ResponsiveHelper.getScreenHeight(c);
    if (ResponsiveHelper.isSmallScreen(c)) return 0.88;
    if (ResponsiveHelper.isMediumScreen(c)) return h < 700 ? 0.82 : 0.72;
    if (ResponsiveHelper.isLargeScreen(c)) return 0.66;
    return 0.6;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetSize(context),
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _hpad(context),
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Features',
                      style: TextStyle(
                        fontSize: _t(context, 20),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.grey[600],
                      iconSize: _px(context, 24),
                      padding: EdgeInsets.all(_px(context, 8)),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Grid of features
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: _hpad(context),
                    vertical: 16.0,
                  ),
                  children: [
                    // Grid fitur di bawahnya
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: _gridColumns(context),
                      mainAxisSpacing: _px(context, 20),
                      crossAxisSpacing: _px(context, 16),
                      childAspectRatio: 0.95,
                      children: _buildFeatureItems(context),
                    ),

                    // Bagian Syahadat di atas
                    _buildSyahadatSection(context),
                    SizedBox(height: _px(context, 32)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Tambahkan method baru untuk Syahadat Section
  Widget _buildSyahadatSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(_px(context, 8)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentGreen.withValues(alpha: 0.15),
                    AppTheme.primaryBlue.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                FlutterIslamicIcons.solidKaaba,
                color: AppTheme.accentGreen,
                size: _px(context, 20),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Dua Kalimat Syahadat',
              style: TextStyle(
                fontSize: _t(context, 20),
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: _px(context, 16)),

        // Syahadat Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentGreen.withValues(alpha: 0.05),
                AppTheme.primaryBlue.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentGreen.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentGreen.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
                spreadRadius: -3,
              ),
            ],
          ),
          child: Column(
            children: [
              // Syahadat Pertama
              _buildSyahadatCard(
                context,
                number: '1',
                title: 'Syahadat Pertama (Tauhid)',
                arabicText: 'أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللهُ',
                transliteration: 'Asyhadu an laa ilaaha illallah',
                translation: 'Aku bersaksi bahwa tidak ada Tuhan selain Allah',
                isFirst: true,
              ),

              // Divider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _px(context, 20)),
                child: Divider(
                  color: AppTheme.accentGreen.withValues(alpha: 0.2),
                  thickness: 1,
                ),
              ),

              // Syahadat Kedua
              _buildSyahadatCard(
                context,
                number: '2',
                title: 'Syahadat Kedua (Risalah)',
                arabicText: 'أَشْهَدُ أَنَّ مُحَمَّدًا رَسُوْلُ اللهُ',
                transliteration: 'Wa asyhadu anna Muhammadar Rasulullah',
                translation:
                    'Dan aku bersaksi bahwa Muhammad adalah utusan Allah',
                isFirst: false,
              ),
            ],
          ),
        ),

        SizedBox(height: _px(context, 12)),

        // Info footer
        Container(
          padding: EdgeInsets.all(_px(context, 12)),
          decoration: BoxDecoration(
            color: AppTheme.accentGreen.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentGreen.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.accentGreen,
                size: _px(context, 18),
              ),
              SizedBox(width: _px(context, 8)),
              Expanded(
                child: Text(
                  'Membaca syahadat adalah rukun Islam yang pertama',
                  style: TextStyle(
                    fontSize: _t(context, 12),
                    color: AppTheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyahadatCard(
    BuildContext context, {
    required String number,
    required String title,
    required String arabicText,
    required String transliteration,
    required String translation,
    required bool isFirst,
  }) {
    return Container(
      padding: EdgeInsets.all(_px(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge and title
          Row(
            children: [
              Container(
                width: _px(context, 32),
                height: _px(context, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentGreen,
                      AppTheme.accentGreen.withValues(alpha: 0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _t(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: _px(context, 12)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: _t(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _px(context, 16)),

          // Arabic text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(_px(context, 16)),
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
            child: Text(
              arabicText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _t(context, 24),
                fontWeight: FontWeight.w600,
                color: AppTheme.accentGreen,
                height: 2.0,
                fontFamily: 'Arabic', // You can add Arabic font if needed
              ),
            ),
          ),
          SizedBox(height: _px(context, 12)),

          // Transliteration
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: _px(context, 12),
              vertical: _px(context, 8),
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.translate_rounded,
                  size: _px(context, 16),
                  color: AppTheme.primaryBlue,
                ),
                SizedBox(width: _px(context, 8)),
                Expanded(
                  child: Text(
                    transliteration,
                    style: TextStyle(
                      fontSize: _t(context, 14),
                      fontStyle: FontStyle.italic,
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: _px(context, 8)),

          // Translation
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: _px(context, 12),
              vertical: _px(context, 8),
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: _px(context, 16),
                  color: AppTheme.accentGreen,
                ),
                SizedBox(width: _px(context, 8)),
                Expanded(
                  child: Text(
                    translation,
                    style: TextStyle(
                      fontSize: _t(context, 13),
                      color: AppTheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureItems(BuildContext context) {
    final features = [
      _FeatureData(
        FlutterIslamicIcons.quran2,
        'Al-Quran',
        AppTheme.accentGreen,
        '/quran',
      ),
      _FeatureData(
        FlutterIslamicIcons.prayingPerson,
        'Sholat',
        AppTheme.accentGreen,
        '/sholat',
      ),
      _FeatureData(
        FlutterIslamicIcons.ramadan,
        'Puasa',
        AppTheme.accentGreen,
        '/puasa',
      ),
      _FeatureData(
        FlutterIslamicIcons.qibla,
        'Qibla',
        AppTheme.accentGreen,
        '/qibla-compass',
      ),
      _FeatureData(
        FlutterIslamicIcons.zakat,
        'Sedekah',
        AppTheme.accentGreen,
        '/zakat',
      ),
      _FeatureData(
        FlutterIslamicIcons.family,
        'Monitoring',
        AppTheme.accentGreen,
        '/monitoring',
      ),
      _FeatureData(
        FlutterIslamicIcons.prayer,
        'Tahajud Challenge',
        AppTheme.accentGreen,
        '/tahajud',
      ),
      _FeatureData(Icons.article, 'Artikel', AppTheme.accentGreen, '/article'),
    ];

    return features.map((f) => _buildFeatureItem(context, f)).toList();
  }

  Widget _buildFeatureItem(BuildContext context, _FeatureData feature) {
    final box = _px(context, 56);
    final icon = _px(context, 28);
    final labelSize = _t(context, 11);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (feature.route != null) {
          Navigator.pushNamed(context, feature.route!);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: box,
            height: box,
            decoration: BoxDecoration(
              color: feature.color,
              borderRadius: BorderRadius.circular(_px(context, 16)),
              boxShadow: [
                BoxShadow(
                  color: feature.color.withValues(alpha: .3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(feature.icon, color: Colors.white, size: icon),
          ),
          SizedBox(height: _px(context, 8)),
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _px(context, 2)),
              child: Text(
                feature.label,
                style: TextStyle(
                  fontSize: labelSize,
                  color: const Color(0xFF212121),
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;

  const _FeatureData(this.icon, this.label, this.color, this.route);
}
