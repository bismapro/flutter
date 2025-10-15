import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';

class RamadhanDetailPage extends StatefulWidget {
  final Map<DateTime, Map<String, dynamic>>? puasaData;
  final Function(DateTime)? onMarkFasting;
  final bool isEmbedded;

  const RamadhanDetailPage({
    super.key,
    this.puasaData,
    this.onMarkFasting,
    this.isEmbedded = false,
  });

  @override
  State<RamadhanDetailPage> createState() => _RamadhanDetailPageState();
}

class _RamadhanDetailPageState extends State<RamadhanDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Sample data for Ramadan
  final Map<int, Map<String, dynamic>> _ramadhanProgress = {
    1: {
      'status': 'completed',
      'sahur': true,
      'iftar': true,
      'notes': 'Alhamdulillah lancar',
    },
    2: {
      'status': 'completed',
      'sahur': true,
      'iftar': true,
      'notes': 'Sedikit lapar siang',
    },
    3: {'status': 'completed', 'sahur': true, 'iftar': true, 'notes': ''},
    4: {
      'status': 'completed',
      'sahur': true,
      'iftar': true,
      'notes': 'Tarawih hingga selesai',
    },
    5: {
      'status': 'completed',
      'sahur': false,
      'iftar': true,
      'notes': 'Terlambat sahur',
    },
    6: {'status': 'planned', 'sahur': false, 'iftar': false, 'notes': ''},
    7: {'status': 'planned', 'sahur': false, 'iftar': false, 'notes': ''},
    // ... up to 30 days
  };

  final List<Map<String, dynamic>> _sunnah = [
    {
      'title': 'Sahur',
      'description': 'Makan sahur sebelum subuh',
      'reward': 'Mendapat berkah dan kekuatan',
      'icon': Icons.restaurant,
      'color': AppTheme.accentGreen,
    },
    {
      'title': 'Doa Berbuka',
      'description': 'Membaca doa ketika berbuka puasa',
      'reward': 'Doa mustajab saat berbuka',
      'icon': Icons.favorite,
      'color': AppTheme.primaryBlue,
    },
    {
      'title': 'Tarawih',
      'description': 'Sholat tarawih berjamaah',
      'reward': 'Pahala sholat malam',
      'icon': Icons.mosque,
      'color': AppTheme.primaryBlueDark,
    },
    {
      'title': 'Tadarus',
      'description': 'Membaca Al-Quran setiap hari',
      'reward': 'Setiap huruf bernilai 10 kebaikan',
      'icon': Icons.menu_book,
      'color': AppTheme.accentGreenDark,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
              // Header with back button (only if not embedded)
              if (!widget.isEmbedded) ...[
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
                          borderRadius: BorderRadius.circular(
                            isTablet ? 14 : 12,
                          ),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.08,
                              ),
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
                              'Puasa Ramadhan 1446 H',
                              style: TextStyle(
                                fontSize: isDesktop
                                    ? 22
                                    : isTablet
                                    ? 20
                                    : 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Bulan penuh berkah dan ampunan',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 14,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Progress Summary Cards - Smaller
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
                      '5',
                      '30',
                      'Completed',
                      AppTheme.accentGreen,
                      Icons.check_circle_rounded,
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 12 : 10),
                    _buildProgressCard(
                      '25',
                      '30',
                      'Tersisa',
                      AppTheme.primaryBlue,
                      Icons.schedule_rounded,
                      isTablet,
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // Tab Bar - New Style
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isDesktop
                      ? 32.0
                      : isTablet
                      ? 28.0
                      : 24.0,
                ),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppTheme.primaryBlue,
                  unselectedLabelColor: AppTheme.onSurfaceVariant,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 14 : 13,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 14 : 13,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Kalender'),
                    Tab(text: 'Amalan Sunnah'),
                    // Tab(text: 'Statistik'),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // TabView Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRamadhanCalendar(),
                    _buildSunnahTab(),
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
    String total,
    String label,
    Color color,
    IconData icon,
    bool isTablet,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 8 : 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
              ),
              child: Icon(icon, color: color, size: isTablet ? 18 : 16),
            ),
            SizedBox(height: isTablet ? 8 : 6),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (total.isNotEmpty)
                    TextSpan(
                      text: '/$total',
                      style: TextStyle(
                        fontSize: isTablet ? 11 : 10,
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: isTablet ? 4 : 2),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 10 : 9,
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

  Widget _buildRamadhanCalendar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 32.0
            : isTablet
            ? 28.0
            : 24.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 22 : 20),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
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
        children: [
          // Calendar Header - Smaller
          Container(
            padding: EdgeInsets.all(isTablet ? 14 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.05),
                  AppTheme.accentGreen.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isTablet ? 22 : 20),
                topRight: Radius.circular(isTablet ? 22 : 20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mosque,
                  color: AppTheme.primaryBlue,
                  size: isTablet ? 20 : 18,
                ),
                SizedBox(width: isTablet ? 8 : 6),
                Text(
                  'Ramadhan 1446 H',
                  style: TextStyle(
                    fontSize: isDesktop
                        ? 16
                        : isTablet
                        ? 15
                        : 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          // Calendar Grid - Larger
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: isDesktop
                      ? 1.0
                      : isTablet
                      ? 0.95
                      : 0.85,
                  crossAxisSpacing: isTablet ? 8 : 6,
                  mainAxisSpacing: isTablet ? 8 : 6,
                ),
                itemCount: 30, // 30 days of Ramadan
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final dayData = widget.puasaData != null
                      ? _getRamadhanDayData(day)
                      : _ramadhanProgress[day];
                  final isCompleted = dayData?['status'] == 'completed';
                  final isToday = day == 6; // Current day for demo

                  return GestureDetector(
                    onTap: () => _showDayDetail(day, dayData),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? LinearGradient(
                                colors: [
                                  AppTheme.accentGreen.withValues(alpha: 0.2),
                                  AppTheme.accentGreen.withValues(alpha: 0.1),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  AppTheme.primaryBlue.withValues(alpha: 0.1),
                                  AppTheme.primaryBlue.withValues(alpha: 0.05),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                        border: isToday
                            ? Border.all(color: AppTheme.primaryBlue, width: 2)
                            : Border.all(
                                color: isCompleted
                                    ? AppTheme.accentGreen.withValues(
                                        alpha: 0.3,
                                      )
                                    : AppTheme.primaryBlue.withValues(
                                        alpha: 0.1,
                                      ),
                                width: 1,
                              ),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentGreen.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            day.toString(),
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isCompleted
                                  ? AppTheme.accentGreen
                                  : isToday
                                  ? AppTheme.primaryBlue
                                  : AppTheme.onSurface,
                            ),
                          ),
                          if (isCompleted) ...[
                            SizedBox(height: 2),
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.accentGreen,
                              size: isTablet ? 14 : 12,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ...existing code...
  Widget _buildSunnahTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 32.0
            : isTablet
            ? 28.0
            : 24.0,
      ),
      itemCount: _sunnah.length,
      itemBuilder: (context, index) {
        final sunnah = _sunnah[index];
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
            child: Row(
              children: [
                Container(
                  width: isDesktop
                      ? 60
                      : isTablet
                      ? 56
                      : 52,
                  height: isDesktop
                      ? 60
                      : isTablet
                      ? 56
                      : 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        sunnah['color'].withValues(alpha: 0.15),
                        sunnah['color'].withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
                    border: Border.all(
                      color: sunnah['color'].withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    sunnah['icon'],
                    color: sunnah['color'],
                    size: isTablet ? 28 : 26,
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sunnah['title'],
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
                      SizedBox(height: isTablet ? 6 : 4),
                      Text(
                        sunnah['description'],
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: isTablet ? 8 : 6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12 : 10,
                          vertical: isTablet ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.accentGreen.withValues(alpha: 0.1),
                              AppTheme.accentGreen.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                          border: Border.all(
                            color: AppTheme.accentGreen.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          sunnah['reward'],
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            color: AppTheme.accentGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
          // Weekly Progress
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
                  'Progress Mingguan',
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
                    _buildWeeklyBar(
                      'Ming 1',
                      1.0,
                      AppTheme.accentGreen,
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    _buildWeeklyBar(
                      'Ming 2',
                      0.8,
                      AppTheme.primaryBlue,
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    _buildWeeklyBar(
                      'Ming 3',
                      0.4,
                      AppTheme.primaryBlueDark,
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    _buildWeeklyBar(
                      'Ming 4',
                      0.0,
                      AppTheme.onSurfaceVariant,
                      isTablet,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 24 : 20),

          // Achievements
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
                  'Puasa Penuh 5 Hari',
                  'Berhasil puasa tanpa terputus',
                  Icons.star,
                  AppTheme.accentGreen,
                  true,
                  isTablet,
                ),
                SizedBox(height: isTablet ? 12 : 8),
                _buildAchievement(
                  'Sahur Konsisten',
                  'Sahur 7 hari berturut-turut',
                  Icons.restaurant,
                  AppTheme.primaryBlue,
                  false,
                  isTablet,
                ),
                SizedBox(height: isTablet ? 12 : 8),
                _buildAchievement(
                  'Tarawih Rutin',
                  'Tarawih 10 malam berturut-turut',
                  Icons.mosque,
                  AppTheme.primaryBlueDark,
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

  Widget _buildWeeklyBar(
    String label,
    double progress,
    Color color,
    bool isTablet,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: isTablet ? 120 : 100,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: (isTablet ? 120 : 100) * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color.withValues(alpha: 0.8), color],
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                ),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 12 : 11,
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

  void _showDayDetail(int day, Map<String, dynamic>? dayData) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isTablet ? 28 : 24),
            topRight: Radius.circular(isTablet ? 28 : 24),
          ),
        ),
        padding: EdgeInsets.all(isTablet ? 28 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isTablet ? 50 : 40,
              height: isTablet ? 6 : 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.3),
                    AppTheme.accentGreen.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(isTablet ? 3 : 2),
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            Text(
              'Hari ke-$day Ramadhan',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            SizedBox(height: isTablet ? 20 : 16),
            if (dayData != null) ...[
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: dayData['status'] == 'completed'
                        ? [
                            AppTheme.accentGreen.withValues(alpha: 0.15),
                            AppTheme.accentGreen.withValues(alpha: 0.1),
                          ]
                        : [
                            AppTheme.primaryBlue.withValues(alpha: 0.15),
                            AppTheme.primaryBlue.withValues(alpha: 0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
                  border: Border.all(
                    color:
                        (dayData['status'] == 'completed'
                                ? AppTheme.accentGreen
                                : AppTheme.primaryBlue)
                            .withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      dayData['status'] == 'completed'
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                      color: dayData['status'] == 'completed'
                          ? AppTheme.accentGreen
                          : AppTheme.primaryBlue,
                      size: isTablet ? 36 : 32,
                    ),
                    SizedBox(height: isTablet ? 12 : 10),
                    Text(
                      dayData['status'] == 'completed'
                          ? 'Puasa Completed!'
                          : 'Puasa Direncanakan',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    if (dayData['notes']?.isNotEmpty ?? false) ...[
                      SizedBox(height: isTablet ? 8 : 6),
                      Text(
                        dayData['notes'],
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: isTablet ? 15 : 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.05),
                      AppTheme.accentGreen.withValues(alpha: 0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      color: AppTheme.onSurfaceVariant,
                      size: isTablet ? 36 : 32,
                    ),
                    SizedBox(height: isTablet ? 10 : 8),
                    Text(
                      'Belum ada aktivitas puasa',
                      style: TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: isTablet ? 24 : 20),
            if (widget.onMarkFasting != null) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _markRamadhanFasting(day);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 16 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isTablet ? 14 : 12,
                          ),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        'Tandai Puasa',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 15 : 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: BorderSide(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 16 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isTablet ? 14 : 12,
                          ),
                        ),
                      ),
                      child: Text(
                        'Tutup',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 15 : 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Tutup',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 15 : 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? _getRamadhanDayData(int day) {
    if (widget.puasaData == null) return null;

    // Create Ramadan date for this year (approximate)
    final now = DateTime.now();
    final ramadanDate = DateTime(now.year, 3, day); // Assuming March for demo
    final dateKey = DateTime(
      ramadanDate.year,
      ramadanDate.month,
      ramadanDate.day,
    );

    return widget.puasaData![dateKey];
  }

  void _markRamadhanFasting(int day) {
    if (widget.onMarkFasting != null) {
      final now = DateTime.now();
      final ramadanDate = DateTime(now.year, 3, day); // Assuming March for demo
      widget.onMarkFasting!(ramadanDate);
    }
  }
}
