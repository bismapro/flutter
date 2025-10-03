import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/core/widgets/menu/custom_bottom_app_bar.dart';
import 'package:test_flutter/features/komunitas/pages/komunitas_page.dart';
import 'package:test_flutter/features/monitoring/pages/monitoring_page.dart';
import 'package:test_flutter/features/quran/pages/quran_page.dart';
import 'package:test_flutter/features/sholat/pages/sholat_page.dart';
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
    final r = _R.of(context);

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

          // Top gradient section
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header with location
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.hpad,
                    vertical: r.space(16, 18, 20),
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
                                fontSize: r.tsp(16, 18, 20),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: r.space(4, 6, 8)),
                            Text(
                              'Jakarta, Indonesia',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: r.tsp(13, 14, 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: Container(
                          padding: EdgeInsets.all(r.space(6, 8, 10)),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: r.icon(22, 24, 26),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: r.space(14, 18, 22)),

                // Current prayer time
                Text(
                  '04:41',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: r.tsp(48, 56, 64),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Fajr 3 hour 9 min left',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: r.tsp(14, 16, 18),
                  ),
                ),

                SizedBox(height: r.space(22, 28, 34)),

                // Prayer times
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.hpad),
                  child: _ResponsivePrayerRow(
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

                SizedBox(height: r.space(16, 20, 24)),
              ],
            ),
          ),

          // DraggableScrollableSheet
          LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final initial = height < 680
                  ? 0.52
                  : (height < 800 ? 0.48 : 0.45);
              final max = r.isDesktop ? 0.9 : 0.85;

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

                        // Scrollable content wrapped by maxWidth
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: r.contentMaxWidth,
                              ),
                              child: ListView(
                                controller: scrollController,
                                padding: EdgeInsets.symmetric(
                                  horizontal: r.hpad,
                                  vertical: r.space(8, 12, 16),
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
                                              size: r.icon(22, 24, 26),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Quick Access',
                                            style: TextStyle(
                                              fontSize: r.tsp(18, 20, 22),
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
                                          size: r.icon(16, 18, 20),
                                          color: AppTheme.primaryBlue,
                                        ),
                                        label: Text(
                                          'See All',
                                          style: TextStyle(
                                            color: AppTheme.primaryBlue,
                                            fontWeight: FontWeight.w600,
                                            fontSize: r.tsp(13, 14, 15),
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: r.space(10, 12, 14),
                                            vertical: r.space(6, 8, 10),
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
                                  SizedBox(height: r.space(14, 18, 20)),

                                  // Quick Access horizontal
                                  SizedBox(
                                    height: r.space(100, 110, 120),
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

                                  SizedBox(height: r.space(28, 32, 36)),

                                  // Latest Articles
                                  _buildSectionHeader(
                                    context,
                                    'Artikel Terbaru',
                                    Icons.article_rounded,
                                    AppTheme.primaryBlue,
                                  ),
                                  SizedBox(height: r.space(12, 16, 18)),

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
                                    height: r.space(80, 100, 120),
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
    final r = _R.of(context);

    double box = r.sizeScaler(36, 44, 50);
    double ic = r.icon(18, 20, 22);
    double nameFs = r.tsp(10, 12, 14);
    double timeFs = r.tsp(9, 11, 12);
    double gap = r.space(4, 6, 8);

    return SizedBox(
      width: box + r.space(12, 16, 18),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final responsive = _ResponsiveConfig.fromScreenSize(size);

    return DraggableScrollableSheet(
      initialChildSize: responsive.initialSheetSize,
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
                  horizontal: responsive.horizontalPadding,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Features',
                      style: TextStyle(
                        fontSize: responsive.headerFontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.grey[600],
                      iconSize: responsive.closeIconSize,
                      padding: EdgeInsets.all(responsive.iconButtonPadding),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Grid of features
              Expanded(
                child: GridView.count(
                  controller: scrollController,
                  crossAxisCount: responsive.gridColumns,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                    vertical: 16.0,
                  ),
                  mainAxisSpacing: responsive.gridMainSpacing,
                  crossAxisSpacing: responsive.gridCrossSpacing,
                  childAspectRatio: responsive.gridAspectRatio,
                  children: _buildFeatureItems(context, responsive),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildFeatureItems(
    BuildContext context,
    _ResponsiveConfig responsive,
  ) {
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

    return features
        .map((feature) => _buildFeatureItem(context, feature, responsive))
        .toList();
  }

  Widget _buildFeatureItem(
    BuildContext context,
    _FeatureData feature,
    _ResponsiveConfig responsive,
  ) {
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
            width: responsive.iconContainerSize,
            height: responsive.iconContainerSize,
            decoration: BoxDecoration(
              color: feature.color,
              borderRadius: BorderRadius.circular(responsive.iconBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: feature.color.withValues(alpha: .3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              feature.icon,
              color: Colors.white,
              size: responsive.iconSize,
            ),
          ),
          SizedBox(height: responsive.iconLabelSpacing),
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.labelPadding,
              ),
              child: Text(
                feature.label,
                style: TextStyle(
                  fontSize: responsive.labelFontSize,
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

// ------------------------- Responsive helpers -------------------------

class _R {
  final BuildContext context;
  final Size size;
  final double width;
  final double height;

  _R._(this.context, this.size) : width = size.width, height = size.height;

  static _R of(BuildContext context) =>
      _R._(context, MediaQuery.of(context).size);

  bool get isSmall => width < 360;
  bool get isPhone => width < 600;
  bool get isTablet => width >= 600 && width < 900;
  bool get isDesktop => width >= 900;

  // content max width on tablet/desktop
  double get contentMaxWidth =>
      isDesktop ? 980 : (isTablet ? 820 : double.infinity);

  // horizontal safe padding
  double get hpad {
    if (isDesktop) return 48;
    if (isTablet) return 32;
    return width * 0.04; // ~16 on small phones
  }

  // scale text size with clamps
  double tsp(double small, double normal, double large) {
    if (isSmall) return small;
    if (isTablet) return large;
    return normal;
  }

  // generic spacing scaler
  double space(double small, double normal, double large) {
    if (isSmall) return small;
    if (isTablet) return large;
    return normal;
  }

  // icon scaler
  double icon(double small, double normal, double large) =>
      tsp(small, normal, large);

  // box size scaler
  double sizeScaler(double small, double normal, double large) =>
      tsp(small, normal, large);

  // double size(double s, double n, double l) => sizeScaler(s, n, l);
}

// Wraps the five prayer items; switches to scrollable row on very narrow screens
class _ResponsivePrayerRow extends StatelessWidget {
  final List<Widget> children;
  const _ResponsivePrayerRow({required this.children});

  @override
  Widget build(BuildContext context) {
    final r = _R.of(context);

    if (r.width < 340) {
      return SizedBox(
        height: r.sizeScaler(88, 98, 110),
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

// ------------------------- AllFeatures responsive config -------------------------

class _ResponsiveConfig {
  final int gridColumns;
  final double gridMainSpacing;
  final double gridCrossSpacing;
  final double gridAspectRatio;
  final double iconContainerSize;
  final double iconSize;
  final double iconBorderRadius;
  final double labelFontSize;
  final double labelPadding;
  final double iconLabelSpacing;
  final double headerFontSize;
  final double closeIconSize;
  final double iconButtonPadding;
  final double horizontalPadding;
  final double initialSheetSize;

  const _ResponsiveConfig({
    required this.gridColumns,
    required this.gridMainSpacing,
    required this.gridCrossSpacing,
    required this.gridAspectRatio,
    required this.iconContainerSize,
    required this.iconSize,
    required this.iconBorderRadius,
    required this.labelFontSize,
    required this.labelPadding,
    required this.iconLabelSpacing,
    required this.headerFontSize,
    required this.closeIconSize,
    required this.iconButtonPadding,
    required this.horizontalPadding,
    required this.initialSheetSize,
  });

  factory _ResponsiveConfig.fromScreenSize(Size size) {
    final width = size.width;
    final height = size.height;

    if (width < 360) {
      return const _ResponsiveConfig(
        gridColumns: 3,
        gridMainSpacing: 16,
        gridCrossSpacing: 12,
        gridAspectRatio: 0.85,
        iconContainerSize: 48,
        iconSize: 24,
        iconBorderRadius: 14,
        labelFontSize: 10,
        labelPadding: 2,
        iconLabelSpacing: 6,
        headerFontSize: 18,
        closeIconSize: 20,
        iconButtonPadding: 8,
        horizontalPadding: 16,
        initialSheetSize: 0.88,
      );
    } else if (width < 600) {
      return _ResponsiveConfig(
        gridColumns: 4,
        gridMainSpacing: 20,
        gridCrossSpacing: 16,
        gridAspectRatio: 0.9,
        iconContainerSize: 56,
        iconSize: 28,
        iconBorderRadius: 16,
        labelFontSize: 11,
        labelPadding: 2,
        iconLabelSpacing: 8,
        headerFontSize: 20,
        closeIconSize: 24,
        iconButtonPadding: 8,
        horizontalPadding: width * 0.05,
        initialSheetSize: height < 700 ? 0.82 : 0.72,
      );
    } else if (width < 900) {
      return const _ResponsiveConfig(
        gridColumns: 5,
        gridMainSpacing: 24,
        gridCrossSpacing: 20,
        gridAspectRatio: 0.95,
        iconContainerSize: 64,
        iconSize: 32,
        iconBorderRadius: 18,
        labelFontSize: 12,
        labelPadding: 4,
        iconLabelSpacing: 10,
        headerFontSize: 22,
        closeIconSize: 26,
        iconButtonPadding: 10,
        horizontalPadding: 32,
        initialSheetSize: 0.66,
      );
    } else {
      return const _ResponsiveConfig(
        gridColumns: 6,
        gridMainSpacing: 28,
        gridCrossSpacing: 24,
        gridAspectRatio: 1.0,
        iconContainerSize: 72,
        iconSize: 36,
        iconBorderRadius: 20,
        labelFontSize: 13,
        labelPadding: 6,
        iconLabelSpacing: 12,
        headerFontSize: 24,
        closeIconSize: 28,
        iconButtonPadding: 12,
        horizontalPadding: 48,
        initialSheetSize: 0.6,
      );
    }
  }
}

class _FeatureData {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;

  const _FeatureData(this.icon, this.label, this.color, this.route);
}

// --------------- Shared UI helpers from your original file (kept, but responsive) ---------------

Widget _buildEnhancedFeatureButton(
  BuildContext context,
  IconData icon,
  String label,
  Color color, {
  VoidCallback? onTap,
}) {
  final r = _R.of(context);

  double iconContainerSize = r.sizeScaler(56, 64, 72);
  double iconSize = r.icon(24, 28, 32);
  double fontSize = r.tsp(11, 13, 14);

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
  final r = _R.of(context);

  return Row(
    children: [
      Container(
        padding: EdgeInsets.all(r.space(6, 8, 10)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: r.icon(18, 20, 22)),
      ),
      const SizedBox(width: 12),
      Text(
        title,
        style: TextStyle(
          fontSize: r.tsp(18, 20, 22),
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
  final r = _R.of(context);
  final imgW = r.sizeScaler(90, 100, 110);
  final imgH = r.sizeScaler(80, 90, 100);

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
        padding: EdgeInsets.all(r.space(10, 12, 14)),
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
                            size: r.icon(28, 32, 36),
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
                          horizontal: r.space(6, 8, 10),
                          vertical: r.space(3, 4, 5),
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: r.tsp(9, 10, 11),
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
                      fontSize: r.tsp(14, 15, 16),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: r.space(4, 6, 8)),
                  Text(
                    summary,
                    style: TextStyle(
                      fontSize: r.tsp(12, 13, 14),
                      color: AppTheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: r.space(6, 8, 10)),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: r.icon(12, 14, 16),
                        color: AppTheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: r.tsp(11, 12, 13),
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: r.icon(12, 14, 16),
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
