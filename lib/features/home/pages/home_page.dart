import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/core/widgets/menu/custom_bottom_app_bar.dart';
import 'package:test_flutter/features/komunitas/pages/komunitas_page.dart';
import 'package:test_flutter/features/monitoring/pages/monitoring_page.dart';
import 'package:test_flutter/features/quran/pages/quran_page.dart';
import 'package:test_flutter/features/sholat/pages/sholat_page.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import '../../../app/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeTabContent(),
    SholatPage(),
    QuranPage(),
    MonitoringPage(),
    KomunitasPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _currentIndex,
        onTabSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class HomeTabContent extends ConsumerStatefulWidget {
  const HomeTabContent({super.key});

  @override
  ConsumerState<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends ConsumerState<HomeTabContent> {
  // ---------- tiny helpers (dibangun di atas ResponsiveHelper) ----------
  double _scaleFactor(BuildContext context) {
    if (ResponsiveHelper.isSmallScreen(context)) return .9;
    if (ResponsiveHelper.isMediumScreen(context)) return 1.0;
    if (ResponsiveHelper.isLargeScreen(context)) return 1.1;
    return 1.2; // extra large
  }

  double _t(BuildContext c, double base) =>
      ResponsiveHelper.adaptiveTextSize(c, base);

  double _px(BuildContext c, double base) => base * _scaleFactor(c);

  double _icon(BuildContext c, double base) => base * _scaleFactor(c);

  double _hpad(BuildContext c) {
    if (ResponsiveHelper.isExtraLargeScreen(c)) return 48;
    if (ResponsiveHelper.isLargeScreen(c)) return 32;
    return ResponsiveHelper.getScreenWidth(c) * 0.04; // ~16 di ponsel normal
  }

  double _contentMaxWidth(BuildContext c) {
    if (ResponsiveHelper.isExtraLargeScreen(c)) return 980;
    if (ResponsiveHelper.isLargeScreen(c)) return 820;
    return double.infinity;
  }

  bool _isDesktop(BuildContext c) =>
      ResponsiveHelper.isLargeScreen(c) ||
      ResponsiveHelper.isExtraLargeScreen(c);

  void _showAllFeaturesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AllFeaturesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
              ),
            ),
          ),

          // Top section
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _hpad(context),
                    vertical: _px(context, 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '9 Ramadhan 1444 H',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _t(context, 16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: _px(context, 6)),
                            Text(
                              'Jakarta, Indonesia',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: _t(context, 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: Container(
                          padding: EdgeInsets.all(_px(context, 8)),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: _icon(context, 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: _px(context, 18)),

                // Current prayer time
                Text(
                  '04:41',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _t(context, 56),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Fajr 3 hour 9 min left',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _t(context, 16),
                  ),
                ),

                SizedBox(height: _px(context, 28)),

                // Prayer times row (auto horizontal scroll jika super sempit)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _hpad(context)),
                  child: _ResponsivePrayerRow(
                    itemHeight: _px(context, 100),
                    children: [
                      _buildPrayerTimeWidget(
                        context,
                        'Fajr',
                        '04:41',
                        Icons.nightlight_round,
                        true,
                      ),
                      _buildPrayerTimeWidget(
                        context,
                        'Dzuhr',
                        '12:00',
                        Icons.wb_sunny_rounded,
                        false,
                      ),
                      _buildPrayerTimeWidget(
                        context,
                        'Asr',
                        '15:14',
                        Icons.wb_twilight_rounded,
                        false,
                      ),
                      _buildPrayerTimeWidget(
                        context,
                        'Maghrib',
                        '18:02',
                        Icons.wb_sunny_outlined,
                        false,
                      ),
                      _buildPrayerTimeWidget(
                        context,
                        'Isha',
                        '19:11',
                        Icons.dark_mode_rounded,
                        false,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: _px(context, 20)),
              ],
            ),
          ),

          // Bottom sheet
          LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              final initial = h < 680 ? 0.52 : (h < 800 ? 0.48 : 0.45);
              final max = _isDesktop(context) ? 0.9 : 0.85;

              return DraggableScrollableSheet(
                initialChildSize: initial,
                minChildSize: initial,
                maxChildSize: max,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundWhite,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Handle bar
                        Container(
                          margin: const EdgeInsets.only(top: 16, bottom: 12),
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryBlue.withValues(alpha: 0.3),
                                AppTheme.accentGreen.withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),

                        // Content (max width on tablet/desktop)
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: _contentMaxWidth(context),
                              ),
                              child: ListView(
                                controller: scrollController,
                                padding: EdgeInsets.symmetric(
                                  horizontal: _hpad(context),
                                  vertical: _px(context, 12),
                                ),
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  // Quick Access header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppTheme.primaryBlue
                                                      .withValues(alpha: 0.1),
                                                  AppTheme.accentGreen
                                                      .withValues(alpha: 0.1),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.apps_rounded,
                                              color: AppTheme.primaryBlue,
                                              size: _icon(context, 24),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Quick Access',
                                            style: TextStyle(
                                              fontSize: _t(context, 20),
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.onSurface,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _showAllFeaturesSheet(context),
                                        icon: Icon(
                                          Icons.grid_view_rounded,
                                          size: _icon(context, 18),
                                          color: AppTheme.primaryBlue,
                                        ),
                                        label: Text(
                                          'See All',
                                          style: TextStyle(
                                            color: AppTheme.primaryBlue,
                                            fontWeight: FontWeight.w600,
                                            fontSize: _t(context, 14),
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: _px(context, 12),
                                            vertical: _px(context, 8),
                                          ),
                                          backgroundColor: AppTheme.primaryBlue
                                              .withValues(alpha: 0.1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: _px(context, 18)),

                                  // Quick Access horizontal
                                  SizedBox(
                                    height: _px(context, 110),
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      children: [
                                        _buildEnhancedFeatureButton(
                                          context,
                                          FlutterIslamicIcons.quran2,
                                          'Al-Quran',
                                          AppTheme.primaryBlue,
                                          onTap: () => Navigator.pushNamed(
                                            context,
                                            '/quran',
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        _buildEnhancedFeatureButton(
                                          context,
                                          FlutterIslamicIcons.prayingPerson,
                                          'Sholat',
                                          AppTheme.primaryBlue,
                                          onTap: () => Navigator.pushNamed(
                                            context,
                                            '/sholat',
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        _buildEnhancedFeatureButton(
                                          context,
                                          FlutterIslamicIcons.ramadan,
                                          'Puasa',
                                          AppTheme.primaryBlue,
                                          onTap: () => Navigator.pushNamed(
                                            context,
                                            '/puasa',
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        _buildEnhancedFeatureButton(
                                          context,
                                          FlutterIslamicIcons.qibla,
                                          'Qibla',
                                          AppTheme.primaryBlue,
                                          onTap: () => Navigator.pushNamed(
                                            context,
                                            '/qibla-compass',
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        _buildEnhancedFeatureButton(
                                          context,
                                          FlutterIslamicIcons.zakat,
                                          'Sedekah',
                                          AppTheme.primaryBlue,
                                          onTap: () => Navigator.pushNamed(
                                            context,
                                            '/zakat',
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        _buildEnhancedFeatureButton(
                                          context,
                                          Icons.apps_rounded,
                                          'More',
                                          Colors.grey.shade700,
                                          onTap: () =>
                                              _showAllFeaturesSheet(context),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: _px(context, 32)),

                                  // Latest Articles
                                  _buildSectionHeader(
                                    context,
                                    'Artikel Terbaru',
                                    Icons.article_rounded,
                                    AppTheme.primaryBlue,
                                  ),
                                  SizedBox(height: _px(context, 16)),

                                  // Articles list
                                  ...List.generate(
                                    3,
                                    (index) => _buildEnhancedArticleCard(
                                      title: _getArticleTitle(index),
                                      summary: _getArticleSummary(index),
                                      imageUrl:
                                          'https://picsum.photos/120/100?random=${index + 2}',
                                      date: _getArticleDate(index),
                                      context: context,
                                      category: index == 0
                                          ? 'Ramadhan'
                                          : (index == 1 ? 'Doa' : 'Ibadah'),
                                    ),
                                  ),

                                  SizedBox(
                                    height: _px(context, 100),
                                  ), // for bottom nav
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeWidget(
    BuildContext context,
    String name,
    String time,
    IconData icon,
    bool isActive,
  ) {
    final box = _px(context, 44);
    final ic = _icon(context, 20);
    final nameFs = _t(context, 12);
    final timeFs = _t(context, 11);
    final gap = _px(context, 6);

    return SizedBox(
      width: box + _px(context, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: nameFs,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: gap),
          Container(
            width: box,
            height: box,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: .3)
                  : Colors.white.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1,
                    )
                  : null,
            ),
            child: Icon(icon, color: Colors.white, size: ic),
          ),
          SizedBox(height: gap),
          Text(
            time,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: timeFs,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getArticleTitle(int index) {
    const titles = [
      'Keutamaan Membaca Al-Quran di Bulan Ramadhan',
      'Doa-Doa yang Dianjurkan Dibaca Setelah Sholat',
      'Amalan-Amalan Sunnah di Malam Lailatul Qadr',
    ];
    return titles[index % titles.length];
  }

  String _getArticleSummary(int index) {
    const summaries = [
      'Membaca Al-Quran di bulan Ramadhan memiliki pahala yang berlipat ganda. Simak penjelasan lengkapnya...',
      'Setelah sholat, dianjurkan untuk membaca doa-doa tertentu untuk mendapatkan keberkahan...',
      'Lailatul Qadr adalah malam yang lebih baik dari seribu bulan. Berikut amalan yang dianjurkan...',
    ];
    return summaries[index % summaries.length];
  }

  String _getArticleDate(int index) {
    const dates = [
      '2 hari yang lalu',
      '5 hari yang lalu',
      '1 minggu yang lalu',
    ];
    return dates[index % dates.length];
  }
}

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
                child: GridView.count(
                  controller: scrollController,
                  crossAxisCount: _gridColumns(context),
                  padding: EdgeInsets.symmetric(
                    horizontal: _hpad(context),
                    vertical: 16.0,
                  ),
                  mainAxisSpacing: _px(context, 20),
                  crossAxisSpacing: _px(context, 16),
                  childAspectRatio: 0.95,
                  children: _buildFeatureItems(context),
                ),
              ),
            ],
          ),
        );
      },
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
        'Monitoring Keluarga',
        AppTheme.accentGreen,
        '/monitoring',
      ),
      _FeatureData(
        FlutterIslamicIcons.prayer,
        'Tahajud Challenge',
        AppTheme.accentGreen,
        '/tahajud',
      ),
      _FeatureData(
        Icons.alarm_rounded,
        'Alarm',
        AppTheme.accentGreen,
        '/alarm-settings',
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

// ---------------------- Shared widgets (pakai ResponsiveHelper) ----------------------

class _ResponsivePrayerRow extends StatelessWidget {
  final List<Widget> children;
  final double itemHeight;
  const _ResponsivePrayerRow({
    required this.children,
    required this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    final w = ResponsiveHelper.getScreenWidth(context);
    if (w < 340) {
      return SizedBox(
        height: itemHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: children.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => children[i],
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }
}

Widget _buildEnhancedFeatureButton(
  BuildContext context,
  IconData icon,
  String label,
  Color color, {
  VoidCallback? onTap,
}) {
  double scale(BuildContext c) {
    if (ResponsiveHelper.isSmallScreen(c)) return .9;
    if (ResponsiveHelper.isMediumScreen(c)) return 1.0;
    if (ResponsiveHelper.isLargeScreen(c)) return 1.1;
    return 1.2;
  }

  double px(double base) => base * scale(context);
  double ts(double base) => ResponsiveHelper.adaptiveTextSize(context, base);

  final iconContainerSize = px(64);
  final iconSize = px(28);
  final fontSize = ts(13);

  return GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: iconContainerSize + 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionHeader(
  BuildContext context,
  String title,
  IconData icon,
  Color color,
) {
  double px(double base) {
    if (ResponsiveHelper.isSmallScreen(context)) return base * .9;
    if (ResponsiveHelper.isMediumScreen(context)) return base;
    if (ResponsiveHelper.isLargeScreen(context)) return base * 1.1;
    return base * 1.2;
  }

  return Row(
    children: [
      Container(
        padding: EdgeInsets.all(px(8)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: px(20)),
      ),
      const SizedBox(width: 12),
      Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveHelper.adaptiveTextSize(context, 20),
          fontWeight: FontWeight.bold,
          color: AppTheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
    ],
  );
}

Widget _buildEnhancedArticleCard({
  required String title,
  required String summary,
  required String imageUrl,
  required String date,
  required String category,
  required BuildContext context,
}) {
  double scale(BuildContext c) {
    if (ResponsiveHelper.isSmallScreen(c)) return .9;
    if (ResponsiveHelper.isMediumScreen(c)) return 1.0;
    if (ResponsiveHelper.isLargeScreen(c)) return 1.1;
    return 1.2;
  }

  double px(double base) => base * scale(context);
  double ts(double base) => ResponsiveHelper.adaptiveTextSize(context, base);

  final imgW = px(100);
  final imgH = px(90);

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 15,
          offset: const Offset(0, 4),
          spreadRadius: -3,
        ),
      ],
    ),
    child: InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/article-detail',
          arguments: {
            'title': title,
            'summary': summary,
            'imageUrl': imageUrl,
            'date': date,
            'content': '',
            'author': 'Tim Editorial Islamic App',
            'readTime': '5 min',
            'category': category,
          },
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: EdgeInsets.all(px(12)),
        child: Row(
          children: [
            // Image
            Container(
              width: imgW,
              height: imgH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      width: imgW,
                      height: imgH,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: imgW,
                          height: imgH,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image,
                            color: Colors.grey.shade400,
                            size: px(32),
                          ),
                        );
                      },
                    ),
                    // Category badge
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: px(8),
                          vertical: px(4),
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ts(10),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ts(15),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: px(6)),
                  Text(
                    summary,
                    style: TextStyle(
                      fontSize: ts(13),
                      color: AppTheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: px(8)),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: px(14),
                        color: AppTheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: ts(12),
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: px(14),
                        color: AppTheme.primaryBlue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
