import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/connection/connection_provider.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/widgets/toast.dart';
import 'package:test_flutter/features/auth/auth_provider.dart';
import 'package:test_flutter/features/puasa/puasa_provider.dart';
import 'package:test_flutter/features/puasa/puasa_state.dart';

class RamadhanDetailPage extends ConsumerStatefulWidget {
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
  ConsumerState<RamadhanDetailPage> createState() => _RamadhanDetailPageState();
}

class _RamadhanDetailPageState extends ConsumerState<RamadhanDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late int _currentHijriYear;
  int _ramadhanDaysInSelectedYear = 30;
  DateTime? _ramadhanStartDate;

  var progresPuasaWajib = {};
  var total = 0;

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
    _tabController = TabController(length: 2, vsync: this);
    _initializeHijriYear();

    final current = ref.read(puasaProvider);
    if (current.progresPuasaWajibTahunIni != null) {
      total = current.progresPuasaWajibTahunIni!.total;
      progresPuasaWajib = current.progresPuasaWajibTahunIni!.detail;
    }
  }

  void _initializeHijriYear() {
    final now = HijriCalendar.now();
    _currentHijriYear = now.hYear;
    _calculateRamadhanDetails(_currentHijriYear);
  }

  void _calculateRamadhanDetails(int hijriYear) {
    // Set Ramadhan month (month 9 in Hijri calendar)
    final ramadhanHijri = HijriCalendar()
      ..hYear = hijriYear
      ..hMonth = 9
      ..hDay = 1;

    _ramadhanStartDate = ramadhanHijri.hijriToGregorian(
      ramadhanHijri.hYear,
      ramadhanHijri.hMonth,
      ramadhanHijri.hDay,
    );

    // Calculate days in Ramadhan for this year (29 or 30)
    final lastDayRamadhan = HijriCalendar()
      ..hYear = hijriYear
      ..hMonth = 9
      ..hDay = 30;

    try {
      lastDayRamadhan.hijriToGregorian(
        lastDayRamadhan.hYear,
        lastDayRamadhan.hMonth,
        lastDayRamadhan.hDay,
      );
      _ramadhanDaysInSelectedYear = 30;
    } catch (e) {
      _ramadhanDaysInSelectedYear = 29;
    }
  }

  // Check if a specific day is completed
  bool _isDayCompleted(int day) {
    final dayKey = day.toString();

    return progresPuasaWajib[dayKey] ?? false;
  }

  // Get total completed days
  int _getCompletedDays() {
    final puasaState = ref.watch(puasaProvider);
    return puasaState.progresPuasaWajibTahunIni?.total ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;
    final connectionState = ref.watch(connectionProvider);
    final isOffline = !connectionState.isOnline;
    final puasaState = ref.watch(puasaProvider);
    final completedDays = _getCompletedDays();

    // Show loading while fetching data
    if (puasaState.status == PuasaStatus.loading &&
        puasaState.progresPuasaWajibTahunIni == null) {
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat data...',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Listen to auth state
    ref.listen(authProvider, (previous, next) {
      if (previous?['status'] != next['status']) {
        if (next['status'] != AuthState.authenticated && mounted) {
          showMessageToast(
            context,
            message: 'Sesi berakhir. Silakan login kembali.',
            type: ToastType.warning,
          );
        }
      }
    });

    // Listen to puasa state for updates
    ref.listen(puasaProvider, (previous, next) {
      // Handle loading state
      if (next.status == PuasaStatus.loading &&
          previous?.status != PuasaStatus.loading) {
        // Loading started - dialog already shown in _markRamadhanFasting
      }

      // Handle success state
      if (next.status == PuasaStatus.success &&
          previous?.status == PuasaStatus.loading) {


        // Show success message
        if (mounted && next.message != null) {
          showMessageToast(
            context,
            message: next.message!,
            type: ToastType.success,
          );
        }

        // Update local state
        if (next.progresPuasaWajibTahunIni != null) {
          setState(() {
            progresPuasaWajib = next.progresPuasaWajibTahunIni!.detail;
            total = next.progresPuasaWajibTahunIni!.total;
          });
        }
      }

      // Handle error state
      if (next.status == PuasaStatus.error &&
          previous?.status == PuasaStatus.loading) {
        // Show error message
        if (mounted && next.message != null) {
          showMessageToast(
            context,
            message: next.message!,
            type: ToastType.error,
          );
        }
      }
    });

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
                              'Puasa Ramadhan $_currentHijriYear H',
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
                      // Offline Badge
                      if (isOffline)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 12 : 10,
                            vertical: isTablet ? 6 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
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

              SizedBox(height: isTablet ? 16 : 12),

              // Progress Summary Cards
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
                      '$completedDays',
                      '$_ramadhanDaysInSelectedYear',
                      'Completed',
                      AppTheme.accentGreen,
                      Icons.check_circle_rounded,
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 12 : 10),
                    _buildProgressCard(
                      '${_ramadhanDaysInSelectedYear - completedDays}',
                      '$_ramadhanDaysInSelectedYear',
                      'Tersisa',
                      AppTheme.primaryBlue,
                      Icons.schedule_rounded,
                      isTablet,
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
                    Tab(text: 'Kalender'),
                    Tab(text: 'Amalan Sunnah'),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // TabView Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildRamadhanCalendar(), _buildSunnahTab()],
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
          // Calendar Header
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
                  'Ramadhan $_currentHijriYear H ($_ramadhanDaysInSelectedYear hari)',
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

          // Calendar Grid
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
                itemCount: _ramadhanDaysInSelectedYear,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final isCompleted = _isDayCompleted(day);
                  final isToday = () {
                    if (_ramadhanStartDate == null) return false;
                    final today = DateTime.now();
                    final ramadhanDayDate = DateTime(
                      _ramadhanStartDate!.year,
                      _ramadhanStartDate!.month,
                      _ramadhanStartDate!.day + index,
                    );
                    return today.year == ramadhanDayDate.year &&
                        today.month == ramadhanDayDate.month &&
                        today.day == ramadhanDayDate.day;
                  }();

                  return GestureDetector(
                    onTap: () => _showDayDetail(day, isCompleted),
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

  void _showDayDetail(int day, bool isCompleted) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final authState = ref.read(authProvider);
    final isAuthenticated = authState['status'] == AuthState.authenticated;
    final connectionState = ref.read(connectionProvider);
    final isOffline = !connectionState.isOnline;

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
              'Hari ke-$day Ramadhan $_currentHijriYear H',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Container(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCompleted
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
                      (isCompleted
                              ? AppTheme.accentGreen
                              : AppTheme.primaryBlue)
                          .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.event_available_outlined,
                    color: isCompleted
                        ? AppTheme.accentGreen
                        : AppTheme.onSurfaceVariant,
                    size: isTablet ? 36 : 32,
                  ),
                  SizedBox(height: isTablet ? 12 : 10),
                  Text(
                    isCompleted
                        ? 'Puasa Completed!'
                        : 'Belum ada aktivitas puasa',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? AppTheme.onSurface
                          : AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isTablet ? 24 : 20),

            if (!isCompleted) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isOffline || !isAuthenticated
                          ? null
                          : () {
                              Navigator.pop(context);
                              if (!isAuthenticated) {
                                showMessageToast(
                                  context,
                                  message: 'Anda harus login terlebih dahulu',
                                  type: ToastType.error,
                                );
                              } else if (isOffline) {
                                showMessageToast(
                                  context,
                                  message:
                                      'Tidak dapat menambah progress saat offline',
                                  type: ToastType.error,
                                );
                              } else {
                                _markRamadhanFasting(day);
                              }
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
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
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

  void _markRamadhanFasting(int day) async {
    final authState = ref.read(authProvider);
    final connectionState = ref.read(connectionProvider);

    if (authState['status'] != AuthState.authenticated) {
      showMessageToast(
        context,
        message: 'Anda harus login terlebih dahulu',
        type: ToastType.error,
      );
      return;
    }

    if (!connectionState.isOnline) {
      showMessageToast(
        context,
        message: 'Tidak dapat menambah progress saat offline',
        type: ToastType.error,
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
              SizedBox(height: 16),
              Text(
                'Menyimpan progress...',
                style: TextStyle(color: AppTheme.onSurface, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Call the API to add progress
      await ref
          .read(puasaProvider.notifier)
          .addProgresPuasaWajib(tanggalRamadhan: day.toString());

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Get state after operation
      final puasaState = ref.read(puasaProvider);

      // Show message from provider
      if (mounted) {
        if (puasaState.status == PuasaStatus.success) {
          // Update local state
          setState(() {
            if (puasaState.progresPuasaWajibTahunIni != null) {
              progresPuasaWajib = puasaState.progresPuasaWajibTahunIni!.detail;
              total = puasaState.progresPuasaWajibTahunIni!.total;
            }
          });
        }
      }

    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }
}
