import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/app/router.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/core/widgets/toast.dart';
import 'child_detail_page.dart';

class MonitoringPage extends ConsumerStatefulWidget {
  const MonitoringPage({super.key});

  @override
  ConsumerState<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends ConsumerState<MonitoringPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String userRole = 'parent'; // 'parent' atau 'child'

  // Sample data anak
  final List<Map<String, dynamic>> children = [
    {
      'id': '1',
      'name': 'Ahmad Faiz',
      'age': 12,
      'avatar': Icons.boy_rounded,
      'lastActive': DateTime.now().subtract(const Duration(minutes: 30)),
      'todayProgress': {
        'sholat': 4,
        'totalSholat': 5,
        'quran': 2,
        'targetQuran': 3,
        'tahajud': true,
        'streak': 7,
      },
      'weeklyStats': {
        'sholat': [5, 4, 5, 3, 5, 5, 4],
        'quran': [3, 2, 3, 1, 2, 3, 2],
        'tahajud': [true, false, true, true, true, true, false],
      },
    },
    {
      'id': '2',
      'name': 'Siti Aisyah',
      'age': 10,
      'avatar': Icons.girl_rounded,
      'lastActive': DateTime.now().subtract(const Duration(hours: 2)),
      'todayProgress': {
        'sholat': 5,
        'totalSholat': 5,
        'quran': 3,
        'targetQuran': 3,
        'tahajud': false,
        'streak': 3,
      },
      'weeklyStats': {
        'sholat': [5, 5, 4, 5, 5, 3, 5],
        'quran': [3, 3, 2, 3, 3, 1, 3],
        'tahajud': [false, true, false, true, false, true, false],
      },
    },
  ];

