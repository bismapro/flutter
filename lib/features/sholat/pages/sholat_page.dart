import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';

class SholatPage extends StatefulWidget {
  const SholatPage({super.key});

  @override
  State<SholatPage> createState() => _SholatPageState();
}

class _SholatPageState extends State<SholatPage> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedDate = DateTime.now();

  // ---------- Responsive utils (berbasis ResponsiveHelper) ----------
  double _scale(BuildContext c) {
    if (ResponsiveHelper.isSmallScreen(c)) return .9;
    if (ResponsiveHelper.isMediumScreen(c)) return 1.0;
    if (ResponsiveHelper.isLargeScreen(c)) return 1.1;
    return 1.2; // extra large
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
    return double.infinity; // phone
  }

  // ---------- Data ----------
  final Map<String, Map<String, dynamic>> _sholatWajibData = {
    'Subuh': {
      'time': '04:13',
      'completed': false,
      'alarmActive': false,
      'icon': Icons.wb_sunny_outlined,
      'color': Colors.orange,
    },
    'Dzuhur': {
      'time': '11:37',
      'completed': false,
      'alarmActive': true,
      'icon': Icons.wb_sunny,
      'color': Colors.amber,
    },
    'Ashar': {
      'time': '14:44',
      'completed': false,
      'alarmActive': false,
      'icon': Icons.wb_cloudy,
      'color': Colors.blue,
    },
    'Maghrib': {
      'time': '17:41',
      'completed': false,
      'alarmActive': false,
      'icon': Icons.wb_twilight,
      'color': Colors.deepOrange,
    },
    'Isya': {
      'time': '18:50',
      'completed': false,
      'alarmActive': false,
      'icon': Icons.nights_stay,
      'color': Colors.indigo,
    },
  };

  final Map<String, Map<String, dynamic>> _sholatSunnahData = {
    'Tahajud': {
      'time': '03:00 - 05:00',
      'completed': false,
      'icon': Icons.bedtime,
    },
    'Dhuha': {
      'time': '07:00 - 11:00',
      'completed': false,
      'icon': Icons.wb_sunny,
    },
    'Qabliyah Subuh': {
      'time': '05:00 - 05:30',
      'completed': false,
      'icon': Icons.wb_sunny_outlined,
    },
    'Qabliyah Dzuhur': {
      'time': '12:00 - 12:15',
      'completed': false,
      'icon': Icons.wb_sunny,
    },
    'Ba\'diyah Dzuhur': {
      'time': '12:45 - 15:30',
      'completed': false,
      'icon': Icons.wb_sunny,
    },
    'Qabliyah Ashar': {
      'time': '15:00 - 15:30',
      'completed': false,
      'icon': Icons.wb_cloudy,
    },
    'Ba\'diyah Maghrib': {
      'time': '18:45 - 19:30',
      'completed': false,
      'icon': Icons.wb_twilight,
    },
    'Qabliyah Isya': {
      'time': '19:30 - 19:45',
      'completed': false,
      'icon': Icons.nights_stay,
    },
    'Ba\'diyah Isya': {
      'time': '20:15 - 23:00',
      'completed': false,
      'icon': Icons.nights_stay,
    },
    'Witir': {
      'time': '20:00 - 05:00',
      'completed': false,
      'icon': Icons.nights_stay,
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get completedWajibCount =>
      _sholatWajibData.values.where((d) => d['completed'] == true).length;

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

  String get hijriDate => '8 Rabiul Akhir 1447'; // placeholder
  bool get isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue,
              AppTheme.primaryBlue.withValues(alpha: 0.9),
              AppTheme.accentGreen.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _maxWidth(context)),
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildLocationAndStatus(context),
                  _buildCurrentPrayerTime(context),
                  Expanded(child: _buildPrayerTimesList(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: _hpad(
        context,
      ).add(EdgeInsets.symmetric(vertical: _px(context, 12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleBtn(
            context,
            icon: Icons.chevron_left_rounded,
            onTap: () => setState(
              () =>
                  selectedDate = selectedDate.subtract(const Duration(days: 1)),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  isToday ? 'Hari ini' : dayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _ts(context, 18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: _ts(context, 14),
                  ),
                ),
                Text(
                  hijriDate,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: _ts(context, 13),
                  ),
                ),
              ],
            ),
          ),
          _circleBtn(
            context,
            icon: Icons.chevron_right_rounded,
            onTap: () => setState(
              () => selectedDate = selectedDate.add(const Duration(days: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(
    BuildContext c, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: _px(c, 28)),
      ),
    );
  }

  Widget _buildLocationAndStatus(BuildContext context) {
    final small = ResponsiveHelper.isSmallScreen(context);

    return Padding(
      padding: _hpad(context),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _px(context, small ? 12 : 16),
                vertical: _px(context, small ? 6 : 8),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: _px(context, small ? 16 : 18),
                  ),
                  SizedBox(width: _px(context, small ? 6 : 8)),
                  Flexible(
                    child: Text(
                      'Purwokerto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _ts(context, small ? 12 : 14),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: _px(context, small ? 8 : 12)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _px(context, small ? 12 : 16),
              vertical: _px(context, small ? 6 : 8),
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGreen.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: _px(context, small ? 14 : 16),
                ),
                SizedBox(width: _px(context, small ? 4 : 6)),
                Text(
                  'KEMENAG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _ts(context, small ? 12 : 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPrayerTime(BuildContext context) {
    final small = ResponsiveHelper.isSmallScreen(context);

    return Padding(
      padding: _hpad(
        context,
      ).add(EdgeInsets.symmetric(vertical: _px(context, 12))),
      child: Row(
        children: [
          // card kiri
          Expanded(
            child: Container(
              padding: EdgeInsets.all(_px(context, small ? 16 : 20)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Waktu Sholat Sekarang',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: _ts(context, small ? 12 : 14),
                    ),
                  ),
                  SizedBox(height: _px(context, small ? 6 : 8)),
                  Row(
                    children: [
                      Text(
                        'Dzuhur',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _ts(context, small ? 18 : 20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.all(_px(context, 6)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade400,
                              Colors.amber.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.wb_sunny,
                          color: Colors.white,
                          size: _px(context, small ? 16 : 20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _px(context, small ? 2 : 4)),
                  Text(
                    '11:37',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _ts(context, small ? 28 : 32),
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: _px(context, small ? 6 : 8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _px(context, 10),
                      vertical: _px(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Ashar dalam 2j 25m',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: _ts(context, small ? 11 : 13),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: _px(context, small ? 12 : 16)),

          // card kanan
          Container(
            padding: EdgeInsets.all(_px(context, small ? 16 : 20)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(_px(context, 8)),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.accentGreen,
                    size: _px(context, small ? 28 : 32),
                  ),
                ),
                SizedBox(height: _px(context, small ? 10 : 12)),
                Text(
                  '$completedWajibCount/5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _ts(context, small ? 20 : 24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'selesai',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: _ts(context, small ? 11 : 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(BuildContext context) {
    final small = ResponsiveHelper.isSmallScreen(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              top: _px(context, 16),
              bottom: _px(context, 8),
            ),
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
          // Tab
          Container(
            margin: _hpad(
              context,
            ).add(EdgeInsets.only(bottom: _px(context, 8))),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.05),
                  AppTheme.accentGreen.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.onSurface,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: _ts(context, small ? 13 : 14),
              ),
              tabs: const [
                Tab(text: 'Sholat Wajib'),
                Tab(text: 'Sholat Sunnah'),
              ],
            ),
          ),
          // imsak / terbit
          Container(
            margin: _hpad(context),
            padding: EdgeInsets.symmetric(vertical: _px(context, 10)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.08),
                  AppTheme.accentGreen.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  size: _px(context, small ? 14 : 16),
                  color: AppTheme.primaryBlue,
                ),
                SizedBox(width: _px(context, small ? 6 : 8)),
                Text(
                  'Imsak 04:03',
                  style: TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: _ts(context, small ? 12 : 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: _px(context, small ? 12 : 16)),
                Container(
                  width: 1,
                  height: _px(context, 16),
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                ),
                SizedBox(width: _px(context, small ? 12 : 16)),
                Icon(
                  Icons.wb_sunny,
                  size: _px(context, small ? 14 : 16),
                  color: AppTheme.accentGreen,
                ),
                SizedBox(width: _px(context, small ? 6 : 8)),
                Text(
                  'Terbit 05:25',
                  style: TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: _ts(context, small ? 12 : 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
      ),
    );
  }

  Widget _buildWajibTab(BuildContext context) {
    final small = ResponsiveHelper.isSmallScreen(context);

    return ListView.builder(
      padding: _hpad(context),
      physics: const BouncingScrollPhysics(),
      itemCount: _sholatWajibData.length,
      itemBuilder: (_, i) {
        final name = _sholatWajibData.keys.elementAt(i);
        final d = _sholatWajibData[name]!;
        final done = d['completed'] as bool;
        final iconColor = (d['color'] as Color);

        return Container(
          margin: EdgeInsets.only(bottom: _px(context, 12)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: done
                  ? AppTheme.accentGreen.withValues(alpha: 0.3)
                  : Colors.grey.shade200,
              width: done ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: done
                    ? AppTheme.accentGreen.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(_px(context, small ? 14 : 16)),
            child: Row(
              children: [
                // checklist
                GestureDetector(
                  onTap: () {
                    setState(() => d['completed'] = !done);
                    if (!done) _showCompletionFeedback(name);
                  },
                  child: Container(
                    width: _px(context, 24),
                    height: _px(context, 24),
                    decoration: BoxDecoration(
                      color: d['completed']
                          ? AppTheme.accentGreen
                          : Colors.transparent,
                      border: Border.all(
                        color: d['completed']
                            ? AppTheme.accentGreen
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: d['completed']
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: _px(context, 16),
                          )
                        : null,
                  ),
                ),
                SizedBox(width: _px(context, small ? 12 : 16)),
                // icon
                Container(
                  width: _px(context, small ? 48 : 52),
                  height: _px(context, small ? 48 : 52),
                  decoration: BoxDecoration(
                    gradient: done
                        ? LinearGradient(
                            colors: [
                              AppTheme.accentGreen,
                              AppTheme.accentGreen.withValues(alpha: 0.8),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              iconColor.withValues(alpha: 0.2),
                              iconColor.withValues(alpha: 0.1),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    done ? Icons.check_circle_rounded : d['icon'],
                    color: done ? Colors.white : iconColor,
                    size: _px(context, small ? 24 : 28),
                  ),
                ),
                SizedBox(width: _px(context, small ? 12 : 16)),
                // text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: _ts(context, small ? 15 : 16),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      SizedBox(height: _px(context, 4)),
                      Text(
                        '${d['time']}',
                        style: TextStyle(
                          fontSize: _ts(context, small ? 13 : 14),
                          color: AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // alarm
                GestureDetector(
                  onTap: () => setState(
                    () => d['alarmActive'] = !(d['alarmActive'] as bool),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(_px(context, small ? 10 : 12)),
                    decoration: BoxDecoration(
                      gradient: (d['alarmActive'] as bool)
                          ? LinearGradient(
                              colors: [
                                AppTheme.primaryBlue,
                                AppTheme.primaryBlue.withValues(alpha: 0.8),
                              ],
                            )
                          : null,
                      color: (d['alarmActive'] as bool)
                          ? null
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.alarm_rounded,
                      color: (d['alarmActive'] as bool)
                          ? Colors.white
                          : Colors.grey.shade600,
                      size: _px(context, small ? 20 : 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSunnahTab(BuildContext context) {
    final small = ResponsiveHelper.isSmallScreen(context);

    return ListView.builder(
      padding: _hpad(context),
      physics: const BouncingScrollPhysics(),
      itemCount: _sholatSunnahData.length,
      itemBuilder: (_, i) {
        final name = _sholatSunnahData.keys.elementAt(i);
        final d = _sholatSunnahData[name]!;

        return Container(
          margin: EdgeInsets.only(bottom: _px(context, 12)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: (d['completed'] as bool)
                  ? AppTheme.accentGreen.withValues(alpha: 0.3)
                  : Colors.grey.shade200,
              width: (d['completed'] as bool) ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (d['completed'] as bool)
                    ? AppTheme.accentGreen.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(_px(context, small ? 14 : 16)),
            child: Row(
              children: [
                // checklist
                GestureDetector(
                  onTap: () {
                    setState(() => d['completed'] = !(d['completed'] as bool));
                    if (d['completed'] == true) _showCompletionFeedback(name);
                  },
                  child: Container(
                    width: _px(context, 24),
                    height: _px(context, 24),
                    decoration: BoxDecoration(
                      color: (d['completed'] as bool)
                          ? AppTheme.accentGreen
                          : Colors.transparent,
                      border: Border.all(
                        color: (d['completed'] as bool)
                            ? AppTheme.accentGreen
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: (d['completed'] as bool)
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: _px(context, 16),
                          )
                        : null,
                  ),
                ),
                SizedBox(width: _px(context, small ? 12 : 16)),
                // icon
                Container(
                  width: _px(context, small ? 48 : 52),
                  height: _px(context, small ? 48 : 52),
                  decoration: BoxDecoration(
                    gradient: (d['completed'] as bool)
                        ? LinearGradient(
                            colors: [
                              AppTheme.accentGreen,
                              AppTheme.accentGreen.withValues(alpha: 0.8),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              AppTheme.primaryBlue.withValues(alpha: 0.15),
                              AppTheme.accentGreen.withValues(alpha: 0.15),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    (d['completed'] as bool)
                        ? Icons.check_circle_rounded
                        : d['icon'],
                    color: (d['completed'] as bool)
                        ? Colors.white
                        : AppTheme.primaryBlue,
                    size: _px(context, small ? 24 : 28),
                  ),
                ),
                SizedBox(width: _px(context, small ? 12 : 16)),
                // text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: _ts(context, small ? 15 : 16),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      SizedBox(height: _px(context, 4)),
                      Text(
                        '${d['time']}',
                        style: TextStyle(
                          fontSize: _ts(context, small ? 12 : 13),
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
        );
      },
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(_px(context, 6)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: _px(context, 20),
              ),
            ),
            SizedBox(width: _px(context, 12)),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: _ts(context, 14),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.accentGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
