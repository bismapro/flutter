import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/core/widgets/toast.dart';

class SholatPage extends StatefulWidget {
  const SholatPage({super.key});

  @override
  State<SholatPage> createState() => _SholatPageState();
}

class _SholatPageState extends State<SholatPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late Animation<Color?> _headerColorAnimation;
  DateTime selectedDate = DateTime.now();

  // ---------- Responsive utils ----------
  double _scale(BuildContext c) {
    if (ResponsiveHelper.isSmallScreen(c)) return .9;
    if (ResponsiveHelper.isMediumScreen(c)) return 1.0;
    if (ResponsiveHelper.isLargeScreen(c)) return 1.1;
    return 1.2;
  }

  double _px(BuildContext c, double base) => base * _scale(c);
  double _ts(BuildContext c, double base) =>
      ResponsiveHelper.adaptiveTextSize(c, base);

  EdgeInsets _hpad(BuildContext c) => EdgeInsets.symmetric(
    horizontal: ResponsiveHelper.getResponsivePadding(c).left,
  );

  double _maxWidth(BuildContext c) {
    if (ResponsiveHelper.isExtraLargeScreen(c)) return 980;
    if (ResponsiveHelper.isLargeScreen(c)) return 860;
    return double.infinity;
  }

  // ---------- Data ----------
  final Map<String, Map<String, dynamic>> _sholatWajibData = {
    'Subuh': {
      'time': '04:13',
      'completed': false,
      'alarmActive': false,
      'icon': Icons.wb_sunny_outlined,
      'tepatWaktu': false,
      'berjamaah': false,
      'tempat': '',
    },
    'Dzuhur': {
      'time': '11:37',
      'completed': false,
      'alarmActive': true,
      'icon': Icons.wb_sunny,
      'tepatWaktu': false,
      'berjamaah': false,
      'tempat': '',
    },
    'Ashar': {
      'time': '14:44',
      'completed': false,
      'alarmActive': false,
      'icon': Icons.wb_cloudy,
      'tepatWaktu': false,
      'berjamaah': false,
      'tempat': '',
    },
    'Maghrib': {
      'time': '17:41',
      'completed': false,
      'alarmActive': false,
      'icon': Icons.wb_twilight,
      'tepatWaktu': false,
      'berjamaah': false,
      'tempat': '',
    },
    'Isya': {
      'time': '18:50',
      'completed': false,
      'alarmActive': false,
      'icon': Icons.nights_stay,
      'tepatWaktu': false,
      'berjamaah': false,
      'tempat': '',
    },
  };

  final Map<String, Map<String, dynamic>> _sholatSunnahData = {
    'Tahajud': {
      'time': '03:00 - 05:00',
      'completed': false,
      'icon': Icons.bedtime_outlined,
    },
    'Dhuha': {
      'time': '07:00 - 11:00',
      'completed': false,
      'icon': Icons.wb_sunny_outlined,
    },
    'Qabliyah Subuh': {
      'time': '05:00 - 05:30',
      'completed': false,
      'icon': Icons.wb_sunny_outlined,
    },
    'Qabliyah Dzuhur': {
      'time': '12:00 - 12:15',
      'completed': false,
      'icon': Icons.wb_sunny_outlined,
    },
    'Ba\'diyah Dzuhur': {
      'time': '12:45 - 15:30',
      'completed': false,
      'icon': Icons.wb_sunny_outlined,
    },
    'Qabliyah Ashar': {
      'time': '15:00 - 15:30',
      'completed': false,
      'icon': Icons.wb_cloudy_outlined,
    },
    'Ba\'diyah Maghrib': {
      'time': '18:45 - 19:30',
      'completed': false,
      'icon': Icons.wb_twilight_outlined,
    },
    'Qabliyah Isya': {
      'time': '19:30 - 19:45',
      'completed': false,
      'icon': Icons.nights_stay_outlined,
    },
    'Ba\'diyah Isya': {
      'time': '20:15 - 23:00',
      'completed': false,
      'icon': Icons.nights_stay_outlined,
    },
    'Witir': {
      'time': '20:00 - 05:00',
      'completed': false,
      'icon': Icons.nights_stay_outlined,
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Animation controller untuk transisi warna header
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Color tween animation
    _updateHeaderColorAnimation();

    _tabController.addListener(() {
      // Update animasi saat tab berubah
      if (_tabController.indexIsChanging) {
        _updateHeaderColorAnimation();
        if (_tabController.index == 0) {
          _headerAnimationController.reverse();
        } else {
          _headerAnimationController.forward();
        }
      }
      setState(() {}); // Rebuild untuk update progress
    });
  }

  void _updateHeaderColorAnimation() {
    _headerColorAnimation =
        ColorTween(
          begin: AppTheme.primaryBlue,
          end: AppTheme.accentGreen,
        ).animate(
          CurvedAnimation(
            parent: _headerAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  int get completedWajibCount =>
      _sholatWajibData.values.where((d) => d['completed'] == true).length;

  int get completedSunnahCount =>
      _sholatSunnahData.values.where((d) => d['completed'] == true).length;

  int get totalWajib => _sholatWajibData.length;

  int get totalSunnah => _sholatSunnahData.length;

  bool get isWajibTab => _tabController.index == 0;

  String get formattedDate {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${selectedDate.day} ${months[selectedDate.month - 1]} ${selectedDate.year}';
  }

  String get dayName {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[selectedDate.weekday - 1];
  }

  String get hijriDate {
    try {
      // Gunakan package hijri untuk konversi akurat
      final hijri = HijriCalendar.fromDate(selectedDate);

      logger.fine('Hijri Date: ${hijri.toString()}');

      const hijriMonths = [
        'Muharram',
        'Safar',
        'Rabiul Awal',
        'Rabiul Akhir',
        'Jumadil Awal',
        'Jumadil Akhir',
        'Rajab',
        "Sya'ban",
        'Ramadan',
        'Syawal',
        "Dzulqa'dah",
        'Dzulhijjah',
      ];

      return '${hijri.hDay} ${hijriMonths[hijri.hMonth - 1]} ${hijri.hYear} H';
    } catch (e) {
      return 'Tanggal Hijriah';
    }
  }

  bool get isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxWidth(context)),
            child: Column(
              children: [
                _buildCompactHeader(context),
                Expanded(child: _buildPrayerTimesList(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    final small = ResponsiveHelper.isSmallScreen(context);
    final currentCompleted = isWajibTab
        ? completedWajibCount
        : completedSunnahCount;
    final currentTotal = isWajibTab ? totalWajib : totalSunnah;

    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        final progressColor =
            _headerColorAnimation.value ?? AppTheme.primaryBlue;

        return Container(
          margin: _hpad(context).add(
            EdgeInsets.only(top: _px(context, 12), bottom: _px(context, 16)),
          ),
          padding: EdgeInsets.all(_px(context, small ? 16 : 20)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [progressColor, progressColor.withValues(alpha: 0.85)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: progressColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Date navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _compactBtn(
                    context,
                    icon: Icons.chevron_left_rounded,
                    onTap: () => setState(
                      () => selectedDate = selectedDate.subtract(
                        const Duration(days: 1),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          isToday ? 'Hari ini' : dayName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _ts(context, small ? 14 : 16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: _px(context, 2)),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: _ts(context, small ? 12 : 13),
                          ),
                        ),
                        Text(
                          hijriDate,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: _ts(context, small ? 11 : 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _compactBtn(
                    context,
                    icon: Icons.chevron_right_rounded,
                    onTap: () => setState(
                      () => selectedDate = selectedDate.add(
                        const Duration(days: 1),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: _px(context, 16)),
              Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
              SizedBox(height: _px(context, 16)),

              // Location & Current Prayer Time
              Row(
                children: [
                  // Location
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: _px(context, 14),
                            ),
                            SizedBox(width: _px(context, 4)),
                            Text(
                              'Purwokerto',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: _ts(context, small ? 11 : 12),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: _px(context, 8)),
                        Text(
                          'Dzuhur',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _ts(context, small ? 16 : 18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '11:37',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _ts(context, small ? 22 : 26),
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: _px(context, 4)),
                        Text(
                          'Ashar dalam 2j 25m',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: _ts(context, small ? 10 : 11),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Circle - Animated
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _px(context, small ? 90 : 100),
                    height: _px(context, small ? 90 : 100),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              '$currentCompleted',
                              key: ValueKey<int>(currentCompleted),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _ts(context, small ? 32 : 36),
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                          ),
                          SizedBox(height: _px(context, 2)),
                          Text(
                            '/ $currentTotal',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: _ts(context, small ? 14 : 16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: _px(context, 4)),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              isWajibTab ? 'Wajib' : 'Sunnah',
                              key: ValueKey<bool>(isWajibTab),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: _ts(context, small ? 10 : 11),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _compactBtn(
    BuildContext c, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.all(_px(c, 8)),
          child: Icon(icon, color: Colors.white, size: _px(c, 20)),
        ),
      ),
    );
  }

  Widget _buildPrayerTimesList(BuildContext context) {
    final small = ResponsiveHelper.isSmallScreen(context);

    return Column(
      children: [
        // Tabs
        Container(
          margin: _hpad(context).add(EdgeInsets.only(top: _px(context, 12))),
          padding: EdgeInsets.all(_px(context, 4)),
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
              fontSize: _ts(context, small ? 13 : 14),
            ),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Wajib'),
              Tab(text: 'Sunnah'),
            ],
          ),
        ),

        SizedBox(height: _px(context, 16)),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildWajibTab(context), _buildSunnahTab(context)],
          ),
        ),
      ],
    );
  }

  // ...existing code... (buildWajibTab, buildSunnahTab, dll - sama seperti sebelumnya)
  Widget _buildWajibTab(BuildContext context) {
    final small = ResponsiveHelper.isSmallScreen(context);

    return ListView.builder(
      padding: _hpad(context).add(EdgeInsets.only(bottom: _px(context, 16))),
      physics: const BouncingScrollPhysics(),
      itemCount: _sholatWajibData.length,
      itemBuilder: (_, i) {
        final name = _sholatWajibData.keys.elementAt(i);
        final d = _sholatWajibData[name]!;
        final done = d['completed'] as bool;

        return Container(
          margin: EdgeInsets.only(bottom: _px(context, 8)),
          decoration: BoxDecoration(
            color: done
                ? AppTheme.primaryBlue.withValues(alpha: 0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: done
                  ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                  : Colors.grey.shade200,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (!done) {
                  _showSholatDetailModal(context, name, d);
                } else {
                  setState(() {
                    d['completed'] = false;
                    d['tepatWaktu'] = false;
                    d['berjamaah'] = false;
                    d['tempat'] = '';
                  });
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _px(context, small ? 14 : 16),
                  vertical: _px(context, small ? 12 : 14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: _px(context, 22),
                      height: _px(context, 22),
                      decoration: BoxDecoration(
                        color: done ? AppTheme.primaryBlue : Colors.transparent,
                        border: Border.all(
                          color: done
                              ? AppTheme.primaryBlue
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: done
                          ? Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: _px(context, 14),
                            )
                          : null,
                    ),
                    SizedBox(width: _px(context, 12)),
                    Container(
                      width: _px(context, 40),
                      height: _px(context, 40),
                      decoration: BoxDecoration(
                        color: done
                            ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                            : AppTheme.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        d['icon'],
                        color: AppTheme.primaryBlue,
                        size: _px(context, 20),
                      ),
                    ),
                    SizedBox(width: _px(context, 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: _ts(context, small ? 14 : 15),
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          SizedBox(height: _px(context, 2)),
                          Text(
                            d['time'],
                            style: TextStyle(
                              fontSize: _ts(context, small ? 12 : 13),
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: (d['alarmActive'] as bool)
                          ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => setState(
                          () => d['alarmActive'] = !(d['alarmActive'] as bool),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: EdgeInsets.all(_px(context, 8)),
                          child: Icon(
                            (d['alarmActive'] as bool)
                                ? Icons.alarm_on_rounded
                                : Icons.alarm_rounded,
                            color: (d['alarmActive'] as bool)
                                ? AppTheme.primaryBlue
                                : Colors.grey.shade500,
                            size: _px(context, 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSunnahTab(BuildContext context) {
    final small = ResponsiveHelper.isSmallScreen(context);

    return ListView.builder(
      padding: _hpad(context).add(EdgeInsets.only(bottom: _px(context, 16))),
      physics: const BouncingScrollPhysics(),
      itemCount: _sholatSunnahData.length,
      itemBuilder: (_, i) {
        final name = _sholatSunnahData.keys.elementAt(i);
        final d = _sholatSunnahData[name]!;
        final done = d['completed'] as bool;

        return Container(
          margin: EdgeInsets.only(bottom: _px(context, 8)),
          decoration: BoxDecoration(
            color: done
                ? AppTheme.accentGreen.withValues(alpha: 0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: done
                  ? AppTheme.accentGreen.withValues(alpha: 0.15)
                  : Colors.grey.shade200,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => d['completed'] = !done);
                if (!done) _showCompletionFeedback(name);
              },
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _px(context, small ? 14 : 16),
                  vertical: _px(context, small ? 12 : 14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: _px(context, 22),
                      height: _px(context, 22),
                      decoration: BoxDecoration(
                        color: done ? AppTheme.accentGreen : Colors.transparent,
                        border: Border.all(
                          color: done
                              ? AppTheme.accentGreen
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: done
                          ? Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: _px(context, 14),
                            )
                          : null,
                    ),
                    SizedBox(width: _px(context, 12)),
                    Container(
                      width: _px(context, 40),
                      height: _px(context, 40),
                      decoration: BoxDecoration(
                        color: done
                            ? AppTheme.accentGreen.withValues(alpha: 0.15)
                            : AppTheme.accentGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        d['icon'],
                        color: AppTheme.accentGreen,
                        size: _px(context, 20),
                      ),
                    ),
                    SizedBox(width: _px(context, 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: _ts(context, small ? 14 : 15),
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          SizedBox(height: _px(context, 2)),
                          Text(
                            d['time'],
                            style: TextStyle(
                              fontSize: _ts(context, small ? 11 : 12),
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSholatDetailModal(
    BuildContext context,
    String sholatName,
    Map<String, dynamic> data,
  ) {
    bool tepatWaktu = false;
    bool berjamaah = false;
    String tempat = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          data['icon'],
                          color: AppTheme.primaryBlue,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sholat $sholatName',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            Text(
                              data['time'],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Tepat Waktu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionButton(
                          context: context,
                          label: 'Ya',
                          icon: Icons.check_circle_outline_rounded,
                          isSelected: tepatWaktu,
                          onTap: () =>
                              setModalState(() => tepatWaktu = !tepatWaktu),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionButton(
                          context: context,
                          label: 'Tidak',
                          icon: Icons.cancel_outlined,
                          isSelected: !tepatWaktu && tempat.isNotEmpty,
                          onTap: () =>
                              setModalState(() => tepatWaktu = !tepatWaktu),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Berjamaah',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionButton(
                          context: context,
                          label: 'Ya',
                          icon: Icons.groups_rounded,
                          isSelected: berjamaah,
                          onTap: () =>
                              setModalState(() => berjamaah = !berjamaah),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionButton(
                          context: context,
                          label: 'Tidak',
                          icon: Icons.person_rounded,
                          isSelected: !berjamaah && tempat.isNotEmpty,
                          onTap: () =>
                              setModalState(() => berjamaah = !berjamaah),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tempat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPlaceChip(
                        context: context,
                        label: 'Masjid',
                        icon: Icons.mosque_rounded,
                        isSelected: tempat == 'Masjid',
                        onTap: () => setModalState(() => tempat = 'Masjid'),
                      ),
                      _buildPlaceChip(
                        context: context,
                        label: 'Rumah',
                        icon: Icons.home_rounded,
                        isSelected: tempat == 'Rumah',
                        onTap: () => setModalState(() => tempat = 'Rumah'),
                      ),
                      _buildPlaceChip(
                        context: context,
                        label: 'Kantor',
                        icon: Icons.business_rounded,
                        isSelected: tempat == 'Kantor',
                        onTap: () => setModalState(() => tempat = 'Kantor'),
                      ),
                      _buildPlaceChip(
                        context: context,
                        label: 'Lainnya',
                        icon: Icons.location_on_rounded,
                        isSelected: tempat == 'Lainnya',
                        onTap: () => setModalState(() => tempat = 'Lainnya'),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: tempat.isEmpty
                          ? null
                          : () {
                              setState(() {
                                data['completed'] = true;
                                data['tepatWaktu'] = tepatWaktu;
                                data['berjamaah'] = berjamaah;
                                data['tempat'] = tempat;
                              });
                              Navigator.pop(context);
                              _showCompletionFeedback(sholatName);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                      ),
                      child: Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected
          ? AppTheme.primaryBlue.withValues(alpha: 0.1)
          : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.primaryBlue
                    : AppTheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompletionFeedback(String sholatName) {
    final feedbacks = [
      'Alhamdulillah! Sholat $sholatName tercatat',
      'Barakallahu fiik! Semoga diterima',
      'Masya Allah, istiqomah terus ya',
      'Semoga berkah sholat ${sholatName}nya',
      'Subhanallah, terus semangat beribadah',
    ];
    final msg = feedbacks[DateTime.now().millisecond % feedbacks.length];

    showMessageToast(context, message: msg, type: ToastType.success);
  }
}
