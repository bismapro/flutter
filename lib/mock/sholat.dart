import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/core/widgets/toast.dart';
import 'package:test_flutter/features/auth/auth_provider.dart';
import 'package:test_flutter/features/sholat/sholat_provider.dart';
import 'package:test_flutter/features/sholat/sholat_state.dart';

class SholatPage extends ConsumerStatefulWidget {
  const SholatPage({super.key});

  @override
  ConsumerState<SholatPage> createState() => _SholatPageState();
}

class _SholatPageState extends ConsumerState<SholatPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late Animation<Color?> _headerColorAnimation;
  DateTime selectedDate = DateTime.now();

  // TODO: Implement actual tracking with backend
  Map<String, bool> _wajibCompleted = {
    'Subuh': false,
    'Dzuhur': false,
    'Ashar': false,
    'Maghrib': false,
    'Isya': false,
  };

  Map<String, bool> _sunnahCompleted = {
    'Tahajud': false,
    'Witir': false,
    'Dhuha': false,
    'Qabliyah Subuh': false,
    'Qabliyah Dzuhur': false,
    'Ba\'diyah Dzuhur': false,
    'Qabliyah Ashar': false,
    'Ba\'diyah Maghrib': false,
    'Qabliyah Isya': false,
    'Ba\'diyah Isya': false,
  };

  Map<String, bool> _wajibAlarms = {
    'Subuh': true,
    'Dzuhur': true,
    'Ashar': true,
    'Maghrib': true,
    'Isya': true,
  };

  Map<String, bool> _sunnahAlarms = {
    'Tahajud': false,
    'Witir': false,
    'Dhuha': false,
    'Qabliyah Subuh': false,
    'Qabliyah Dzuhur': false,
    'Ba\'diyah Dzuhur': false,
    'Qabliyah Ashar': false,
    'Ba\'diyah Maghrib': false,
    'Qabliyah Isya': false,
    'Ba\'diyah Isya': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _updateHeaderColorAnimation();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _updateHeaderColorAnimation();
        if (_tabController.index == 0) {
          _headerAnimationController.reverse();
        } else {
          _headerAnimationController.forward();
        }
      }
      setState(() {});
    });

    // Fetch jadwal sholat setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchJadwalSholat();
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  Future<void> _fetchJadwalSholat() async {
    // Auto fetch dengan lokasi yang tersimpan atau current location
    await ref.read(sholatProvider.notifier).fetchJadwalSholat();
  }

  Future<void> _useCurrentLocation() async {
    await ref.read(sholatProvider.notifier).useCurrentLocation();
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

  // Responsive utils
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
      final hijri = HijriCalendar.fromDate(selectedDate);
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

  int get _completedCount {
    if (isWajibTab) {
      return _wajibCompleted.values.where((v) => v).length;
    } else {
      return _sunnahCompleted.values.where((v) => v).length;
    }
  }

  int get _totalCount {
    return isWajibTab ? 5 : 10;
  }

  /// Show login required message
  void _showLoginRequired() {
    showMessageToast(
      context,
      message:
          'Anda harus login untuk menggunakan fitur alarm dan pencatatan sholat',
      type: ToastType.warning,
    );
  }

  /// Show prayer detail bottom sheet
  void _showPrayerDetail({
    required String name,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    // Check authentication
    if (ref.watch(authProvider)['status'] != AuthState.authenticated) {
      _showLoginRequired();
      return;
    }

    final isWajib = isWajibTab;
    final isCompleted = isWajib
        ? _wajibCompleted[name] ?? false
        : _sunnahCompleted[name] ?? false;
    final hasAlarm = isWajib
        ? _wajibAlarms[name] ?? false
        : _sunnahAlarms[name] ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(height: 1),

                // Checkbox - Tandai sudah sholat
                InkWell(
                  onTap: () {
                    setModalState(() {
                      if (isWajib) {
                        _wajibCompleted[name] =
                            !(_wajibCompleted[name] ?? false);
                      } else {
                        _sunnahCompleted[name] =
                            !(_sunnahCompleted[name] ?? false);
                      }
                    });
                    setState(() {}); // Update parent state
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color:
                                (isWajib
                                        ? _wajibCompleted[name]
                                        : _sunnahCompleted[name]) ??
                                    false
                                ? color
                                : Colors.transparent,
                            border: Border.all(
                              color:
                                  (isWajib
                                          ? _wajibCompleted[name]
                                          : _sunnahCompleted[name]) ??
                                      false
                                  ? color
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child:
                              (isWajib
                                      ? _wajibCompleted[name]
                                      : _sunnahCompleted[name]) ??
                                  false
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tandai sudah sholat',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Catat ibadah Anda hari ini',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1),

                // Toggle - Alarm
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 16,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alarm pengingat',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Dapatkan notifikasi saat waktu sholat tiba',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value:
                            (isWajib
                                ? _wajibAlarms[name]
                                : _sunnahAlarms[name]) ??
                            false,
                        onChanged: (value) {
                          setModalState(() {
                            if (isWajib) {
                              _wajibAlarms[name] = value;
                            } else {
                              _sunnahAlarms[name] = value;
                            }
                          });
                          setState(() {}); // Update parent state

                          showMessageToast(
                            context,
                            message: value
                                ? 'Alarm $name diaktifkan'
                                : 'Alarm $name dinonaktifkan',
                            type: ToastType.success,
                          );
                        },
                        activeColor: color,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),
                const SizedBox(height: 16),

                // Close Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sholatState = ref.watch(sholatProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState['status'] == AuthState.authenticated;

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxWidth(context)),
            child: Column(
              children: [
                _buildCompactHeader(context, sholatState),
                if (sholatState.status == SholatStatus.loading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (sholatState.status == SholatStatus.error)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            sholatState.message ?? 'Terjadi kesalahan',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _fetchJadwalSholat,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(child: _buildPrayerTimesList(context, sholatState)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context, SholatState sholatState) {
    final small = ResponsiveHelper.isSmallScreen(context);

    // Get jadwal for selected date
    final jadwal = ref
        .read(sholatProvider.notifier)
        .getJadwalByDate(selectedDate);

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
              // Offline indicator
              if (sholatState.isOffline)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _px(context, 12),
                    vertical: _px(context, 6),
                  ),
                  margin: EdgeInsets.only(bottom: _px(context, 12)),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off,
                        size: _px(context, 14),
                        color: Colors.white,
                      ),
                      SizedBox(width: _px(context, 6)),
                      Text(
                        'Mode Offline',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _ts(context, 11),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

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
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: _useCurrentLocation,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: _px(context, 4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: _px(context, 14),
                                ),
                                SizedBox(width: _px(context, 4)),
                                Flexible(
                                  child: Text(
                                    sholatState.locationName ??
                                        'Memuat lokasi...',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: _ts(context, small ? 11 : 12),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: _px(context, 4)),
                                Icon(
                                  Icons.refresh,
                                  size: _px(context, 12),
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Local Time Display
                        if (sholatState.localTime != null)
                          Padding(
                            padding: EdgeInsets.only(top: _px(context, 2)),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: _px(context, 12),
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                                SizedBox(width: _px(context, 4)),
                                Text(
                                  '${sholatState.localTime} • ${sholatState.localDate}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: _ts(context, small ? 10 : 11),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: _px(context, 8)),
                        Text(
                          jadwal != null ? 'Dzuhur' : '-',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _ts(context, small ? 16 : 18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          jadwal?.wajib.dzuhur ?? '--:--',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _ts(context, small ? 22 : 26),
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: _px(context, 4)),
                        Text(
                          jadwal != null ? 'Ashar dalam 2j 25m' : 'Memuat...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: _ts(context, small ? 10 : 11),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Circle
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
                          Text(
                            '$_completedCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _ts(context, small ? 32 : 36),
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          SizedBox(height: _px(context, 2)),
                          Text(
                            '/ $_totalCount',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: _ts(context, small ? 14 : 16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: _px(context, 4)),
                          Text(
                            isWajibTab ? 'Wajib' : 'Sunnah',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: _ts(context, small ? 10 : 11),
                              fontWeight: FontWeight.w500,
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

  Widget _buildPrayerTimesList(BuildContext context, SholatState sholatState) {
    final small = ResponsiveHelper.isSmallScreen(context);
    final jadwal = ref
        .read(sholatProvider.notifier)
        .getJadwalByDate(selectedDate);

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
            children: [
              _buildWajibTab(context, jadwal),
              _buildSunnahTab(context, jadwal),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWajibTab(BuildContext context, jadwal) {
    if (jadwal == null) {
      return const Center(
        child: Text('Jadwal tidak tersedia untuk tanggal ini'),
      );
    }

    final wajibList = {
      'Subuh': {'time': jadwal.wajib.shubuh, 'icon': Icons.wb_sunny_outlined},
      'Dzuhur': {'time': jadwal.wajib.dzuhur, 'icon': Icons.wb_sunny},
      'Ashar': {'time': jadwal.wajib.ashar, 'icon': Icons.wb_cloudy},
      'Maghrib': {'time': jadwal.wajib.maghrib, 'icon': Icons.wb_twilight},
      'Isya': {'time': jadwal.wajib.isya, 'icon': Icons.nights_stay},
    };

    return ListView.builder(
      padding: _hpad(context).add(EdgeInsets.only(bottom: _px(context, 16))),
      physics: const BouncingScrollPhysics(),
      itemCount: wajibList.length,
      itemBuilder: (_, i) {
        final name = wajibList.keys.elementAt(i);
        final data = wajibList[name]!;

        return _buildSholatTile(
          context: context,
          name: name,
          time: data['time'] as String,
          icon: data['icon'] as IconData,
          color: AppTheme.primaryBlue,
          isCompleted: _wajibCompleted[name] ?? false,
          hasAlarm: _wajibAlarms[name] ?? false,
        );
      },
    );
  }

  Widget _buildSunnahTab(BuildContext context, jadwal) {
    if (jadwal == null) {
      return const Center(
        child: Text('Jadwal tidak tersedia untuk tanggal ini'),
      );
    }

    final sunnahList = {
      'Tahajud': {
        'time': jadwal.sunnah.tahajud,
        'icon': Icons.bedtime_outlined,
      },
      'Witir': {
        'time': jadwal.sunnah.witir,
        'icon': Icons.nights_stay_outlined,
      },
      'Dhuha': {'time': jadwal.sunnah.dhuha, 'icon': Icons.wb_sunny_outlined},
      'Qabliyah Subuh': {
        'time': jadwal.sunnah.qabliyahSubuh,
        'icon': Icons.wb_sunny_outlined,
      },
      'Qabliyah Dzuhur': {
        'time': jadwal.sunnah.qabliyahDzuhur,
        'icon': Icons.wb_sunny_outlined,
      },
      'Ba\'diyah Dzuhur': {
        'time': jadwal.sunnah.baDiyahDzuhur,
        'icon': Icons.wb_sunny_outlined,
      },
      'Qabliyah Ashar': {
        'time': jadwal.sunnah.qabliyahAshar,
        'icon': Icons.wb_cloudy_outlined,
      },
      'Ba\'diyah Maghrib': {
        'time': jadwal.sunnah.baDiyahMaghrib,
        'icon': Icons.wb_twilight_outlined,
      },
      'Qabliyah Isya': {
        'time': jadwal.sunnah.qabliyahIsya,
        'icon': Icons.nights_stay_outlined,
      },
      'Ba\'diyah Isya': {
        'time': jadwal.sunnah.baDiyahIsya,
        'icon': Icons.nights_stay_outlined,
      },
    };

    return ListView.builder(
      padding: _hpad(context).add(EdgeInsets.only(bottom: _px(context, 16))),
      physics: const BouncingScrollPhysics(),
      itemCount: sunnahList.length,
      itemBuilder: (_, i) {
        final name = sunnahList.keys.elementAt(i);
        final data = sunnahList[name]!;

        return _buildSholatTile(
          context: context,
          name: name,
          time: data['time'] as String,
          icon: data['icon'] as IconData,
          color: AppTheme.accentGreen,
          isCompleted: _sunnahCompleted[name] ?? false,
          hasAlarm: _sunnahAlarms[name] ?? false,
        );
      },
    );
  }

  Widget _buildSholatTile({
    required BuildContext context,
    required String name,
    required String time,
    required IconData icon,
    required Color color,
    required bool isCompleted,
    required bool hasAlarm,
  }) {
    final small = ResponsiveHelper.isSmallScreen(context);

    return Container(
      margin: EdgeInsets.only(bottom: _px(context, 8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? color.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPrayerDetail(
            name: name,
            time: time,
            icon: icon,
            color: color,
          ),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _px(context, small ? 14 : 16),
              vertical: _px(context, small ? 12 : 14),
            ),
            child: Row(
              children: [
                Container(
                  width: _px(context, 40),
                  height: _px(context, 40),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: _px(context, 20)),
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
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: _px(context, 2)),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: _ts(context, small ? 12 : 13),
                          color: AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Alarm indicator
                if (hasAlarm)
                  Container(
                    margin: EdgeInsets.only(right: _px(context, 8)),
                    padding: EdgeInsets.all(_px(context, 6)),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      size: _px(context, 16),
                      color: color,
                    ),
                  ),

                // Checkmark
                if (isCompleted)
                  Container(
                    width: _px(context, 24),
                    height: _px(context, 24),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: _px(context, 16),
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}