import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';

class SholatPage extends StatefulWidget {
  const SholatPage({super.key});

  @override
  State<SholatPage> createState() => _SholatPageState();
}

class _SholatPageState extends State<SholatPage> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedDate = DateTime.now();

  final Map<String, Map<String, dynamic>> _sholatWajibData = {
    'Subuh': {
      'time': '04:13',
      'completed': false,
      'alarmActive': false,
      'icon': Icons.wb_sunny_outlined,
      'color': Colors.orange.shade400,
    },
    'Dzuhur': {
      'time': '11:37',
      'completed': false,
      'alarmActive': true,
      'icon': Icons.wb_sunny,
      'color': Colors.amber.shade600,
    },
    'Ashar': {
      'time': '14:44',
      'completed': false,
      'alarmActive': false,
      'icon': Icons.wb_cloudy,
      'color': Colors.blue.shade400,
    },
    'Maghrib': {
      'time': '17:41',
      'completed': false,
      'alarmActive': false,
      'icon': Icons.wb_twilight,
      'color': Colors.deepOrange.shade400,
    },
    'Isya': {
      'time': '18:50',
      'completed': false,
      'alarmActive': false,
      'icon': Icons.nights_stay,
      'color': Colors.indigo.shade400,
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

  int get completedWajibCount {
    return _sholatWajibData.values
        .where((data) => data['completed'] == true)
        .length;
  }

  String get formattedDate {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${selectedDate.day} ${months[selectedDate.month - 1]} ${selectedDate.year}';
  }

  String get dayName {
    final days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return days[selectedDate.weekday - 1];
  }

  String get hijriDate {
    // Simplified - dalam implementasi nyata gunakan package hijri
    return '8 Rabiul Akhir 1447';
  }

  bool get isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

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
          child: Column(
            children: [
              _buildHeader(isSmallScreen),
              _buildLocationAndStatus(isSmallScreen),
              _buildCurrentPrayerTime(isSmallScreen),
              Expanded(child: _buildPrayerTimesList(isSmallScreen)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.subtract(
                        const Duration(days: 1),
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      isToday
                          ? 'Hari ini'
                          : dayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                    Text(
                      hijriDate,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: isSmallScreen ? 12 : 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.add(const Duration(days: 1));
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAndStatus(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 6 : 8,
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
                    size: isSmallScreen ? 16 : 18,
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Flexible(
                    child: Text(
                      'Purwokerto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 6 : 8,
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
                  size: isSmallScreen ? 14 : 16,
                ),
                SizedBox(width: isSmallScreen ? 4 : 6),
                Text(
                  'KEMENAG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 12 : 14,
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

  Widget _buildCurrentPrayerTime(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Row(
                    children: [
                      Text(
                        'Dzuhur',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
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
                          size: isSmallScreen ? 16 : 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    '11:37',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Ashar dalam 2j 25m',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: isSmallScreen ? 11 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.accentGreen,
                    size: isSmallScreen ? 28 : 32,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 10 : 12),
                Text(
                  '$completedWajibCount/5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'selesai',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(bool isSmallScreen) {
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
            margin: EdgeInsets.only(top: 16, bottom: 8),
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
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20,
              vertical: isSmallScreen ? 12 : 16,
            ),
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
                fontSize: isSmallScreen ? 13 : 14,
              ),
              tabs: const [
                Tab(text: 'Sholat Wajib'),
                Tab(text: 'Sholat Sunnah'),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
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
                  size: isSmallScreen ? 14 : 16,
                  color: AppTheme.primaryBlue,
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  'Imsak 04:03',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Container(
                  width: 1,
                  height: 16,
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Icon(
                  Icons.wb_sunny,
                  size: isSmallScreen ? 14 : 16,
                  color: AppTheme.accentGreen,
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  'Terbit 05:25',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWajibTab(isSmallScreen),
                _buildSunnahTab(isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWajibTab(bool isSmallScreen) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      itemCount: _sholatWajibData.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final prayerName = _sholatWajibData.keys.elementAt(index);
        final prayerData = _sholatWajibData[prayerName]!;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: prayerData['completed']
                  ? AppTheme.accentGreen.withValues(alpha: 0.3)
                  : Colors.grey.shade200,
              width: prayerData['completed'] ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: prayerData['completed']
                    ? AppTheme.accentGreen.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
              child: Row(
                children: [
                  // Checklist
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        prayerData['completed'] = !prayerData['completed'];
                      });
                      if (prayerData['completed']) {
                        _showCompletionFeedback(prayerName);
                      }
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: prayerData['completed']
                            ? AppTheme.accentGreen
                            : Colors.transparent,
                        border: Border.all(
                          color: prayerData['completed']
                              ? AppTheme.accentGreen
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: prayerData['completed']
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Container(
                    width: isSmallScreen ? 48 : 52,
                    height: isSmallScreen ? 48 : 52,
                    decoration: BoxDecoration(
                      gradient: prayerData['completed']
                          ? LinearGradient(
                              colors: [
                                AppTheme.accentGreen,
                                AppTheme.accentGreen.withValues(alpha: 0.8),
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                (prayerData['color'] as Color).withValues(
                                  alpha: 0.2,
                                ),
                                (prayerData['color'] as Color).withValues(
                                  alpha: 0.1,
                                ),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      prayerData['completed']
                          ? Icons.check_circle_rounded
                          : prayerData['icon'],
                      color: prayerData['completed']
                          ? Colors.white
                          : prayerData['color'],
                      size: isSmallScreen ? 24 : 28,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prayerName,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 15 : 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prayerData['time'],
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            color: AppTheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        prayerData['alarmActive'] =
                            !prayerData['alarmActive'];
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                      decoration: BoxDecoration(
                        gradient: prayerData['alarmActive']
                            ? LinearGradient(
                                colors: [
                                  AppTheme.primaryBlue,
                                  AppTheme.primaryBlue.withValues(alpha: 0.8),
                                ],
                              )
                            : null,
                        color: prayerData['alarmActive']
                            ? null
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.alarm_rounded,
                        color: prayerData['alarmActive']
                            ? Colors.white
                            : Colors.grey.shade600,
                        size: isSmallScreen ? 20 : 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSunnahTab(bool isSmallScreen) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      itemCount: _sholatSunnahData.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final prayerName = _sholatSunnahData.keys.elementAt(index);
        final prayerData = _sholatSunnahData[prayerName]!;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: prayerData['completed']
                  ? AppTheme.accentGreen.withValues(alpha: 0.3)
                  : Colors.grey.shade200,
              width: prayerData['completed'] ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: prayerData['completed']
                    ? AppTheme.accentGreen.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
              child: Row(
                children: [
                  // Checklist
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        prayerData['completed'] = !prayerData['completed'];
                      });
                      if (prayerData['completed']) {
                        _showCompletionFeedback(prayerName);
                      }
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: prayerData['completed']
                            ? AppTheme.accentGreen
                            : Colors.transparent,
                        border: Border.all(
                          color: prayerData['completed']
                              ? AppTheme.accentGreen
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: prayerData['completed']
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Container(
                    width: isSmallScreen ? 48 : 52,
                    height: isSmallScreen ? 48 : 52,
                    decoration: BoxDecoration(
                      gradient: prayerData['completed']
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
                      prayerData['completed']
                          ? Icons.check_circle_rounded
                          : prayerData['icon'],
                      color: prayerData['completed']
                          ? Colors.white
                          : AppTheme.primaryBlue,
                      size: isSmallScreen ? 24 : 28,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prayerName,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 15 : 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prayerData['time'],
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
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

    final randomFeedback =
        feedbacks[DateTime.now().millisecond % feedbacks.length];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                randomFeedback,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
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
