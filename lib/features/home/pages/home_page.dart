import 'package:flutter/material.dart';
import 'package:test_flutter/core/widgets/menu/custom_bottom_app_bar.dart';
import 'package:test_flutter/features/artikel/pages/artikel_page.dart';
import 'package:test_flutter/features/komunitas/pages/komunitas_page.dart';
import 'package:test_flutter/features/premium/pages/premium_page.dart';
import 'package:test_flutter/features/profile/pages/profile_page.dart';
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
    const KomunitasPage(),
    const ArtikelPage(),
    const PremiumPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: _pages[_currentIndex],
      // floatingActionButton: SizedBox(
      //   width: 55.0,
      //   height: 55.0,
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       Navigator.pushNamed(context, '/qibla-compass');
      //     },
      //     backgroundColor: AppTheme.primaryBlue,
      //     elevation: 4,
      //     child: const Icon(Icons.explore, color: Colors.white, size: 28.0),
      //   ),
      // ),
      // floatingActionButtonLocation: CustomCenterDockedFAB(offsetY: 40),
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
          Positioned(
            top: -40, // Adjust this value to control vertical position
            left: 0,
            right: 0,
            height:
                MediaQuery.of(context).size.height *
                0.6, // Control image height
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background/bg-1.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(
                      alpha: 0.01,
                    ), // transparan banget, nyatu dengan background
                    BlendMode.srcOver, // campur halus dengan background
                  ),
                ),
              ),
            ),
          ),

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
                      Container(
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width < 360 ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: MediaQuery.of(context).size.width < 360
                              ? 20
                              : 24,
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
                                  Icons.menu_book_rounded,
                                  'Al-Quran',
                                  AppTheme.primaryBlue,
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/quran'),
                                ),
                                const SizedBox(width: 14),
                                _buildEnhancedFeatureButton(
                                  context,
                                  Icons.nightlight_round,
                                  'Puasa',
                                  AppTheme.accentGreen,
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/puasa'),
                                ),
                                const SizedBox(width: 14),
                                _buildEnhancedFeatureButton(
                                  context,
                                  Icons.explore_outlined,
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
                                  Icons.volunteer_activism_rounded,
                                  'Sedekah',
                                  AppTheme.accentGreen,
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
                          _buildSectionHeader(
                            context,
                            'Ngaji Online',
                            Icons.play_circle_rounded,
                            AppTheme.accentGreen,
                          ),
                          const SizedBox(height: 16),

                          // Enhanced Live Stream Card
                          Container(
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  // Image
                                  Image.network(
                                    'https://picsum.photos/400/220?random=1',
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  // Gradient overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withValues(alpha: 0.2),
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.8),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                  // Live Badge
                                  Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withValues(
                                              alpha: 0.5,
                                            ),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'LIVE',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Play button
                                  Center(
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                  ),
                                  // Bottom info
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    right: 16,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Kajian Tafsir Al-Quran',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Ustadz Ahmad Fauzi',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.remove_red_eye_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                '3.6K',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

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

  Widget _buildFeatureButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    double iconContainerSize = 56;
    double iconSize = 28;
    double fontSize = 12;
    double spacing = 8;

    if (screenWidth < 360) {
      iconContainerSize = 48;
      iconSize = 24;
      fontSize = 10;
      spacing = 6;
    } else if (screenWidth >= 600) {
      iconContainerSize = 64;
      iconSize = 32;
      fontSize = 14;
      spacing = 10;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
          SizedBox(height: spacing),
          SizedBox(
            width: iconContainerSize + 8, // Slightly wider for text
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                color: const Color(0xFF212121),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard({
    required String title,
    required String summary,
    required String imageUrl,
    required String date,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/article-detail',
          arguments: {
            'title': title,
            'summary': summary,
            'imageUrl': imageUrl,
            'date': date,
            'content': _getFullArticleContent(title),
            'author': 'Tim Editorial Islamic App',
            'readTime': '5 min',
            'category': 'Ibadah',
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: .1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 120,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFullArticleContent(String title) {
    // Mock content berdasarkan title
    switch (title) {
      case 'Keutamaan Membaca Al-Quran di Bulan Ramadhan':
        return '''Bulan Ramadhan adalah bulan yang penuh berkah dan rahmat. Dalam bulan ini, Allah SWT memberikan keutamaan yang luar biasa bagi umat Islam yang menjalankan ibadah dengan khusyuk.

Membaca Al-Quran di bulan Ramadhan memiliki pahala yang berlipat ganda dibandingkan dengan bulan-bulan lainnya. Rasulullah SAW bersabda dalam sebuah hadits yang diriwayatkan oleh Ibnu Majah:

"من قرأ حرفا من كتاب الله فله به حسنة، والحسنة بعشر أمثالها"

Artinya: "Barangsiapa membaca satu huruf dari kitab Allah, maka baginya satu kebaikan, dan satu kebaikan dibalas dengan sepuluh kali lipatnya."

Di bulan Ramadhan, pahala ini menjadi berlipat ganda karena kemuliaan bulan tersebut. Para ulama menyarankan untuk:

1. Membaca Al-Quran dengan tartil (perlahan dan jelas)
2. Merenungkan makna ayat-ayat yang dibaca
3. Mengamalkan isi kandungan Al-Quran dalam kehidupan sehari-hari
4. Membaca Al-Quran secara rutin setiap hari

Semoga dengan membaca Al-Quran di bulan Ramadhan, kita dapat meraih ridha Allah SWT dan menjadi pribadi yang lebih baik.''';

      case 'Doa-Doa yang Dianjurkan Dibaca Setelah Sholat':
        return '''Setelah menyelesaikan sholat, dianjurkan untuk membaca doa-doa tertentu sebagai bentuk dzikir dan memohon keberkahan kepada Allah SWT.

Berikut adalah beberapa doa yang dianjurkan:

1. ISTIGHFAR (3x)
أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ
"Astaghfirullaahal 'adhiim"
Artinya: "Aku memohon ampun kepada Allah Yang Maha Agung"

2. DOA SETELAH SHOLAT
اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ
"Allahumma a'innii 'alaa dzikrika wa syukrika wa husni 'ibaadatika"
Artinya: "Ya Allah, tolonglah aku dalam berdzikir kepada-Mu, bersyukur kepada-Mu, dan beribadah dengan baik kepada-Mu"

3. TASBIH, TAHMID, dan TAKBIR
- Subhanallah (33x)
- Alhamdulillah (33x)  
- Allahu Akbar (34x)

Doa-doa ini memiliki keutamaan yang besar dan dapat menjadi penutup yang baik setelah melaksanakan sholat.''';

      default:
        return '''Lailatul Qadr adalah malam yang sangat mulia dalam Islam. Malam ini disebutkan dalam Al-Quran sebagai malam yang lebih baik dari seribu bulan.

Beberapa amalan yang dianjurkan di malam Lailatul Qadr:

1. Sholat Tahajjud
Melaksanakan sholat malam dengan khusyuk dan penuh harapan.

2. Membaca Al-Quran
Memperbanyak tilawah Al-Quran, terutama surah-surah pendek.

3. Berdzikir dan Bertasbih
Memperbanyak dzikir dengan mengucap tasbih, tahmid, dan takbir.

4. Berdoa
Memohon kepada Allah dengan doa-doa yang tulus dari hati.

5. Istighfar
Memohon ampun kepada Allah atas segala dosa dan kesalahan.

Doa yang dianjurkan di malam Lailatul Qadr:
اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي

"Allahumma innaka 'afuwwun tuhibbul 'afwa fa'fu 'anni"

Artinya: "Ya Allah, sesungguhnya Engkau Maha Pemaaf dan menyukai maaf, maka maafkanlah aku."

Semoga kita dapat memanfaatkan malam Lailatul Qadr dengan sebaik-baiknya.''';
    }
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

class PremiumTabContent extends StatelessWidget {
  const PremiumTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Premium Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ArtikelTabContent extends StatefulWidget {
  const ArtikelTabContent({super.key});

  @override
  State<ArtikelTabContent> createState() => _ArtikelTabContentState();
}

class _ArtikelTabContentState extends State<ArtikelTabContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final List<String> _categories = [
    'Semua',
    'Ibadah',
    'Akhlak',
    'Sejarah',
    'Ramadhan',
    'Doa',
    'Al-Quran',
  ];

  final List<Map<String, dynamic>> _allArticles = [
    {
      'title': 'Keutamaan Membaca Al-Quran di Bulan Ramadhan',
      'summary':
          'Membaca Al-Quran di bulan Ramadhan memiliki pahala yang berlipat ganda. Simak penjelasan lengkapnya dalam artikel ini.',
      'category': 'Ramadhan',
      'date': '2 hari yang lalu',
      'readTime': '5 min',
      'imageUrl': 'https://picsum.photos/300/200?random=1',
    },
    {
      'title': 'Doa-Doa yang Dianjurkan Dibaca Setelah Sholat',
      'summary':
          'Setelah sholat, dianjurkan untuk membaca doa-doa tertentu untuk mendapatkan keberkahan dan perlindungan Allah SWT.',
      'category': 'Doa',
      'date': '3 hari yang lalu',
      'readTime': '7 min',
      'imageUrl': 'https://picsum.photos/300/200?random=2',
    },
    {
      'title': 'Amalan-Amalan Sunnah di Malam Lailatul Qadr',
      'summary':
          'Lailatul Qadr adalah malam yang lebih baik dari seribu bulan. Berikut amalan yang dianjurkan dilakukan.',
      'category': 'Ibadah',
      'date': '5 hari yang lalu',
      'readTime': '6 min',
      'imageUrl': 'https://picsum.photos/300/200?random=3',
    },
    {
      'title': 'Sejarah Turunnya Ayat Pertama Al-Quran',
      'summary':
          'Kisah turunnya wahyu pertama kepada Nabi Muhammad SAW di Gua Hira yang mengubah sejarah umat manusia.',
      'category': 'Sejarah',
      'date': '1 minggu yang lalu',
      'readTime': '8 min',
      'imageUrl': 'https://picsum.photos/300/200?random=4',
    },
    {
      'title': 'Pentingnya Menjaga Akhlak dalam Kehidupan Sehari-hari',
      'summary':
          'Akhlak yang baik adalah cerminan keimanan seseorang. Pelajari cara menjaga akhlak dalam berinteraksi.',
      'category': 'Akhlak',
      'date': '1 minggu yang lalu',
      'readTime': '4 min',
      'imageUrl': 'https://picsum.photos/300/200?random=5',
    },
    {
      'title': 'Makna dan Hikmah Surah Al-Fatihah',
      'summary':
          'Surah Al-Fatihah adalah induk dari Al-Quran. Pelajari makna dan hikmah yang terkandung di dalamnya.',
      'category': 'Al-Quran',
      'date': '2 minggu yang lalu',
      'readTime': '10 min',
      'imageUrl': 'https://picsum.photos/300/200?random=6',
    },
    {
      'title': 'Adab Masuk dan Keluar Masjid',
      'summary':
          'Islam mengajarkan adab yang baik dalam setiap aspek kehidupan, termasuk ketika masuk dan keluar masjid.',
      'category': 'Ibadah',
      'date': '2 minggu yang lalu',
      'readTime': '3 min',
      'imageUrl': 'https://picsum.photos/300/200?random=7',
    },
    {
      'title': 'Doa Berbuka Puasa dan Adabnya',
      'summary':
          'Ketika berbuka puasa, ada doa khusus yang dianjurkan untuk dibaca beserta adab-adab yang perlu diperhatikan.',
      'category': 'Ramadhan',
      'date': '3 minggu yang lalu',
      'readTime': '5 min',
      'imageUrl': 'https://picsum.photos/300/200?random=8',
    },
  ];

  List<Map<String, dynamic>> get _filteredArticles {
    return _allArticles.where((article) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          article['category'] == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          article['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article['summary'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Artikel Islami',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pelajari Islam lebih dalam',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari artikel...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Filter
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;

                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == _categories.length - 1 ? 0 : 12,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryBlue
                                      : AppTheme.borderColor,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Articles List
            Expanded(
              child: _filteredArticles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: AppTheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada artikel ditemukan',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba ubah kata kunci atau kategori',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = _filteredArticles[index];
                        return _buildArticleCard(article);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.network(
              article['imageUrl'],
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, size: 48, color: Colors.grey),
                );
              },
            ),
          ),

          // Article Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    article['category'],
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  article['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Summary
                Text(
                  article['summary'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Meta Info
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article['readTime'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article['date'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.bookmark_border,
                      size: 20,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class KomunitasTabContent extends StatefulWidget {
  const KomunitasTabContent({super.key});

  @override
  State<KomunitasTabContent> createState() => _KomunitasTabContentState();
}

class _KomunitasTabContentState extends State<KomunitasTabContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  // Simulated current user
  final String _currentUserId = 'user_123';
  final String _currentUserName = 'Muhammad Ahmad';

  List<Map<String, dynamic>> _communityPosts = [];

  @override
  void initState() {
    super.initState();
    _initializePosts();
  }

  void _initializePosts() {
    _communityPosts = [
      {
        'id': 'post_1',
        'title': 'Pengalaman Pertama Umrah di Bulan Ramadhan',
        'content':
            'Alhamdulillah, saya baru saja pulang dari umrah. Subhanallah, betapa berbedanya suasana Masjidil Haram di bulan Ramadhan.\n\n"Dan berikan kabar gembira kepada orang-orang yang berbuat baik" - QS. Al-Baqarah: 155\n\nBeberapa tips untuk teman-teman yang ingin umrah:\n• Persiapkan fisik dan mental jauh-jauh hari\n• Pelajari doa-doa dan manasik umrah\n• Bawa obat-obatan pribadi\n• Siapkan mental untuk antrian yang panjang\n\nSemoga bermanfaat!',
        'category': 'Sharing',
        'authorId': 'user_456',
        'authorName': 'Siti Aminah',
        'date': '2 jam yang lalu',
        'likes': 24,
        'likedBy': [],
        'comments': [
          {
            'id': 'comment_1',
            'authorName': 'Ahmad Fauzi',
            'content':
                'Masya Allah, pengalaman yang luar biasa. Semoga Allah mudahkan saya juga bisa kesana.',
            'date': '1 jam yang lalu',
          },
          {
            'id': 'comment_2',
            'authorName': 'Fatimah',
            'content':
                'Barakallahu fiik atas sharingnya. Bisa cerita lebih detail tentang persiapannya?',
            'date': '45 menit yang lalu',
          },
        ],
        'imageUrl': 'https://picsum.photos/400/250?random=1',
      },
      {
        'id': 'post_2',
        'title': 'Bagaimana Cara Khusyuk dalam Sholat?',
        'content':
            'Assalamualaikum, saya ingin bertanya kepada teman-teman. Bagaimana cara agar bisa lebih khusyuk dalam sholat? Sering kali pikiran saya kemana-mana saat sholat.\n\nMohon sharing pengalaman dari teman-teman 🙏',
        'category': 'Pertanyaan',
        'authorId': 'user_789',
        'authorName': 'Abdullah',
        'date': '5 jam yang lalu',
        'likes': 18,
        'likedBy': ['user_123'],
        'comments': [
          {
            'id': 'comment_3',
            'authorName': 'Ustadz Mahmud',
            'content':
                'Wa alaykumus salam. Salah satu caranya adalah dengan memahami makna bacaan sholat dan fokus pada dzikir.',
            'date': '4 jam yang lalu',
          },
        ],
        'imageUrl': null,
      },
      {
        'id': 'post_3',
        'title': 'Event Kajian Rutin Masjid Al-Barokah',
        'content':
            'Bismillah, kami mengundang teman-teman untuk menghadiri kajian rutin setiap Jumat malam di Masjid Al-Barokah.\n\nTema kali ini: "Menggali Hikmah dari Surah Al-Kahf"\n\nDetail Acara:\n• Waktu: Setiap Jumat, 20:00 - 21:30 WIB\n• Tempat: Masjid Al-Barokah, Jl. Raya No. 123\n• Pemateri: Ustadz Ahmad Hidayat\n• Free untuk umum\n\n"Dan bacakanlah apa yang diwahyukan kepadamu yaitu Kitab Tuhanmu" - QS. Al-Kahf: 27\n\nJazakumullahu khairan',
        'category': 'Event',
        'authorId': _currentUserId,
        'authorName': _currentUserName,
        'date': '1 hari yang lalu',
        'likes': 32,
        'likedBy': ['user_456', 'user_789'],
        'comments': [],
        'imageUrl': 'https://picsum.photos/400/250?random=3',
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredPosts {
    return _communityPosts.where((post) {
      final matchesCategory =
          _selectedCategory == 'Semua' || post['category'] == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          post['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post['content'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showAddPostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Post Baru'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  hintText: 'Masukkan judul post...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              Expanded(
                child: TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Konten',
                    hintText: 'Tulis konten post Anda di sini...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  minLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty) {
                setState(() {
                  _communityPosts.insert(0, {
                    'id': 'post_${DateTime.now().millisecondsSinceEpoch}',
                    'title': titleController.text,
                    'content': contentController.text,
                    'category': 'Diskusi',
                    'authorId': _currentUserId,
                    'authorName': _currentUserName,
                    'date': 'Baru saja',
                    'likes': 0,
                    'likedBy': [],
                    'comments': [],
                    'imageUrl': null,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _toggleLike(String postId) {
    setState(() {
      final postIndex = _communityPosts.indexWhere(
        (post) => post['id'] == postId,
      );
      if (postIndex != -1) {
        final post = _communityPosts[postIndex];
        final likedBy = List<String>.from(post['likedBy']);

        if (likedBy.contains(_currentUserId)) {
          likedBy.remove(_currentUserId);
          post['likes']--;
        } else {
          likedBy.add(_currentUserId);
          post['likes']++;
        }

        post['likedBy'] = likedBy;
      }
    });
  }

  void _deletePost(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Post'),
        content: const Text('Apakah Anda yakin ingin menghapus post ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _communityPosts.removeWhere((post) => post['id'] == postId);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showCommentsDialog(Map<String, dynamic> post) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Komentar',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),

                // Comments List
                Expanded(
                  child: post['comments'].isEmpty
                      ? const Center(child: Text('Belum ada komentar'))
                      : ListView.builder(
                          itemCount: post['comments'].length,
                          itemBuilder: (context, index) {
                            final comment = post['comments'][index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment['authorName'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        comment['date'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment['content'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const Divider(),

                // Add Comment
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Tulis komentar...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (commentController.text.isNotEmpty) {
                          setDialogState(() {
                            post['comments'].add({
                              'id':
                                  'comment_${DateTime.now().millisecondsSinceEpoch}',
                              'authorName': _currentUserName,
                              'content': commentController.text,
                              'date': 'Baru saja',
                            });
                          });
                          setState(() {}); // Update main state
                          commentController.clear();
                        }
                      },
                      child: const Text('Kirim'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Komunitas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Berbagi dan berdiskusi bersama',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari diskusi...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Posts List
            Expanded(
              child: _filteredPosts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 64,
                            color: AppTheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada diskusi ditemukan',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mulai diskusi baru dengan menekan tombol +',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = _filteredPosts[index];
                        return _buildPostCard(post);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final isLiked = (post['likedBy'] as List).contains(_currentUserId);
    final isMyPost = post['authorId'] == _currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryBlue.withValues(alpha: .1),
                  child: Text(
                    post['authorName'][0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['authorName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        post['date'],
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isMyPost)
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => _deletePost(post['id']),
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Category Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                post['category'],
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: Text(
                    post['content'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Post Image
          if (post['imageUrl'] != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post['imageUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Like Button
                GestureDetector(
                  onTap: () => _toggleLike(post['id']),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : AppTheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['likes']}',
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // Comment Button
                GestureDetector(
                  onTap: () => _showCommentsDialog(post),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: AppTheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['comments'].length}',
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Share Button
                Icon(
                  Icons.share_outlined,
                  color: AppTheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        Icons.menu_book_rounded,
        'Al-Quran',
        AppTheme.accentGreen,
        '/quran',
      ),
      _FeatureData(
        Icons.nightlight_round,
        'Puasa',
        AppTheme.accentGreen,
        '/puasa',
      ),
      _FeatureData(
        Icons.explore_outlined,
        'Qibla',
        AppTheme.accentGreen,
        '/qibla-compass',
      ),
      _FeatureData(
        Icons.volunteer_activism_rounded,
        'Sedekah',
        AppTheme.accentGreen,
        '/zakat',
      ),

      _FeatureData(
        Icons.alarm_rounded,
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

// Helper methods for article data
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
    'Membaca Al-Quran di bulan Ramadhan memiliki pahala yang berlipat ganda...',
    'Setelah sholat, dianjurkan untuk membaca doa-doa tertentu...',
    'Lailatul Qadr adalah malam yang lebih baik dari seribu bulan...',
  ];
  return summaries[index % summaries.length];
}

String _getArticleDate(int index) {
  const dates = ['2 hari lalu', '5 hari lalu', '1 minggu lalu'];
  return dates[index % dates.length];
}
