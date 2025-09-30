import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';

class SunnahDetailPage extends StatefulWidget {
  final Map<String, dynamic> puasaData;

  const SunnahDetailPage({super.key, required this.puasaData});

  @override
  State<SunnahDetailPage> createState() => _SunnahDetailPageState();
}

class _SunnahDetailPageState extends State<SunnahDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Sample tracking data based on puasa type
  Map<DateTime, Map<String, dynamic>> _trackingData = {};

  final Map<String, List<Map<String, dynamic>>> _puasaGuides = {
    'Puasa Senin Kamis': [
      {
        'title': 'Niat Puasa Senin Kamis',
        'content':
            'نَوَيْتُ صَوْمَ يَوْمِ الْاِثْنَيْنِ سُنَّةً لِلّٰهِ تَعَالَى\n\nArtinya: "Aku berniat puasa hari Senin sunnah karena Allah Ta\'ala"',
        'icon': Icons.favorite,
        'color': AppTheme.primaryBlue,
      },
      {
        'title': 'Keutamaan',
        'content':
            'Rasulullah SAW bersabda: "Amal perbuatan itu dilaporkan pada hari Senin dan Kamis, maka aku suka amalku dilaporkan dalam keadaan berpuasa." (HR. Tirmidzi)',
        'icon': Icons.star,
        'color': AppTheme.accentGreen,
      },
      {
        'title': 'Tips Pelaksanaan',
        'content':
            '• Mulai sahur lebih awal\n• Banyak minum saat berbuka\n• Jaga konsistensi setiap minggu\n• Kombinasikan dengan amalan lain',
        'icon': Icons.lightbulb,
        'color': AppTheme.primaryBlueDark,
      },
    ],
    'Puasa Ayyamul Bidh': [
      {
        'title': 'Niat Puasa Ayyamul Bidh',
        'content':
            'نَوَيْتُ صَوْمَ الْأَيَّامِ الْبِيْضِ سُنَّةً لِلّٰهِ تَعَالَى\n\nArtinya: "Aku berniat puasa Ayyamul Bidh sunnah karena Allah Ta\'ala"',
        'icon': Icons.favorite,
        'color': AppTheme.primaryBlue,
      },
      {
        'title': 'Waktu Pelaksanaan',
        'content':
            'Puasa pada tanggal 13, 14, dan 15 setiap bulan Hijriah. Disebut "Ayyamul Bidh" karena bulan purnama bersinar terang pada hari-hari tersebut.',
        'icon': Icons.calendar_month,
        'color': AppTheme.accentGreen,
      },
      {
        'title': 'Hikmah dan Manfaat',
        'content':
            '• Mengikuti sunnah Rasulullah SAW\n• Melatih kesabaran dan ketakwaan\n• Mendapat pahala seperti puasa setahun\n• Menjaga kesehatan tubuh',
        'icon': Icons.psychology,
        'color': AppTheme.primaryBlueDark,
      },
    ],
    'Puasa Daud': [
      {
        'title': 'Cara Pelaksanaan',
        'content':
            'Puasa sehari, berbuka sehari secara bergantian. Ini adalah puasa yang paling dicintai Allah menurut hadits Rasulullah SAW.',
        'icon': Icons.swap_horiz,
        'color': AppTheme.primaryBlue,
      },
      {
        'title': 'Keutamaan Istimewa',
        'content':
            'Rasulullah SAW bersabda: "Puasa yang paling dicintai Allah adalah puasa Daud. Dia berpuasa sehari dan berbuka sehari." (HR. Bukhari)',
        'icon': Icons.diamond,
        'color': AppTheme.accentGreen,
      },
      {
        'title': 'Panduan Praktis',
        'content':
            '• Mulai secara bertahap\n• Pilih hari yang sesuai aktivitas\n• Jaga konsistensi pola\n• Perhatikan kondisi kesehatan',
        'icon': Icons.schedule,
        'color': AppTheme.primaryBlueDark,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeTrackingData();
  }

  void _initializeTrackingData() {
    final now = DateTime.now();
    final puasaName = widget.puasaData['name'];

    // Generate sample data based on puasa type
    if (puasaName == 'Puasa Senin Kamis') {
      for (int i = 0; i < 60; i++) {
        final date = now.subtract(Duration(days: i));
        if (date.weekday == DateTime.monday ||
            date.weekday == DateTime.thursday) {
          _trackingData[DateTime(date.year, date.month, date.day)] = {
            'status': i < 20 ? 'completed' : (i < 40 ? 'planned' : 'skipped'),
            'notes': i < 20 ? 'Alhamdulillah lancar' : '',
          };
        }
      }
    } else if (puasaName == 'Puasa Ayyamul Bidh') {
      // Generate for 13, 14, 15 of each month
      for (int month = 1; month <= 12; month++) {
        for (int day = 13; day <= 15; day++) {
          final date = DateTime(now.year, month, day);
          if (!date.isAfter(now)) {
            _trackingData[DateTime(date.year, date.month, date.day)] = {
              'status': date.isBefore(now.subtract(const Duration(days: 30)))
                  ? 'completed'
                  : 'planned',
              'notes': 'Ayyamul Bidh bulan $month',
            };
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.03),
              AppTheme.backgroundWhite,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Container(
                padding: EdgeInsets.all(
                  isDesktop
                      ? 32.0
                      : isTablet
                      ? 28.0
                      : 24.0,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.primaryBlue,
                          size: isTablet ? 26 : 24,
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 20 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.puasaData['name'],
                            style: TextStyle(
                              fontSize: isDesktop
                                  ? 26
                                  : isTablet
                                  ? 24
                                  : 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            widget.puasaData['description'],
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Summary
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isDesktop
                      ? 32.0
                      : isTablet
                      ? 28.0
                      : 24.0,
                ),
                child: Row(
                  children: [
                    _buildProgressCard(
                      _getCompletedCount().toString(),
                      'Completed',
                      AppTheme.accentGreen,
                      Icons.check_circle_rounded,
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    _buildProgressCard(
                      _getPlannedCount().toString(),
                      'Planned',
                      AppTheme.primaryBlue,
                      Icons.schedule_rounded,
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    _buildProgressCard(
                      '${_getCompletionRate()}%',
                      'Success Rate',
                      AppTheme.primaryBlueDark,
                      Icons.trending_up_rounded,
                      isTablet,
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 28 : 24),

              // Tab Bar
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isDesktop
                      ? 32.0
                      : isTablet
                      ? 28.0
                      : 24.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primaryBlue,
                  labelColor: AppTheme.primaryBlue,
                  unselectedLabelColor: AppTheme.onSurfaceVariant,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 15 : 14,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: isTablet ? 15 : 14,
                  ),
                  tabs: const [
                    Tab(text: 'Tracking'),
                    Tab(text: 'Panduan'),
                    Tab(text: 'Statistik'),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 24 : 20),

              // TabView Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTrackingTab(),
                    _buildGuideTab(),
                    _buildStatisticsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    String value,
    String label,
    Color color,
    IconData icon,
    bool isTablet,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
          border: Border.all(color: color.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
              ),
              child: Icon(icon, color: color, size: isTablet ? 24 : 22),
            ),
            SizedBox(height: isTablet ? 12 : 10),
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: isTablet ? 6 : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 12 : 11,
                color: AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 32.0
            : isTablet
            ? 28.0
            : 24.0,
      ),
      child: Column(
        children: [
          // Recent Activity
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 22 : 20),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: AppTheme.primaryBlue,
                      size: isTablet ? 24 : 22,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Text(
                      'Aktivitas Terbaru',
                      style: TextStyle(
                        fontSize: isDesktop
                            ? 20
                            : isTablet
                            ? 18
                            : 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 20 : 16),
                ..._getRecentActivities()
                    .map((activity) => _buildActivityItem(activity, isTablet))
                    .toList(),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 24 : 20),

          // Quick Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _markTodayFasting(),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.puasaData['color'],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              icon: Icon(Icons.add_task, size: isTablet ? 20 : 18),
              label: Text(
                'Tandai Puasa Hari Ini',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 16 : 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    final guides = _puasaGuides[widget.puasaData['name']] ?? [];

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 32.0
            : isTablet
            ? 28.0
            : 24.0,
      ),
      itemCount: guides.length,
      itemBuilder: (context, index) {
        final guide = guides[index];
        return Container(
          margin: EdgeInsets.only(bottom: isTablet ? 18 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 22 : 20),
            border: Border.all(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(
              isDesktop
                  ? 24
                  : isTablet
                  ? 22
                  : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isTablet ? 12 : 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            guide['color'].withValues(alpha: 0.15),
                            guide['color'].withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                      ),
                      child: Icon(
                        guide['icon'],
                        color: guide['color'],
                        size: isTablet ? 24 : 22,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: Text(
                        guide['title'],
                        style: TextStyle(
                          fontSize: isDesktop
                              ? 18
                              : isTablet
                              ? 17
                              : 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  guide['content'],
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    color: AppTheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 32.0
            : isTablet
            ? 28.0
            : 24.0,
      ),
      child: Column(
        children: [
          // Monthly Progress Chart
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 22 : 20),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress Bulanan',
                  style: TextStyle(
                    fontSize: isDesktop
                        ? 20
                        : isTablet
                        ? 18
                        : 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                SizedBox(height: isTablet ? 20 : 16),
                Row(
                  children: [
                    _buildMonthlyBar(
                      'Jan',
                      0.8,
                      AppTheme.accentGreen,
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    _buildMonthlyBar(
                      'Feb',
                      0.6,
                      AppTheme.primaryBlue,
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    _buildMonthlyBar(
                      'Mar',
                      0.9,
                      AppTheme.accentGreen,
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    _buildMonthlyBar(
                      'Apr',
                      0.7,
                      AppTheme.primaryBlue,
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    _buildMonthlyBar(
                      'Mei',
                      0.5,
                      AppTheme.primaryBlueDark,
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    _buildMonthlyBar(
                      'Jun',
                      0.3,
                      AppTheme.onSurfaceVariant,
                      isTablet,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 24 : 20),

          // Achievement Summary
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 22 : 20),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pencapaian',
                  style: TextStyle(
                    fontSize: isDesktop
                        ? 20
                        : isTablet
                        ? 18
                        : 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 12),
                _buildAchievement(
                  'Konsisten 7 Hari',
                  'Puasa ${widget.puasaData['name']} berturut-turut',
                  Icons.star,
                  AppTheme.accentGreen,
                  true,
                  isTablet,
                ),
                SizedBox(height: isTablet ? 12 : 8),
                _buildAchievement(
                  'Bulan Sempurna',
                  'Menyelesaikan target puasa dalam sebulan',
                  Icons.diamond,
                  AppTheme.primaryBlue,
                  false,
                  isTablet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      padding: EdgeInsets.all(isTablet ? 12 : 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (activity['status'] == 'completed'
                    ? AppTheme.accentGreen
                    : AppTheme.primaryBlue)
                .withValues(alpha: 0.05),
            (activity['status'] == 'completed'
                    ? AppTheme.accentGreen
                    : AppTheme.primaryBlue)
                .withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        border: Border.all(
          color:
              (activity['status'] == 'completed'
                      ? AppTheme.accentGreen
                      : AppTheme.primaryBlue)
                  .withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            activity['status'] == 'completed'
                ? Icons.check_circle
                : Icons.schedule,
            color: activity['status'] == 'completed'
                ? AppTheme.accentGreen
                : AppTheme.primaryBlue,
            size: isTablet ? 20 : 18,
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['date'],
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
                if (activity['notes'].isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    activity['notes'],
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBar(
    String label,
    double progress,
    Color color,
    bool isTablet,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: isTablet ? 80 : 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: (isTablet ? 80 : 60) * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color.withValues(alpha: 0.8), color],
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
                ),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 11 : 10,
              color: AppTheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievement(
    String title,
    String description,
    IconData icon,
    Color color,
    bool isUnlocked,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUnlocked
              ? [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)]
              : [
                  AppTheme.onSurfaceVariant.withValues(alpha: 0.05),
                  AppTheme.onSurfaceVariant.withValues(alpha: 0.02),
                ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
        border: Border.all(
          color: isUnlocked
              ? color.withValues(alpha: 0.2)
              : AppTheme.onSurfaceVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 12 : 10),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? color.withValues(alpha: 0.15)
                  : AppTheme.onSurfaceVariant.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? color : AppTheme.onSurfaceVariant,
              size: isTablet ? 24 : 22,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? AppTheme.onSurface
                        : AppTheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            Icon(Icons.check_circle, color: color, size: isTablet ? 24 : 22),
        ],
      ),
    );
  }

  int _getCompletedCount() {
    return _trackingData.values
        .where((data) => data['status'] == 'completed')
        .length;
  }

  int _getPlannedCount() {
    return _trackingData.values
        .where((data) => data['status'] == 'planned')
        .length;
  }

  int _getCompletionRate() {
    final completed = _getCompletedCount();
    final total = _trackingData.length;
    return total > 0 ? ((completed / total) * 100).round() : 0;
  }

  List<Map<String, dynamic>> _getRecentActivities() {
    final activities = <Map<String, dynamic>>[];
    final sortedEntries = _trackingData.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    for (var entry in sortedEntries.take(5)) {
      activities.add({
        'date': '${entry.key.day}/${entry.key.month}/${entry.key.year}',
        'status': entry.value['status'],
        'notes': entry.value['notes'] ?? '',
      });
    }

    return activities;
  }

  void _markTodayFasting() {
    final today = DateTime.now();
    final dateKey = DateTime(today.year, today.month, today.day);

    setState(() {
      _trackingData[dateKey] = {
        'status': 'completed',
        'notes': 'Alhamdulillah puasa hari ini',
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alhamdulillah! ${widget.puasaData['name']} hari ini telah ditandai 🤲',
        ),
        backgroundColor: AppTheme.accentGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
