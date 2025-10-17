import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/connection/connection_provider.dart';
import 'package:test_flutter/features/puasa/widgets/sunnah_tab.dart';
import 'package:test_flutter/features/puasa/pages/ramadhan_detail_page.dart';
import 'package:test_flutter/features/puasa/pages/sunnah_detail_page.dart';
import 'package:test_flutter/features/puasa/puasa_provider.dart';

class PuasaPage extends ConsumerStatefulWidget {
  const PuasaPage({super.key});

  @override
  ConsumerState<PuasaPage> createState() => _PuasaPageState();
}

class _PuasaPageState extends ConsumerState<PuasaPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _hasInitializedWajib = false;
  bool _hasInitializedSunnah = false;

  final List<Map<String, dynamic>> _puasaSunnah = [
    {
      'name': 'Puasa Senin Kamis',
      'description': 'Puasa sunnah setiap hari Senin dan Kamis',
      'duration': 'Mingguan',
      'period': 'Setiap minggu',
      'color': AppTheme.primaryBlue,
      'icon': Icons.calendar_today,
      'type': 'senin_kamis',
    },
    {
      'name': 'Puasa Ayyamul Bidh',
      'description': 'Puasa tanggal 13, 14, 15 setiap bulan Hijriah',
      'duration': '3 hari',
      'period': 'Setiap bulan',
      'color': AppTheme.primaryBlueDark,
      'icon': Icons.brightness_3,
      'type': 'ayyamul_bidh',
    },
    {
      'name': 'Puasa Daud',
      'description': 'Puasa sehari berbuka sehari',
      'duration': 'Bergantian',
      'period': 'Kontinyu',
      'color': AppTheme.primaryBlueLight,
      'icon': Icons.swap_horiz,
      'type': 'daud',
    },
    {
      'name': 'Puasa 6 Syawal',
      'description': 'Puasa 6 hari di bulan Syawal',
      'duration': '6 hari',
      'period': 'Syawal',
      'color': AppTheme.accentGreenDark,
      'icon': Icons.star,
      'type': 'syawal',
    },
    {
      'name': 'Puasa Muharram',
      'description': 'Puasa tanggal 9 dan 10 Muharram (Asyura)',
      'duration': '1-2 hari',
      'period': 'Muharram',
      'color': AppTheme.errorColor,
      'icon': Icons.event_note,
      'type': 'muharram',
    },
    {
      'name': 'Puasa Syaban',
      'description': 'Puasa sunnah di bulan Syaban',
      'duration': 'Fleksibel',
      'period': 'Syaban',
      'color': AppTheme.accentGreen,
      'icon': Icons.nightlight_round,
      'type': 'syaban',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes
    _tabController.addListener(_handleTabChange);

    // Saat online kembali → fetch ulang
    ref.listen(connectionProvider, (previous, next) {
      if (previous?.isOnline == false && next.isOnline) {
        if (!_hasInitializedWajib) _initPuasaWajib();
        if (!_hasInitializedSunnah) _initPuasaSunnah();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPuasaWajib();
    });
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;

    final currentIndex = _tabController.index;

    if (currentIndex == 0 && !_hasInitializedWajib) {
      // Tab Puasa Wajib
      _initPuasaWajib();
    } else if (currentIndex == 1 && !_hasInitializedSunnah) {
      // Tab Puasa Sunnah
      _initPuasaSunnah();
    }
  }

  Future<void> _initPuasaWajib() async {
    if (_hasInitializedWajib) return;

    final connectionState = ref.read(connectionProvider);
    final isOffline = !connectionState.isOnline;

    if (isOffline) {
      return;
    }

    try {
      await ref.read(puasaProvider.notifier).fetchRiwayatPuasaWajib();
      _hasInitializedWajib = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Puasa Wajib: $e');
      }
    }
  }

  Future<void> _initPuasaSunnah() async {
    if (_hasInitializedSunnah) return;

    final connectionState = ref.read(connectionProvider);
    final isOffline = !connectionState.isOnline;

    if (isOffline) {
      return;
    }

    try {
      await ref
          .read(puasaProvider.notifier)
          .fetchRiwayatPuasaSunnah(jenis: 'senin_kamis');

      _hasInitializedSunnah = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Puasa Sunnah: $e');
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;
    final connectionState = ref.watch(connectionProvider);
    final isOffline = !connectionState.isOnline;

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

                              if (isOffline)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 12 : 10,
                                    vertical: isTablet ? 6 : 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.wifi_off_rounded,
                                        color: Colors.red.shade700,
                                        size: isTablet ? 16 : 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Offline',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: isTablet ? 12 : 11,
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

              // TabView Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    RamadhanDetailPage(isEmbedded: true),
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
}
