import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
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

  final List<Widget> _pages = [
    const HomeTabContent(),
    const SholatPage(),
    const QuranPage(),
    const MonitoringPage(),
    const KomunitasPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

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

          // Background image with custom positioning
          // Positioned(
          //   top: -40, // Adjust this value to control vertical position
          //   left: 0,
          //   right: 0,
          //   height:
          //       MediaQuery.of(context).size.height *
          //       0.6, // Control image height
          //   child: Container(
          //     decoration: BoxDecoration(
          //       image: DecorationImage(
          //         image: AssetImage("assets/images/background/bg-1.png"),
          //         fit: BoxFit.cover,
          //         alignment: Alignment.topCenter,
          //         colorFilter: ColorFilter.mode(
          //           Colors.white.withValues(
          //             alpha: 0.01,
          //           ), // transparan banget, nyatu dengan background
          //           BlendMode.srcOver, // campur halus dengan background
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          // Top gradient section with prayer times
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header with location
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04,
                    vertical: 16.0,
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
                                fontSize:
                                    MediaQuery.of(context).size.width < 360
                                    ? 14
                                    : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Jakarta, Indonesia',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize:
                                    MediaQuery.of(context).size.width < 360
                                    ? 12
                                    : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                        child: Container(
                          padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width < 360 ? 6 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width < 360
                                ? 20
                                : 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height < 700 ? 16 : 20,
                ),

                // Current prayer time
                Text(
                  '04:41',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width < 360 ? 48 : 56,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Fajr 3 hour 9 min left',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width < 360 ? 14 : 16,
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height < 700 ? 24 : 32,
                ),

                // Prayer times row
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPrayerTimeWidget(
                        'Fajr',
                        '04:41',
                        Icons.nightlight_round,
                        true,
                      ),
                      _buildPrayerTimeWidget(
                        'Dzuhr',
                        '12:00',
                        Icons.wb_sunny_rounded,
                        false,
                      ),
                      _buildPrayerTimeWidget(
                        'Asr',
                        '15:14',
                        Icons.wb_twilight_rounded,
                        false,
                      ),
                      _buildPrayerTimeWidget(
                        'Maghrib',
                        '18:02',
                        Icons.wb_sunny_outlined,
                        false,
                      ),
                      _buildPrayerTimeWidget(
                        'Isha',
                        '19:11',
                        Icons.dark_mode_rounded,
                        false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // DraggableScrollableSheet Section
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.45,
            maxChildSize: 0.85,
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
                    // Enhanced Handle bar
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

                    // Scrollable content
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 8.0,
                        ),
                        children: [
                          // All Features Section - Enhanced
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primaryBlue.withValues(
                                            alpha: 0.1,
                                          ),
                                          AppTheme.accentGreen.withValues(
                                            alpha: 0.1,
                                          ),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.apps_rounded,
                                      color: AppTheme.primaryBlue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Quick Access',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.onSurface,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: () => _showAllFeaturesSheet(context),
                                icon: Icon(
                                  Icons.grid_view_rounded,
                                  size: 18,
                                  color: AppTheme.primaryBlue,
                                ),
                                label: Text(
                                  'See All',
                                  style: TextStyle(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  backgroundColor: AppTheme.primaryBlue
                                      .withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Features Row with Horizontal Scroll - Enhanced
                          SizedBox(
                            height: 110,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _buildEnhancedFeatureButton(
                                  context,
                                  FlutterIslamicIcons.quran2,
                                  'Al-Quran',
                                  AppTheme.primaryBlue,
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/quran'),
                                ),
                                const SizedBox(width: 14),
                                _buildEnhancedFeatureButton(
                                  context,
                                  FlutterIslamicIcons.prayingPerson,
                                  'Sholat',
                                  AppTheme.primaryBlue,
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/sholat'),
                                ),
                                const SizedBox(width: 14),
                                _buildEnhancedFeatureButton(
                                  context,
                                  FlutterIslamicIcons.ramadan,
                                  'Puasa',
                                  AppTheme.primaryBlue,
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/puasa'),
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
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/zakat'),
                                ),
                                const SizedBox(width: 14),
                                _buildEnhancedFeatureButton(
                                  context,
                                  Icons.apps_rounded,
                                  'More',
                                  Colors.grey.shade700,
                                  onTap: () => _showAllFeaturesSheet(context),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Ngaji Online Section - Enhanced
                          // _buildSectionHeader(
                          //   context,
                          //   'Ngaji Online',
                          //   Icons.play_circle_rounded,
                          //   AppTheme.accentGreen,
                          // ),
                          // const SizedBox(height: 16),

                          // Enhanced Live Stream Card
                          // GestureDetector(
                          //   onTap: () {
                          //     Navigator.pushNamed(context, '/ngaji-online');
                          //   },
                          //   child: Container(
                          //     height: 220,
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(20),
                          //       boxShadow: [
                          //         BoxShadow(
                          //           color: AppTheme.primaryBlue.withValues(
                          //             alpha: 0.15,
                          //           ),
                          //           blurRadius: 20,
                          //           offset: const Offset(0, 8),
                          //           spreadRadius: -5,
                          //         ),
                          //       ],
                          //     ),
                          //   child: ClipRRect(
                          //     borderRadius: BorderRadius.circular(20),
                          //     child: Stack(
                          //       children: [
                          //         // Image
                          //         Image.network(
                          //           'https://picsum.photos/400/220?random=1',
                          //           width: double.infinity,
                          //           height: double.infinity,
                          //           fit: BoxFit.cover,
                          //         ),
                          //         // Gradient overlay
                          //         Container(
                          //           decoration: BoxDecoration(
                          //             gradient: LinearGradient(
                          //               colors: [
                          //                 Colors.black.withValues(alpha: 0.2),
                          //                 Colors.transparent,
                          //                 Colors.black.withValues(alpha: 0.8),
                          //               ],
                          //               begin: Alignment.topCenter,
                          //               end: Alignment.bottomCenter,
                          //             ),
                          //           ),
                          //         ),
                          //         // Live Badge
                          //         Positioned(
                          //           top: 16,
                          //           left: 16,
                          //           child: Container(
                          //             padding: const EdgeInsets.symmetric(
                          //               horizontal: 12,
                          //               vertical: 6,
                          //             ),
                          //             decoration: BoxDecoration(
                          //               color: Colors.red,
                          //               borderRadius: BorderRadius.circular(20),
                          //               boxShadow: [
                          //                 BoxShadow(
                          //                   color: Colors.red.withValues(
                          //                     alpha: 0.5,
                          //                   ),
                          //                   blurRadius: 8,
                          //                   spreadRadius: 2,
                          //                 ),
                          //               ],
                          //             ),
                          //             child: Row(
                          //               mainAxisSize: MainAxisSize.min,
                          //               children: [
                          //                 Container(
                          //                   width: 6,
                          //                   height: 6,
                          //                   decoration: const BoxDecoration(
                          //                     color: Colors.white,
                          //                     shape: BoxShape.circle,
                          //                   ),
                          //                 ),
                          //                 const SizedBox(width: 6),
                          //                 const Text(
                          //                   'LIVE',
                          //                   style: TextStyle(
                          //                     color: Colors.white,
                          //                     fontSize: 12,
                          //                     fontWeight: FontWeight.bold,
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ),
                          //         // Play button
                          //         Center(
                          //           child: Container(
                          //             width: 60,
                          //             height: 60,
                          //             decoration: BoxDecoration(
                          //               color: Colors.white.withValues(
                          //                 alpha: 0.3,
                          //               ),
                          //               shape: BoxShape.circle,
                          //               border: Border.all(
                          //                 color: Colors.white,
                          //                 width: 2,
                          //               ),
                          //             ),
                          //             child: const Icon(
                          //               Icons.play_arrow_rounded,
                          //               color: Colors.white,
                          //               size: 36,
                          //             ),
                          //           ),
                          //         ),
                          //         // Bottom info
                          //         Positioned(
                          //           bottom: 16,
                          //           left: 16,
                          //           right: 16,
                          //           child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               Expanded(
                          //                 child: Column(
                          //                   crossAxisAlignment:
                          //                       CrossAxisAlignment.start,
                          //                   children: [
                          //                     const Text(
                          //                       'Kajian Tafsir Al-Quran',
                          //                       style: TextStyle(
                          //                         color: Colors.white,
                          //                         fontSize: 16,
                          //                         fontWeight: FontWeight.bold,
                          //                       ),
                          //                       maxLines: 1,
                          //                       overflow: TextOverflow.ellipsis,
                          //                     ),
                          //                     const SizedBox(height: 4),
                          //                     Text(
                          //                       'Ustadz Ahmad Fauzi',
                          //                       style: TextStyle(
                          //                         color: Colors.white
                          //                             .withValues(alpha: 0.9),
                          //                         fontSize: 13,
                          //                       ),
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ),
                          //               Container(
                          //                 padding: const EdgeInsets.symmetric(
                          //                   horizontal: 12,
                          //                   vertical: 6,
                          //                 ),
                          //                 decoration: BoxDecoration(
                          //                   color: Colors.black.withValues(
                          //                     alpha: 0.5,
                          //                   ),
                          //                   borderRadius: BorderRadius.circular(
                          //                     20,
                          //                   ),
                          //                 ),
                          //                 child: Row(
                          //                   children: [
                          //                     const Icon(
                          //                       Icons.remove_red_eye_rounded,
                          //                       color: Colors.white,
                          //                       size: 16,
                          //                     ),
                          //                     const SizedBox(width: 4),
                          //                     const Text(
                          //                       '3.6K',
                          //                       style: TextStyle(
                          //                         color: Colors.white,
                          //                         fontSize: 13,
                          //                         fontWeight: FontWeight.w600,
                          //                       ),
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // ),

                          // const SizedBox(height: 36),

                          // Latest Articles Section - Enhanced
                          _buildSectionHeader(
                            context,
                            'Artikel Terbaru',
                            Icons.article_rounded,
                            AppTheme.primaryBlue,
                          ),
                          const SizedBox(height: 16),

                          // Articles List
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

                          // Extra spacing for bottom navigation
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeWidget(
    String name,
    String time,
    IconData icon,
    bool isActive,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;

        // Responsive sizing
        double containerSize = 44;
        double iconSize = 20;
        double nameFontSize = 12;
        double timeFontSize = 11;
        double spacing = 6;

        if (screenWidth < 360) {
          containerSize = 36;
          iconSize = 18;
          nameFontSize = 10;
          timeFontSize = 9;
          spacing = 4;
        } else if (screenWidth >= 400) {
          containerSize = 48;
          iconSize = 22;
          nameFontSize = 14;
          timeFontSize = 12;
          spacing = 8;
        }

        return Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontSize: nameFontSize,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spacing),
              Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: .3)
                      : Colors.white.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: iconSize),
              ),
              SizedBox(height: spacing),
              Text(
                time,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontSize: timeFontSize,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
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
        FlutterIslamicIcons.quran2, // ikon Al-Quran
        'Al-Quran',
        AppTheme.accentGreen,
        '/quran',
      ),
      _FeatureData(
        FlutterIslamicIcons.prayingPerson, // orang rukuk/sujud
        'Sholat',
        AppTheme.accentGreen,
        '/sholat',
      ),
      _FeatureData(
        FlutterIslamicIcons.ramadan, // bulan bintang = puasa
        'Puasa',
        AppTheme.accentGreen,
        '/puasa',
      ),
      _FeatureData(
        FlutterIslamicIcons.qibla, // arah kiblat
        'Qibla',
        AppTheme.accentGreen,
        '/qibla-compass',
      ),
      _FeatureData(
        FlutterIslamicIcons.zakat, // tangan memberi (sedekah)
        'Sedekah',
        AppTheme.accentGreen,
        '/zakat',
      ),
      _FeatureData(
        FlutterIslamicIcons.family, // belum ada icon keluarga di package ini
        'Monitoring Keluarga',
        AppTheme.accentGreen,
        '/monitoring',
      ),
      _FeatureData(
        FlutterIslamicIcons.prayer, // ibadah malam / tahajud
        'Tahajud Challenge',
        AppTheme.accentGreen,
        '/tahajud',
      ),
      _FeatureData(
        Icons.alarm_rounded, // tetap pakai material
        'Alarm',
        AppTheme.accentGreen,
        '/alarm-settings',
      ),
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
        // HapticFeedback.lightImpact();
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

// Responsive configuration class
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

    // Small phones (< 360px)
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
        initialSheetSize: 0.85,
      );
    }
    // Normal phones (360px - 600px)
    else if (width >= 360 && width < 600) {
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
        initialSheetSize: height < 700 ? 0.8 : 0.7,
      );
    }
    // Tablets (600px - 900px)
    else if (width >= 600 && width < 900) {
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
        initialSheetSize: 0.65,
      );
    }
    // Large tablets / Desktop (>= 900px)
    else {
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

// Feature data model
class _FeatureData {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;

  const _FeatureData(this.icon, this.label, this.color, this.route);
}

Widget _buildEnhancedFeatureButton(
  BuildContext context,
  IconData icon,
  String label,
  Color color, {
  VoidCallback? onTap,
}) {
  final screenWidth = MediaQuery.of(context).size.width;

  double iconContainerSize = 64;
  double iconSize = 28;
  double fontSize = 13;

  if (screenWidth < 360) {
    iconContainerSize = 56;
    iconSize = 24;
    fontSize = 11;
  } else if (screenWidth >= 600) {
    iconContainerSize = 72;
    iconSize = 32;
    fontSize = 14;
  }

  return GestureDetector(
    onTap: onTap,
    child: Container(
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

// Enhanced Section Header Widget
Widget _buildSectionHeader(
  BuildContext context,
  String title,
  IconData icon,
  Color color,
) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 12),
      Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
    ],
  );
}

// Enhanced Article Card Widget
Widget _buildEnhancedArticleCard({
  required String title,
  required String summary,
  required String imageUrl,
  required String date,
  required String category,
  required BuildContext context,
}) {
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image with gradient overlay
            Container(
              width: 100,
              height: 90,
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
                      width: 100,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 90,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        );
                      },
                    ),
                    // Category badge on image
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    summary,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
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
