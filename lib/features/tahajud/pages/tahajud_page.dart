import 'package:flutter/material.dart';
import 'package:test_flutter/app/router.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:intl/intl.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/core/widgets/toast.dart';

class TahajudPage extends StatefulWidget {
  const TahajudPage({super.key});

  @override
  State<TahajudPage> createState() => _TahajudPageState();
}

class _TahajudPageState extends State<TahajudPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // Authentication & Premium status
  bool isAuthenticated = true; // Set to true when user is logged in
  bool isPremium = false; // Set to true when user has premium subscription

  // Challenge data
  int currentStreak = 7;
  int longestStreak = 15;
  int totalDays = 45;
  int currentLevel = 3;
  int tahajudCount = 45;
  bool todayCompleted = false;

  // Monthly tahajud count
  int monthlyTahajudCount = 12;

  // Calendar data - tahajud completed dates
  final Set<DateTime> completedDates = {
    DateTime(2025, 10, 24),
    DateTime(2025, 10, 25),
    DateTime(2025, 10, 27),
    DateTime(2025, 10, 28),
    DateTime(2025, 10, 22),
    DateTime(2025, 10, 20),
    DateTime(2025, 10, 18),
    DateTime(2025, 10, 16),
    DateTime(2025, 10, 15),
    DateTime(2025, 10, 13),
    DateTime(2025, 10, 11),
    DateTime(2025, 10, 10),
  };

  DateTime selectedMonth = DateTime.now();
  PageController calendarPageController = PageController();

  // Available badges
  final List<Map<String, dynamic>> badges = [
    {
      'id': 'first_step',
      'name': 'Langkah Pertama',
      'description': 'Lakukan tahajud pertama kali',
      'icon': Icons.star_rounded,
      'color': Colors.amber,
      'achieved': true,
      'date': DateTime(2025, 8, 15),
    },
    {
      'id': 'week_warrior',
      'name': 'Pejuang Seminggu',
      'description': 'Tahajud 7 hari berturut-turut',
      'icon': Icons.military_tech_rounded,
      'color': Colors.blue,
      'achieved': true,
      'date': DateTime(2025, 9, 10),
    },
    {
      'id': 'night_guardian',
      'name': 'Penjaga Malam',
      'description': 'Tahajud 30 hari dalam sebulan',
      'icon': Icons.shield_rounded,
      'color': Colors.purple,
      'achieved': false,
    },
    {
      'id': 'consistent_soul',
      'name': 'Jiwa Istiqomah',
      'description': 'Tahajud 100 hari total',
      'icon': Icons.psychology_rounded,
      'color': Colors.green,
      'achieved': false,
    },
    {
      'id': 'diamond_devotee',
      'name': 'Berlian Ibadah',
      'description': 'Tahajud 365 hari total',
      'icon': Icons.diamond_rounded,
      'color': Colors.cyan,
      'achieved': false,
    },
  ];

  // Challenge levels
  final List<Map<String, dynamic>> levels = [
    {'level': 1, 'name': 'Pemula', 'minDays': 0, 'color': Colors.grey},
    {'level': 2, 'name': 'Pembelajar', 'minDays': 7, 'color': Colors.blue},
    {'level': 3, 'name': 'Pejuang', 'minDays': 30, 'color': Colors.purple},
    {'level': 4, 'name': 'Ahli', 'minDays': 100, 'color': Colors.orange},
    {'level': 5, 'name': 'Master', 'minDays': 365, 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: currentStreak / 30.0)
        .animate(
          CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
        );

    _progressController.forward();
    _calculateMonthlyTahajud();
  }

  void _calculateMonthlyTahajud() {
    final now = DateTime.now();
    monthlyTahajudCount = completedDates.where((date) {
      return date.year == now.year && date.month == now.month;
    }).length;
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  // ===================== Responsive helpers =====================

  Widget _wrapMaxWidth(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: child,
      ),
    );
  }

  double _calendarCellSize(BuildContext context) {
    final w = ResponsiveHelper.getScreenWidth(context);
    if (ResponsiveHelper.isSmallScreen(context)) {
      return (w - 24 - 24) / 7 - 6;
    }
    if (ResponsiveHelper.isMediumScreen(context)) return (w - 24 - 24) / 7 - 2;
    return 44;
  }

  EdgeInsets _outerHMargin(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: ResponsiveHelper.isSmallScreen(context) ? 16 : 24,
    );
  }

  Widget _responsiveFAB({
    required bool disabled,
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required List<Color> gradient,
  }) {
    final isSmall = ResponsiveHelper.isSmallScreen(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (disabled ? Colors.grey : AppTheme.primaryBlue).withValues(
              alpha: 0.4,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isSmall
          ? FloatingActionButton(
              onPressed: disabled ? null : onPressed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(icon, color: Colors.white, size: 24),
            )
          : FloatingActionButton.extended(
              onPressed: disabled ? null : onPressed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: Icon(icon, color: Colors.white, size: 24),
              label: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
                ),
              ),
            ),
    );
  }

  void _markTodayComplete() {
    if (!todayCompleted && isPremium) {
      setState(() {
        todayCompleted = true;
        currentStreak++;
        tahajudCount++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
        final now = DateTime.now();
        completedDates.add(DateTime(now.year, now.month, now.day));
        _calculateMonthlyTahajud();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Alhamdulillah! Tahajud hari ini berhasil dicatat',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 15),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAuthenticated) return _buildLoginRequired();
    if (!isPremium) return _buildPremiumRequired();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.05),
              AppTheme.backgroundWhite,
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: _wrapMaxWidth(
              Column(
                children: [
                  _buildHeader(),
                  _buildStreakCard(),
                  _buildCalendarSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // ===================== Header =====================

  Widget _buildHeader() {
    return Container(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Back button di kiri
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue.withValues(
                      alpha: 0.1,
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              // Title di tengah
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBlue.withValues(alpha: 0.15),
                              AppTheme.accentGreen.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.nightlight_round,
                          color: AppTheme.primaryBlue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tahajud Challenge',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.adaptiveTextSize(
                            context,
                            24,
                          ),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bangun di malam hari untuk beribadah',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.adaptiveTextSize(
                            context,
                            14,
                          ),
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Premium badge di kanan
              if (isPremium)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Quote Card
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
            child: Column(
              children: [
                Text(
                  'وَمِنَ اللَّيْلِ فَتَهَجَّدْ بِهِ نَافِلَةً لَّكَ',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
                    fontWeight: FontWeight.w600,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '"Dan pada sebagian malam, maka lakukanlah shalat tahajud sebagai suatu ibadah tambahan bagimu"',
                  style: TextStyle(
                    color: AppTheme.onSurface.withValues(alpha: 0.8),
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 13),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'QS. Al-Isra: 79',
                  style: TextStyle(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 12),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Auth & Premium =====================

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
                    'Anda harus login terlebih dahulu untuk mengakses Tahajud Challenge',
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
                      Icons.nightlight_round,
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
                    'Tahajud Challenge adalah fitur premium. Tingkatkan ibadah malam Anda dengan fitur tracking dan reward!',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
                      color: AppTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildPremiumFeature(
                    Icons.trending_up_rounded,
                    'Tracking streak dan progress',
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumFeature(
                    Icons.calendar_month_rounded,
                    'Kalender tahajud lengkap',
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumFeature(
                    Icons.emoji_events_rounded,
                    'Badge dan achievement',
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumFeature(
                    Icons.notifications_active_rounded,
                    'Reminder tahajud otomatis',
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
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Kembali',
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

  // ===================== Streak Card (Redesigned) =====================

  Widget _buildStreakCard() {
    return Container(
      margin: _outerHMargin(context).add(const EdgeInsets.only(top: 20)),
      padding: EdgeInsets.all(
        ResponsiveHelper.isSmallScreen(context) ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
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
        children: [
          // Icon dan Streak
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.2),
                      AppTheme.accentGreen.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: AppTheme.primaryBlue,
                  size: ResponsiveHelper.isSmallScreen(context) ? 24 : 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Streak Saat Ini',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.adaptiveTextSize(
                          context,
                          13,
                        ),
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$currentStreak',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.adaptiveTextSize(
                              context,
                              32,
                            ),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'hari berturut-turut',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.adaptiveTextSize(
                                context,
                                13,
                              ),
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStreakStat(
                  Icons.calendar_today_rounded,
                  'Total Tahajud',
                  '$tahajudCount hari',
                  AppTheme.primaryBlue,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _buildStreakStat(
                  Icons.calendar_month_rounded,
                  'Bulan Ini',
                  '$monthlyTahajudCount hari',
                  AppTheme.accentGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStat(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveHelper.adaptiveTextSize(context, 11),
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveHelper.adaptiveTextSize(context, 15),
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ===================== Calendar =====================

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.all(24),
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
      child: _wrapMaxWidth(
        Column(
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
                    Icons.calendar_month_rounded,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Kalender Tahajud',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCalendarHeader(),
            const SizedBox(height: 16),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              selectedMonth = DateTime(
                selectedMonth.year,
                selectedMonth.month - 1,
              );
              _calculateMonthlyTahajud();
            });
          },
          icon: Icon(Icons.chevron_left_rounded, color: AppTheme.primaryBlue),
        ),
        Text(
          DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth),
          style: TextStyle(
            fontSize: ResponsiveHelper.adaptiveTextSize(context, 18),
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              selectedMonth = DateTime(
                selectedMonth.year,
                selectedMonth.month + 1,
              );
              _calculateMonthlyTahajud();
            });
          },
          icon: Icon(Icons.chevron_right_rounded, color: AppTheme.primaryBlue),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final daysOfWeek = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final cell = _calendarCellSize(context);

    return Column(
      children: [
        // Header with day names
        Row(
          children: daysOfWeek.map((day) {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 12),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        ...List.generate((daysInMonth + firstDayWeekday - 1 + 6) ~/ 7, (
          weekIndex,
        ) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber =
                    weekIndex * 7 + dayIndex - firstDayWeekday + 2;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }

                final currentDate = DateTime(
                  selectedMonth.year,
                  selectedMonth.month,
                  dayNumber,
                );
                final isCompleted = completedDates.contains(
                  DateTime(
                    currentDate.year,
                    currentDate.month,
                    currentDate.day,
                  ),
                );
                final now = DateTime.now();
                final isToday =
                    now.year == currentDate.year &&
                    now.month == currentDate.month &&
                    now.day == currentDate.day;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isCompleted) {
                          completedDates.removeWhere(
                            (date) =>
                                date.year == currentDate.year &&
                                date.month == currentDate.month &&
                                date.day == currentDate.day,
                          );
                        } else {
                          completedDates.add(
                            DateTime(
                              currentDate.year,
                              currentDate.month,
                              currentDate.day,
                            ),
                          );
                        }
                        _calculateMonthlyTahajud();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      height: cell,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.accentGreen
                            : isToday
                            ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: AppTheme.primaryBlue, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.adaptiveTextSize(
                                  context,
                                  14,
                                ),
                                fontWeight: FontWeight.w500,
                                color: isCompleted
                                    ? Colors.white
                                    : isToday
                                    ? AppTheme.primaryBlue
                                    : AppTheme.onSurface,
                              ),
                            ),
                            if (isCompleted)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: ResponsiveHelper.isSmallScreen(context)
                                      ? 14
                                      : 16,
                                  height:
                                      ResponsiveHelper.isSmallScreen(context)
                                      ? 14
                                      : 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size:
                                        ResponsiveHelper.isSmallScreen(context)
                                        ? 10
                                        : 12,
                                    color: AppTheme.accentGreen,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 8,
          children: [
            _buildCalendarLegend(AppTheme.accentGreen, 'Tahajud dilakukan'),
            _buildCalendarLegend(
              AppTheme.primaryBlue.withValues(alpha: 0.3),
              'Hari ini',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarLegend(Color color, String label) {
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
          ),
        ),
      ],
    );
  }

  // ===================== FAB =====================

  Widget _buildFloatingActionButton() {
    return _responsiveFAB(
      disabled: todayCompleted,
      onPressed: _markTodayComplete,
      icon: todayCompleted ? Icons.check_circle_rounded : Icons.add_rounded,
      label: todayCompleted ? 'Selesai' : 'Catat Tahajud',
      gradient: todayCompleted
          ? [Colors.grey, Colors.grey.shade400]
          : [AppTheme.primaryBlue, AppTheme.accentGreen],
    );
  }
}
