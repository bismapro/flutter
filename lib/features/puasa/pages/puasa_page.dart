import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/features/puasa/widgets/sunnah_tab.dart';
import 'package:test_flutter/features/puasa/pages/ramadhan_detail_page.dart';
import 'package:test_flutter/features/puasa/pages/sunnah_detail_page.dart';

class PuasaPage extends StatefulWidget {
  const PuasaPage({super.key});

  @override
  State<PuasaPage> createState() => _PuasaPageState();
}

class _PuasaPageState extends State<PuasaPage> with TickerProviderStateMixin {
  late TabController _tabController;

  // Data puasa (untuk demo)
  Map<DateTime, Map<String, dynamic>> _puasaData = {};

  final List<Map<String, dynamic>> _puasaSunnah = [
    {
      'name': 'Puasa Senin Kamis',
      'description': 'Puasa sunnah setiap hari Senin dan Kamis',
      'duration': 'Mingguan',
      'period': 'Setiap minggu',
      'color': AppTheme.primaryBlue,
      'icon': Icons.calendar_today,
    },
    {
      'name': 'Puasa Ayyamul Bidh',
      'description': 'Puasa tanggal 13, 14, 15 setiap bulan Hijriah',
      'duration': '3 hari',
      'period': 'Setiap bulan',
      'color': AppTheme.primaryBlueDark,
      'icon': Icons.brightness_3,
    },
    {
      'name': 'Puasa Daud',
      'description': 'Puasa sehari berbuka sehari',
      'duration': 'Bergantian',
      'period': 'Kontinyu',
      'color': AppTheme.primaryBlueLight,
      'icon': Icons.swap_horiz,
    },
    {
      'name': 'Puasa 6 Syawal',
      'description': 'Puasa 6 hari di bulan Syawal',
      'duration': '6 hari',
      'period': 'Syawal',
      'color': AppTheme.accentGreenDark,
      'icon': Icons.star,
    },
    {
      'name': 'Puasa Muharram',
      'description': 'Puasa tanggal 9 dan 10 Muharram (Asyura)',
      'duration': '1-2 hari',
      'period': 'Muharram',
      'color': AppTheme.errorColor,
      'icon': Icons.event_note,
    },
    {
      'name': 'Puasa Syaban',
      'description': 'Puasa sunnah di bulan Syaban',
      'duration': 'Fleksibel',
      'period': 'Syaban',
      'color': AppTheme.accentGreen,
      'icon': Icons.nightlight_round,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Inisialisasi data sample untuk demo
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      if (date.weekday == DateTime.monday ||
          date.weekday == DateTime.thursday) {
        _puasaData[DateTime(date.year, date.month, date.day)] = {
          'type': 'Senin Kamis',
          'status': i < 10 ? 'completed' : 'planned',
          'notes': 'Puasa Senin Kamis',
        };
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ...existing code...
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
            // stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(
                  isDesktop
                      ? 32.0
                      : isTablet
                      ? 28.0
                      : 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isTablet ? 14 : 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryBlue.withValues(alpha: 0.1),
                                AppTheme.accentGreen.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              isTablet ? 16 : 14,
                            ),
                          ),
                          child: Icon(
                            Icons.mosque,
                            color: AppTheme.primaryBlue,
                            size: isDesktop
                                ? 28
                                : isTablet
                                ? 26
                                : 24,
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kalender Puasa',
                                style: TextStyle(
                                  fontSize: isDesktop
                                      ? 22
                                      : isTablet
                                      ? 20
                                      : 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Tracking ibadah puasa',
                                style: TextStyle(
                                  fontSize: isDesktop
                                      ? 15
                                      : isTablet
                                      ? 14
                                      : 14,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // Tab Bar
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
                    Tab(text: 'Puasa Wajib'),
                    Tab(text: 'Puasa Sunnah'),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 16 : 12),
              // ...existing code...

              // TabView Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    RamadhanDetailPage(
                      puasaData: _puasaData,
                      onMarkFasting: _markFasting,
                      isEmbedded: true,
                    ),
                    SunnahTab(
                      puasaSunnah: _puasaSunnah,
                      onPuasaTap: _showPuasaDetail,
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

  void _showPuasaDetail(Map<String, dynamic> puasa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SunnahDetailPage(puasaData: puasa),
      ),
    );
  }

  void _markFasting(DateTime date) {
    setState(() {
      final dateKey = DateTime(date.year, date.month, date.day);
      _puasaData[dateKey] = {
        'type': 'Puasa Sunnah',
        'status': 'completed',
        'notes': 'Puasa sunnah',
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alhamdulillah! Puasa telah ditandai 🤲'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
