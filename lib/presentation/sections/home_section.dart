import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/prayer_time_widget.dart';
import '../widgets/feature_card.dart';
import '../widgets/article_card.dart';

class HomeSection extends StatelessWidget {
  const HomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.primaryGreen),
      child: SafeArea(
        child: Stack(
          children: [
            // Banner Section (Fixed Background)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 80.0),
                child: Column(
                  children: [
                    // Date and Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '9 Ramadhan 1444 H',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Jakarta, Indonesia',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Next Prayer Time
                    const Text(
                      '04:41',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const Text(
                      'Fajr 3 hour 9 min left',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 32),

                    // Prayer Times Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        PrayerTimeWidget(
                          name: 'Fajr',
                          time: '04:41',
                          icon: Icons.nightlight_round,
                          isActive: true,
                        ),
                        PrayerTimeWidget(
                          name: 'Dzuhr',
                          time: '12:00',
                          icon: Icons.wb_sunny,
                          isActive: false,
                        ),
                        PrayerTimeWidget(
                          name: 'Asr',
                          time: '15:14',
                          icon: Icons.wb_sunny_outlined,
                          isActive: false,
                        ),
                        PrayerTimeWidget(
                          name: 'Maghrib',
                          time: '18:02',
                          icon: Icons.brightness_3,
                          isActive: false,
                        ),
                        PrayerTimeWidget(
                          name: 'Isha',
                          time: '19:11',
                          icon: Icons.nights_stay,
                          isActive: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable White Section
            DraggableScrollableSheet(
              initialChildSize: 0.45, // Start at 45% of screen height
              minChildSize: 0.45, // Minimum 45%
              maxChildSize: 0.85, // Maximum 85%
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // All Features
                          const Text(
                            'All Features',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Features Grid - Scrollable
                          SizedBox(
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                FeatureCard(
                                  icon: Icons.menu_book,
                                  title: 'Quran',
                                  color: const Color(0xFF4DD0E1),
                                ),
                                const SizedBox(width: 12),
                                FeatureCard(
                                  icon: Icons.volume_up,
                                  title: 'Adzan',
                                  color: const Color(0xFF4DD0E1),
                                ),
                                const SizedBox(width: 12),
                                FeatureCard(
                                  icon: Icons.explore,
                                  title: 'Qibla',
                                  color: const Color(0xFF4DD0E1),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/qibla-compass',
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                FeatureCard(
                                  icon: Icons.favorite,
                                  title: 'Donation',
                                  color: const Color(0xFF4DD0E1),
                                ),
                                const SizedBox(width: 12),
                                FeatureCard(
                                  icon: Icons.apps,
                                  title: 'All',
                                  color: const Color(0xFF4DD0E1),
                                ),
                                const SizedBox(width: 12),
                                FeatureCard(
                                  icon: Icons.mosque,
                                  title: 'Masjid',
                                  color: const Color(0xFF4DD0E1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Ngaji Online Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ngaji Online',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'See All',
                                  style: TextStyle(
                                    color: Color(0xFF4DD0E1),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Live Stream Card
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://picsum.photos/400/200?random=1',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.3),
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                // Live badge
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Viewers count
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '3.6K viewers',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Latest Articles Section
                          const Text(
                            'Artikel Terbaru',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Articles List
                          ...List.generate(
                            3,
                            (index) => ArticleCard(
                              title: _getArticleTitle(index),
                              summary: _getArticleSummary(index),
                              imageUrl:
                                  'https://picsum.photos/80/80?random=${index + 2}',
                              date: _getArticleDate(index),
                              articleData: _getArticleData(index),
                            ),
                          ),

                          // Extra spacing for bottom navigation
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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

  Map<String, dynamic> _getArticleData(int index) {
    const categories = ['Ramadhan', 'Doa', 'Ibadah'];

    return {
      'title': _getArticleTitle(index),
      'summary': _getArticleSummary(index),
      'imageUrl': 'https://picsum.photos/400/300?random=${index + 2}',
      'date': _getArticleDate(index),
      'category': categories[index % categories.length],
      'readTime': '${5 + index} min',
      'tags': index == 0
          ? ['Ramadhan', 'Al-Quran', 'Ibadah']
          : index == 1
          ? ['Doa', 'Sholat', 'Amalan']
          : ['Lailatul Qadr', 'Malam', 'Sunnah'],
    };
  }
}