  // Sample notifikasi
  final List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'childName': 'Ahmad Faiz',
      'type': 'missed_prayer',
      'message': 'Terlewat sholat Ashar',
      'time': DateTime.now().subtract(const Duration(hours: 1)),
      'isRead': false,
    },
    {
      'id': '2',
      'childName': 'Siti Aisyah',
      'type': 'achievement',
      'message': 'Mencapai streak 3 hari berturut-turut!',
      'time': DateTime.now().subtract(const Duration(hours: 3)),
      'isRead': false,
    },
    {
      'id': '3',
      'childName': 'Ahmad Faiz',
      'type': 'quran_target',
      'message': 'Mencapai target membaca Al-Qur\'an hari ini',
      'time': DateTime.now().subtract(const Duration(hours: 5)),
      'isRead': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ========= Helpers Responsif =========

  int _gridCount(BuildContext context) {
    if (ResponsiveHelper.isExtraLargeScreen(context)) return 4;
    if (ResponsiveHelper.isLargeScreen(context)) return 3;
    if (ResponsiveHelper.isMediumScreen(context)) return 2;
    return 1;
  }

  double _chartHeight(BuildContext context, {double base = 150}) {
    if (ResponsiveHelper.isSmallScreen(context)) return base * 0.9;
    if (ResponsiveHelper.isLargeScreen(context)) return base * 1.15;
    if (ResponsiveHelper.isExtraLargeScreen(context)) return base * 1.25;
    return base;
  }

  Widget _wrapMaxWidth(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: aktifkan authProvider saat siap
    // final authState = ref.watch(authProvider);
    // final isAuthenticated = authState.isAuthenticated;
    // final isPremium = authState.user?.isPremium ?? false;

    // sementara: hardcoded
    final isAuthenticated = true;
    final isPremium = false;

    if (!isAuthenticated) return _buildLoginRequired();
    if (!isPremium) return _buildPremiumRequired();

    // Main content when authenticated and premium
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
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
              _buildHeader(isPremium),
              const SizedBox(height: 16),
              _buildTabBar(),
              const SizedBox(height: 16),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDashboardTab(),
                      _buildChildrenTab(),
                      _buildNotificationsTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // ========= Halaman Auth & Premium =========

  Widget _buildLoginRequired() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryBlue.withValues(alpha: 0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 80,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Login Diperlukan',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.adaptiveTextSize(context, 28),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Anda harus login terlebih dahulu untuk mengakses fitur Monitoring Keluarga',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
                      color: AppTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Login Sekarang',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.adaptiveTextSize(
                            context,
                            16,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.home),
                    child: Text(
                      'Kembali ke Home',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.adaptiveTextSize(
                          context,
                          16,
                        ),
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumRequired() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.withValues(alpha: 0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.withValues(alpha: 0.2),
                          Colors.orange.withValues(alpha: 0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.family_restroom_rounded,
                      size: 80,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Fitur Premium',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.adaptiveTextSize(context, 28),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Monitoring Keluarga adalah fitur premium. Pantau aktivitas ibadah keluarga dengan fitur lengkap!',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
                      color: AppTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildPremiumFeature(
                    Icons.family_restroom_rounded,
                    'Monitor aktivitas semua anggota keluarga',
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumFeature(
                    Icons.analytics_rounded,
                    'Statistik dan grafik lengkap',
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumFeature(
                    Icons.notifications_active_rounded,
                    'Notifikasi real-time',
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumFeature(
                    Icons.emoji_events_rounded,
                    'Sistem reward dan achievement',
                  ),
                  const SizedBox(height: 48),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => showMessageToast(
                        context,
                        message: 'Fitur dalam pengembangan',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.workspace_premium_rounded, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Berlangganan Premium',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.adaptiveTextSize(
                                context,
                                16,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.home),
                    child: Text(
                      'Kembali ke Home',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.adaptiveTextSize(
                          context,
                          16,
                        ),
                        color: Colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumFeature(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.amber, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Icon(Icons.check_circle, color: Colors.green, size: 20),
      ],
    );
  }

  // ========= Header & Tab =========

  Widget _buildHeader(bool isPremium) {
    return Container(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, _) {
              final isWide = !ResponsiveHelper.isSmallScreen(context);
              final titleSize = ResponsiveHelper.adaptiveTextSize(context, 28);
              final subtitleSize = ResponsiveHelper.adaptiveTextSize(
                context,
                15,
              );

              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitoring Keluarga',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    userRole == 'parent'
                        ? 'Pantau aktivitas ibadah anak'
                        : 'Laporkan aktivitas ibadah Anda',
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );

              final badge = isPremium
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();

              return isWide
                  ? Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryBlue.withValues(alpha: 0.15),
                                AppTheme.accentGreen.withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.family_restroom_rounded,
                            color: AppTheme.primaryBlue,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: title),
                        badge,
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryBlue.withValues(
                                      alpha: 0.15,
                                    ),
                                    AppTheme.accentGreen.withValues(
                                      alpha: 0.15,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.family_restroom_rounded,
                                color: AppTheme.primaryBlue,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: title),
                            const SizedBox(width: 8),
                            badge,
                          ],
                        ),
                      ],
                    );
            },
          ),
          const SizedBox(height: 20),

          // Stats Summary
          if (userRole == 'parent')
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                    AppTheme.accentGreen.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, _) {
                  final isWide =
                      ResponsiveHelper.isMediumScreen(context) ||
                      ResponsiveHelper.isLargeScreen(context) ||
                      ResponsiveHelper.isExtraLargeScreen(context);
                  final items = [
                    Expanded(
                      child: _buildQuickStat(
                        'Anak Aktif',
                        '${children.length}',
                        Icons.people_rounded,
                        AppTheme.primaryBlue,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _buildQuickStat(
                        'Notifikasi',
                        '${notifications.where((n) => !n['isRead']).length}',
                        Icons.notifications_rounded,
                        AppTheme.accentGreen,
                      ),
                    ),
                  ];
                  return isWide
                      ? Row(children: items)
                      : Column(
                          children: [
                            _buildQuickStat(
                              'Anak Aktif',
                              '${children.length}',
                              Icons.people_rounded,
                              AppTheme.primaryBlue,
                            ),
                            const SizedBox(height: 12),
                            _buildQuickStat(
                              'Notifikasi',
                              '${notifications.where((n) => !n['isRead']).length}',
                              Icons.notifications_rounded,
                              AppTheme.accentGreen,
                            ),
                          ],
                        );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveHelper.adaptiveTextSize(context, 18),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveHelper.adaptiveTextSize(context, 12),
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isSmallScreen(context) ? 12 : 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: ResponsiveHelper.isSmallScreen(context),
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.onSurfaceVariant,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
        ),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        padding: const EdgeInsets.all(6),
        tabs: const [
          Tab(icon: Icon(Icons.dashboard_rounded, size: 20), text: 'Dashboard'),
          Tab(icon: Icon(Icons.group_rounded, size: 20), text: 'Anak-anak'),
          Tab(
            icon: Icon(Icons.notifications_rounded, size: 20),
            text: 'Notifikasi',
          ),
        ],
      ),
    );
  }

  // ========= Tab: Dashboard =========

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Aktivitas Hari Ini',
            style: TextStyle(
              fontSize: ResponsiveHelper.adaptiveTextSize(context, 20),
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          ...children.map((child) => _buildChildSummaryCard(child)).toList(),
          const SizedBox(height: 24),
          _buildWeeklyChart(),
          const SizedBox(height: 24),
          _buildAchievementsSection(),
        ],
      ),
    );
  }

  Widget _buildChildSummaryCard(Map<String, dynamic> child) {
    final progress = child['todayProgress'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildDetailPage(childData: child),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withValues(alpha: 0.2),
                        AppTheme.primaryBlue.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    child['avatar'],
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              child['name'],
                              style: TextStyle(
                                fontSize: ResponsiveHelper.adaptiveTextSize(
                                  context,
                                  16,
                                ),
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppTheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Umur ${child['age']} tahun',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.adaptiveTextSize(
                            context,
                            12,
                          ),
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: progress['streak'] >= 7
                        ? AppTheme.accentGreen.withValues(alpha: 0.1)
                        : AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: progress['streak'] >= 7
                            ? AppTheme.accentGreen
                            : AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${progress['streak']}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.adaptiveTextSize(
                            context,
                            12,
                          ),
                          fontWeight: FontWeight.bold,
                          color: progress['streak'] >= 7
                              ? AppTheme.accentGreen
                              : AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressItem(
                    'Sholat',
                    '${progress['sholat']}/${progress['totalSholat']}',
                    progress['sholat'] / progress['totalSholat'],
                    AppTheme.primaryBlue,
                    Icons.mosque_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProgressItem(
                    'Al-Qur\'an',
                    '${progress['quran']}/${progress['targetQuran']}',
                    progress['quran'] / progress['targetQuran'],
                    AppTheme.accentGreen,
                    Icons.menu_book_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProgressItem(
                    'Tahajud',
                    progress['tahajud'] ? 'Selesai' : 'Belum',
                    progress['tahajud'] ? 1.0 : 0.0,
                    Colors.purple,
                    Icons.nightlight_round,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    String label,
    String value,
    double progress,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.adaptiveTextSize(context, 11),
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.adaptiveTextSize(context, 12),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  // ========= Tab: Anak-anak =========

  Widget _buildChildrenTab() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Anak',
                style: TextStyle(
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              TextButton.icon(
                onPressed: _showAddChildDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tambah Anak'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid responsif
          GridView.builder(
            itemCount: children.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridCount(context),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: ResponsiveHelper.isSmallScreen(context)
                  ? 1.05
                  : 1.4,
            ),
            itemBuilder: (_, i) => _buildChildDetailCard(children[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildChildDetailCard(Map<String, dynamic> child) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildDetailPage(childData: child),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.accentGreen.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentGreen.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentGreen.withValues(alpha: 0.2),
                        AppTheme.accentGreen.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    child['avatar'],
                    color: AppTheme.accentGreen,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              child['name'],
                              style: TextStyle(
                                fontSize: ResponsiveHelper.adaptiveTextSize(
                                  context,
                                  18,
                                ),
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppTheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Umur ${child['age']} tahun',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.adaptiveTextSize(
                            context,
                            14,
                          ),
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppTheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Aktif ${_getTimeAgo(child['lastActive'])}',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.adaptiveTextSize(
                                context,
                                12,
                              ),
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: AppTheme.onSurfaceVariant,
                  ),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'detail',
                      child: Row(
                        children: [
                          Icon(Icons.analytics_rounded),
                          SizedBox(width: 8),
                          Text('Lihat Detail'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'reward',
                      child: Row(
                        children: [
                          Icon(Icons.card_giftcard_rounded),
                          SizedBox(width: 8),
                          Text('Kirim Reward'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings_rounded),
                          SizedBox(width: 8),
                          Text('Pengaturan'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) => _handleChildAction(child, value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Progress Minggu Ini',
              style: TextStyle(
                fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildWeeklyProgressChart(child['weeklyStats']),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressChart(Map<String, dynamic> stats) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      height: _chartHeight(context, base: 130),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final sholatProgress = stats['sholat'][index] / 5.0;
          final quranProgress = stats['quran'][index] / 3.0;
          final tahajudDone = stats['tahajud'][index];

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Tahajud indicator
              Container(
                width: 6,
                height: 8,
                decoration: BoxDecoration(
                  color: tahajudDone
                      ? Colors.purple
                      : Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 4),
              // Quran progress
              Container(
                width: 6,
                height: (30 * quranProgress).toDouble(),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 2),
              // Sholat progress
              Container(
                width: 6,
                height: (40 * sholatProgress).toDouble(),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: TextStyle(
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 10),
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ========= Tab: Notifikasi =========

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    for (var notification in notifications) {
                      notification['isRead'] = true;
                    }
                  });
                },
                child: const Text('Tandai Semua Dibaca'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...notifications
              .map((notification) => _buildNotificationCard(notification))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'];

    Color getTypeColor(String type) {
      switch (type) {
        case 'missed_prayer':
          return Colors.red;
        case 'achievement':
          return AppTheme.accentGreen;
        case 'quran_target':
          return AppTheme.primaryBlue;
        default:
          return Colors.grey;
      }
    }

    IconData getTypeIcon(String type) {
      switch (type) {
        case 'missed_prayer':
          return Icons.warning_rounded;
        case 'achievement':
          return Icons.emoji_events_rounded;
        case 'quran_target':
          return Icons.menu_book_rounded;
        default:
          return Icons.info_rounded;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead
            ? Colors.white
            : AppTheme.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? Colors.grey.withValues(alpha: 0.1)
              : AppTheme.primaryBlue.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: getTypeColor(notification['type']).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              getTypeIcon(notification['type']),
              color: getTypeColor(notification['type']),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['childName'],
                  style: TextStyle(
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 13),
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTimeAgo(notification['time']),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 11),
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }

  // ========= Grafik & Achievements =========

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.2),
                      AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Grafik Aktivitas Mingguan',
                style: TextStyle(
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildChartLegend(AppTheme.primaryBlue, 'Sholat'),
              _buildChartLegend(AppTheme.accentGreen, 'Al-Qur\'an'),
              _buildChartLegend(Colors.purple, 'Tahajud'),
            ],
          ),
          const SizedBox(height: 16),
          // Combined chart for all children
          Container(
            height: _chartHeight(context, base: 160),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (dayIndex) {
                final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

                double avgSholat = 0, avgQuran = 0;
                int tahajudCount = 0;

                for (var child in children) {
                  avgSholat += child['weeklyStats']['sholat'][dayIndex] / 5.0;
                  avgQuran += child['weeklyStats']['quran'][dayIndex] / 3.0;
                  if (child['weeklyStats']['tahajud'][dayIndex]) {
                    tahajudCount++;
                  }
                }

                avgSholat /= children.length;
                avgQuran /= children.length;
                final tahajudPercentage = tahajudCount / children.length;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Tahajud indicator
                    Container(
                      width: 8,
                      height: 12 * tahajudPercentage,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Quran progress
                    Container(
                      width: 8,
                      height: 50 * avgQuran,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Sholat progress
                    Container(
                      width: 8,
                      height: 60 * avgSholat,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[dayIndex],
                      style: TextStyle(
                        fontSize: ResponsiveHelper.adaptiveTextSize(
                          context,
                          11,
                        ),
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveHelper.adaptiveTextSize(context, 12),
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withValues(alpha: 0.2),
                      Colors.amber.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Pencapaian Terbaru',
                style: TextStyle(
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAchievementCard(
                  'Ahmad Faiz',
                  'Streak 7 Hari',
                  Icons.local_fire_department_rounded,
                  AppTheme.accentGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAchievementCard(
                  'Siti Aisyah',
                  'Sholat Tepat Waktu',
                  Icons.access_time_rounded,
                  AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    String name,
    String achievement,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: ResponsiveHelper.adaptiveTextSize(context, 13),
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            achievement,
            style: TextStyle(
              fontSize: ResponsiveHelper.adaptiveTextSize(context, 11),
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ========= FAB & Dialogs =========

  Widget _buildFloatingActionButton() {
    final isSmall = ResponsiveHelper.isSmallScreen(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isSmall
          ? FloatingActionButton(
              onPressed: _showRewardDialog,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 24,
              ),
            )
          : FloatingActionButton.extended(
              onPressed: _showRewardDialog,
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(
                Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 24,
              ),
              label: Text(
                'Kirim Reward',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
                ),
              ),
            ),
    );
  }

  void _showAddChildDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Tambah Anak',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.adaptiveTextSize(context, 18),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nama Anak',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Umur',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anak berhasil ditambahkan')),
                );
              },
              child: const Text(
                'Tambah',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Kirim Reward',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.adaptiveTextSize(context, 18),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Pilih Anak',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: children.map((child) {
                return DropdownMenuItem<String>(
                  value: child['id'] as String,
                  child: Text(child['name'] as String),
                );
              }).toList(),
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Pesan Semangat',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.card_giftcard_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('Reward berhasil dikirim!')),
                      ],
                    ),
                    backgroundColor: AppTheme.accentGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              child: const Text('Kirim', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleChildAction(Map<String, dynamic> child, String action) {
    switch (action) {
      case 'detail':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildDetailPage(childData: child),
          ),
        );
        break;
      case 'reward':
        _showRewardDialog();
        break;
      case 'settings':
        _showChildSettingsDialog(child);
        break;
    }
  }

  void _showChildSettingsDialog(Map<String, dynamic> child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Pengaturan ${child['name']}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.adaptiveTextSize(context, 18),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Notifikasi Sholat'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Notifikasi Al-Qur\'an'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Laporan Harian'),
              value: false,
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pengaturan berhasil disimpan')),
                );
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========= Utils =========

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${difference.inDays} hari lalu';
    }
  }
}
