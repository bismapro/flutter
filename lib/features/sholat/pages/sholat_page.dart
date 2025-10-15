import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/format_helper.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/core/widgets/toast.dart';
import 'package:test_flutter/features/auth/auth_provider.dart';
import 'package:test_flutter/features/sholat/services/alarm_service.dart';
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
  Timer? _timeUpdateTimer;

  final AlarmService _alarmService = AlarmService();

  Map<String, bool> _wajibCompleted = {
    'Shubuh': false,
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

  // Tambahkan helper method untuk mendapatkan sholat saat ini dan berikutnya
  String _getCurrentPrayerName(dynamic jadwal) {
    if (jadwal == null) return 'Memuat...';

    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    if (isWajibTab) {
      // Parse waktu sholat wajib
      final shubuh = _parseTime(jadwal.wajib.shubuh);
      final dzuhur = _parseTime(jadwal.wajib.dzuhur);
      final ashar = _parseTime(jadwal.wajib.ashar);
      final maghrib = _parseTime(jadwal.wajib.maghrib);
      final isya = _parseTime(jadwal.wajib.isya);

      if (_isTimeBefore(currentTime, shubuh)) {
        return 'Shubuh';
      } else if (_isTimeBefore(currentTime, dzuhur)) {
        return 'Dzuhur';
      } else if (_isTimeBefore(currentTime, ashar)) {
        return 'Ashar';
      } else if (_isTimeBefore(currentTime, maghrib)) {
        return 'Maghrib';
      } else if (_isTimeBefore(currentTime, isya)) {
        return 'Isya';
      } else {
        return 'Shubuh'; // Setelah Isya, berikutnya Shubuh besok
      }
    } else {
      // Parse waktu sholat sunnah
      final tahajud = _parseTime(jadwal.sunnah.tahajud ?? '03:00');
      final witir = _parseTime(jadwal.sunnah.witir ?? '23:00');
      final dhuha = _parseTime(jadwal.sunnah.dhuha ?? '07:00');

      // Logika untuk sunnah (simplified)
      if (_isTimeBefore(currentTime, TimeOfDay(hour: 3, minute: 0))) {
        return 'Tahajud';
      } else if (_isTimeBefore(currentTime, TimeOfDay(hour: 7, minute: 0))) {
        return 'Dhuha';
      } else if (_isTimeBefore(currentTime, TimeOfDay(hour: 11, minute: 0))) {
        return 'Qabliyah Dzuhur';
      } else if (_isTimeBefore(currentTime, TimeOfDay(hour: 14, minute: 0))) {
        return 'Ba\'diyah Dzuhur';
      } else if (_isTimeBefore(currentTime, TimeOfDay(hour: 15, minute: 30))) {
        return 'Qabliyah Ashar';
      } else if (_isTimeBefore(currentTime, TimeOfDay(hour: 18, minute: 0))) {
        return 'Ba\'diyah Maghrib';
      } else if (_isTimeBefore(currentTime, TimeOfDay(hour: 19, minute: 30))) {
        return 'Qabliyah Isya';
      } else if (_isTimeBefore(currentTime, TimeOfDay(hour: 21, minute: 0))) {
        return 'Ba\'diyah Isya';
      } else {
        return 'Witir';
      }
    }
  }

  String _getCurrentPrayerTime(dynamic jadwal) {
    if (jadwal == null) return '--:--';

    final prayerName = _getCurrentPrayerName(jadwal);

    if (isWajibTab) {
      switch (prayerName) {
        case 'Shubuh':
          return jadwal.wajib.shubuh ?? '--:--';
        case 'Dzuhur':
          return jadwal.wajib.dzuhur ?? '--:--';
        case 'Ashar':
          return jadwal.wajib.ashar ?? '--:--';
        case 'Maghrib':
          return jadwal.wajib.maghrib ?? '--:--';
        case 'Isya':
          return jadwal.wajib.isya ?? '--:--';
        default:
          return '--:--';
      }
    } else {
      switch (prayerName) {
        case 'Tahajud':
          return jadwal.sunnah.tahajud ?? 'Sepertiga malam';
        case 'Witir':
          return jadwal.sunnah.witir ?? 'Setelah Isya';
        case 'Dhuha':
          return jadwal.sunnah.dhuha ?? 'Pagi hari';
        case 'Qabliyah Subuh':
          return jadwal.sunnah.qabliyahSubuh ?? 'Sebelum Subuh';
        case 'Qabliyah Dzuhur':
          return jadwal.sunnah.qabliyahDzuhur ?? 'Sebelum Dzuhur';
        case 'Ba\'diyah Dzuhur':
          return jadwal.sunnah.baDiyahDzuhur ?? 'Setelah Dzuhur';
        case 'Qabliyah Ashar':
          return jadwal.sunnah.qabliyahAshar ?? 'Sebelum Ashar';
        case 'Ba\'diyah Maghrib':
          return jadwal.sunnah.baDiyahMaghrib ?? 'Setelah Maghrib';
        case 'Qabliyah Isya':
          return jadwal.sunnah.qabliyahIsya ?? 'Sebelum Isya';
        case 'Ba\'diyah Isya':
          return jadwal.sunnah.baDiyahIsya ?? 'Setelah Isya';
        default:
          return '--:--';
      }
    }
  }

  String _getNextPrayerName(dynamic jadwal) {
    if (jadwal == null) return 'Memuat...';

    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    if (isWajibTab) {
      final shubuh = _parseTime(jadwal.wajib.shubuh);
      final dzuhur = _parseTime(jadwal.wajib.dzuhur);
      final ashar = _parseTime(jadwal.wajib.ashar);
      final maghrib = _parseTime(jadwal.wajib.maghrib);
      final isya = _parseTime(jadwal.wajib.isya);

      if (_isTimeBefore(currentTime, shubuh)) {
        return 'Shubuh';
      } else if (_isTimeBefore(currentTime, dzuhur)) {
        return 'Dzuhur';
      } else if (_isTimeBefore(currentTime, ashar)) {
        return 'Ashar';
      } else if (_isTimeBefore(currentTime, maghrib)) {
        return 'Maghrib';
      } else if (_isTimeBefore(currentTime, isya)) {
        return 'Isya';
      } else {
        return 'Shubuh (Besok)';
      }
    } else {
      // Logika untuk next prayer sunnah
      final currentPrayer = _getCurrentPrayerName(jadwal);
      final sunnahSequence = [
        'Tahajud',
        'Qabliyah Subuh',
        'Dhuha',
        'Qabliyah Dzuhur',
        'Ba\'diyah Dzuhur',
        'Qabliyah Ashar',
        'Ba\'diyah Maghrib',
        'Qabliyah Isya',
        'Ba\'diyah Isya',
        'Witir',
      ];

      final currentIndex = sunnahSequence.indexOf(currentPrayer);
      if (currentIndex >= 0 && currentIndex < sunnahSequence.length - 1) {
        return sunnahSequence[currentIndex + 1];
      } else {
        return sunnahSequence[0]; // Kembali ke awal
      }
    }
  }

  String _getNextPrayerTime(dynamic jadwal) {
    if (jadwal == null) return '--:--';

    final nextPrayerName = _getNextPrayerName(jadwal);

    if (isWajibTab) {
      switch (nextPrayerName) {
        case 'Shubuh':
        case 'Shubuh (Besok)':
          return jadwal.wajib.shubuh ?? '--:--';
        case 'Dzuhur':
          return jadwal.wajib.dzuhur ?? '--:--';
        case 'Ashar':
          return jadwal.wajib.ashar ?? '--:--';
        case 'Maghrib':
          return jadwal.wajib.maghrib ?? '--:--';
        case 'Isya':
          return jadwal.wajib.isya ?? '--:--';
        default:
          return '--:--';
      }
    } else {
      switch (nextPrayerName) {
        case 'Tahajud':
          return jadwal.sunnah.tahajud ?? 'Sepertiga malam';
        case 'Witir':
          return jadwal.sunnah.witir ?? 'Setelah Isya';
        case 'Dhuha':
          return jadwal.sunnah.dhuha ?? 'Pagi hari';
        case 'Qabliyah Subuh':
          return jadwal.sunnah.qabliyahSubuh ?? 'Sebelum Subuh';
        case 'Qabliyah Dzuhur':
          return jadwal.sunnah.qabliyahDzuhur ?? 'Sebelum Dzuhur';
        case 'Ba\'diyah Dzuhur':
          return jadwal.sunnah.baDiyahDzuhur ?? 'Setelah Dzuhur';
        case 'Qabliyah Ashar':
          return jadwal.sunnah.qabliyahAshar ?? 'Sebelum Ashar';
        case 'Ba\'diyah Maghrib':
          return jadwal.sunnah.baDiyahMaghrib ?? 'Setelah Maghrib';
        case 'Qabliyah Isya':
          return jadwal.sunnah.qabliyahIsya ?? 'Sebelum Isya';
        case 'Ba\'diyah Isya':
          return jadwal.sunnah.baDiyahIsya ?? 'Setelah Isya';
        default:
          return '--:--';
      }
    }
  }

  String _getTimeUntilNextPrayer(dynamic jadwal) {
    if (jadwal == null) return 'Memuat...';

    final now = DateTime.now();
    final nextPrayerTimeStr = _getNextPrayerTime(jadwal);

    if (nextPrayerTimeStr == '--:--' ||
        nextPrayerTimeStr.contains('Sebelum') ||
        nextPrayerTimeStr.contains('Setelah') ||
        nextPrayerTimeStr.contains('malam') ||
        nextPrayerTimeStr.contains('hari')) {
      return 'Segera';
    }

    try {
      final nextPrayerTime = _parseTime(nextPrayerTimeStr);
      var nextPrayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        nextPrayerTime.hour,
        nextPrayerTime.minute,
      );

      // Jika waktu sudah lewat hari ini, set ke besok
      if (nextPrayerDateTime.isBefore(now)) {
        nextPrayerDateTime = nextPrayerDateTime.add(const Duration(days: 1));
      }

      final difference = nextPrayerDateTime.difference(now);
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);

      if (hours > 0) {
        return 'dalam ${hours}j ${minutes}m';
      } else if (minutes > 0) {
        return 'dalam ${minutes}m';
      } else {
        return 'Sebentar lagi';
      }
    } catch (e) {
      return 'Segera';
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      // Fallback
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  bool _isTimeBefore(TimeOfDay current, TimeOfDay target) {
    if (current.hour < target.hour) {
      return true;
    } else if (current.hour == target.hour) {
      return current.minute < target.minute;
    }
    return false;
  }

  // ---------- Responsive utils ----------
  double _scale(BuildContext c) {
    if (ResponsiveHelper.isSmallScreen(c)) return 1.0;
    if (ResponsiveHelper.isMediumScreen(c)) return 1.1;
    if (ResponsiveHelper.isLargeScreen(c)) return 1.2;
    return 1.3;
  }

  double _px(BuildContext c, double base) => base * _scale(c);
  double _ts(BuildContext c, double base) => ResponsiveHelper.adaptiveTextSize(
    c,
    base * 1.1,
  ); // Meningkatkan base font size

  EdgeInsets _hpad(BuildContext c) => EdgeInsets.symmetric(
    horizontal: ResponsiveHelper.getResponsivePadding(c).left,
  );

  double _maxWidth(BuildContext c) {
    if (ResponsiveHelper.isExtraLargeScreen(c)) return 980;
    if (ResponsiveHelper.isLargeScreen(c)) return 860;
    return double.infinity;
  }

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

    // Initialize alarm service
    _alarmService.initialize();

    // Fetch jadwal sholat setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchJadwalSholat();
      ref.read(authProvider.notifier).checkAuthStatus();
      // Fetch progress data
      ref.read(sholatProvider.notifier).fetchProgressSholatWajibHariIni();
      ref.read(sholatProvider.notifier).fetchProgressSholatSunnahHariIni();
      _loadAlarmStates();
    });

    // Setup timer untuk update waktu setiap detik
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          // Update UI untuk waktu realtime
        });
      }
    });
  }

  /// Load alarm states dari local storage
  Future<void> _loadAlarmStates() async {
    try {
      final states = await _alarmService.getAllAlarmStates();
      setState(() {
        _wajibAlarms = {
          'Subuh': states['Subuh'] ?? false,
          'Dzuhur': states['Dzuhur'] ?? false,
          'Ashar': states['Ashar'] ?? false,
          'Maghrib': states['Maghrib'] ?? false,
          'Isya': states['Isya'] ?? false,
        };
      });
    } catch (e) {
      logger.fine('Error loading alarm states: $e');
    }
  }

  /// Update waktu sholat ke alarm service
  void _updateAlarmTimes(dynamic jadwal) {
    if (jadwal != null) {
      _alarmService.updatePrayerTimes({
        'Subuh': jadwal.wajib.shubuh ?? '00:00',
        'Dzuhur': jadwal.wajib.dzuhur ?? '00:00',
        'Ashar': jadwal.wajib.ashar ?? '00:00',
        'Maghrib': jadwal.wajib.maghrib ?? '00:00',
        'Isya': jadwal.wajib.isya ?? '00:00',
      });
    }
  }

  void init() {
    _fetchJadwalSholat();
    ref.read(authProvider.notifier).checkAuthStatus();
    ref.read(sholatProvider.notifier).fetchProgressSholatWajibHariIni();
    ref.read(sholatProvider.notifier).fetchProgressSholatSunnahHariIni();
    ref.read(sholatProvider.notifier).fetchProgressSholatWajibRiwayat();
    ref.read(sholatProvider.notifier).fetchProgressSholatSunnahRiwayat();
  }

  void _fetchJadwalSholat() {
    ref.read(sholatProvider.notifier).fetchJadwalSholat();
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
    _timeUpdateTimer?.cancel();
    _alarmService.dispose();
    super.dispose();
  }

  bool get isWajibTab => _tabController.index == 0;

  bool get isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  int get _completedCount {
    final state = ref.watch(sholatProvider);

    if (isWajibTab) {
      final progressData = state.progressWajibHariIni;
      return progressData.values
          .where((v) => v is Map && (v['completed'] == true))
          .length;
    } else {
      final progressData = state.progressSunnahHariIni;
      return progressData.values
          .where((v) => v is Map && (v['completed'] == true))
          .length;
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
                        activeThumbColor: color,
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

  String get hijriDate => FormatHelper.getHijriDate(selectedDate);

  @override
  Widget build(BuildContext context) {
    final sholatState = ref.watch(sholatProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState['status'] == AuthState.authenticated;

    // Get jadwal based on selected date
    final jadwal = ref
        .read(sholatProvider.notifier)
        .getJadwalByDate(selectedDate);

    // Update alarm times ketika jadwal berubah
    if (jadwal != null) {
      _updateAlarmTimes(jadwal);
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxWidth(context)),
            child: Column(
              children: [
                _buildCompactHeader(
                  context,
                  sholatState,
                  dayName,
                  formattedDate,
                  hijriDate,
                ),
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

  Widget _buildCompactHeader(
    BuildContext context,
    SholatState sholatState,
    String dayName,
    String formattedDate,
    String hijriDate,
  ) {
    final small = ResponsiveHelper.isSmallScreen(context);

    // Get jadwal for selected date
    final jadwal = ref
        .read(sholatProvider.notifier)
        .getJadwalByDate(selectedDate);

    // Get current time formatted
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

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

                        // Local Time Display - Realtime
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
                                currentTime,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: _ts(context, small ? 10 : 11),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: _px(context, 8)),
                        // Update bagian dalam _buildCompactHeader untuk mengganti hardcoded values:
                        // ...existing code...
                        SizedBox(height: _px(context, 8)),
                        Text(
                          _getCurrentPrayerName(jadwal),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _ts(context, small ? 16 : 18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getCurrentPrayerTime(jadwal),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _ts(context, small ? 22 : 26),
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: _px(context, 4)),
                        Text(
                          jadwal != null
                              ? '${_getNextPrayerName(jadwal)} ${_getTimeUntilNextPrayer(jadwal)}'
                              : 'Memuat...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: _ts(context, small ? 10 : 11),
                          ),
                        ),
                        // ...existing code...
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
    final small = ResponsiveHelper.isSmallScreen(context);
    final state = ref.watch(sholatProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState['status'] == AuthState.authenticated;
    final progressData = state.progressWajibHariIni;

    // Map jadwal waktu dengan nama sholat - dengan fallback
    final wajibList = {
      'Shubuh': {
        'time': jadwal?.wajib.shubuh ?? '--:--',
        'icon': Icons.wb_sunny_outlined,
        'dbKey': 'subuh',
      },
      'Dzuhur': {
        'time': jadwal?.wajib.dzuhur ?? '--:--',
        'icon': Icons.wb_sunny,
        'dbKey': 'dzuhur',
      },
      'Ashar': {
        'time': jadwal?.wajib.ashar ?? '--:--',
        'icon': Icons.wb_cloudy,
        'dbKey': 'ashar',
      },
      'Maghrib': {
        'time': jadwal?.wajib.maghrib ?? '--:--',
        'icon': Icons.wb_twilight,
        'dbKey': 'maghrib',
      },
      'Isya': {
        'time': jadwal?.wajib.isya ?? '--:--',
        'icon': Icons.nights_stay,
        'dbKey': 'isya',
      },
    };

    return ListView.builder(
      padding: _hpad(context).add(EdgeInsets.only(bottom: _px(context, 16))),
      physics: const BouncingScrollPhysics(),
      itemCount: wajibList.length,
      itemBuilder: (_, i) {
        final name = wajibList.keys.elementAt(i);
        final jadwalData = wajibList[name]!;
        final dbKey = jadwalData['dbKey'] as String;
        final time = jadwalData['time'] as String;

        // Ambil data progress dari state
        final sholatProgress = progressData[dbKey] as Map<String, dynamic>?;
        final isCompleted = sholatProgress?['completed'] as bool? ?? false;
        final isOnTime = sholatProgress?['is_on_time'] as bool? ?? false;
        final isJamaah = sholatProgress?['is_jamaah'] as bool? ?? false;
        final lokasi = sholatProgress?['lokasi'] as String? ?? '';
        final progressId = sholatProgress?['id'] as int?;

        return Container(
          margin: EdgeInsets.only(bottom: _px(context, 8)),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.primaryBlue.withValues(alpha: 0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCompleted
                  ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                  : Colors.grey.shade200,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                if (!isLoggedIn) {
                  _showLoginRequired();
                  return;
                }

                if (!isCompleted) {
                  await _showSholatDetailModal(
                    context,
                    name,
                    jadwalData,
                    'wajib',
                  );
                } else {
                  _showDetailWithDeleteOption(
                    context,
                    name,
                    jadwalData,
                    'wajib',
                    sholatProgress,
                    progressId,
                  );
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
                    // Checkbox indicator
                    Container(
                      width: _px(context, 22),
                      height: _px(context, 22),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.primaryBlue
                            : Colors.transparent,
                        border: Border.all(
                          color: isCompleted
                              ? AppTheme.primaryBlue
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: _px(context, 14),
                            )
                          : null,
                    ),
                    SizedBox(width: _px(context, 12)),

                    // Icon sholat
                    Container(
                      width: _px(context, 40),
                      height: _px(context, 40),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                            : AppTheme.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        jadwalData['icon'] as IconData,
                        color: AppTheme.primaryBlue,
                        size: _px(context, 20),
                      ),
                    ),
                    SizedBox(width: _px(context, 12)),

                    // Nama dan waktu sholat
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
                                  : null,
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
                          if (isCompleted) ...[
                            SizedBox(height: _px(context, 4)),
                            Wrap(
                              spacing: 4,
                              children: [
                                if (isOnTime)
                                  _buildBadge(
                                    context,
                                    'Tepat Waktu',
                                    Icons.check_circle,
                                    Colors.green,
                                  ),
                                if (isJamaah)
                                  _buildBadge(
                                    context,
                                    'Jamaah',
                                    Icons.groups,
                                    Colors.blue,
                                  ),
                                if (lokasi.isNotEmpty)
                                  _buildBadge(
                                    context,
                                    lokasi,
                                    Icons.location_on,
                                    Colors.orange,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Alarm button dengan state dari service
                    Material(
                      color: _wajibAlarms[name] == true
                          ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () async {
                          if (!isLoggedIn) {
                            _showLoginRequired();
                            return;
                          }

                          final newState = !(_wajibAlarms[name] ?? false);

                          try {
                            // Set alarm via service
                            await _alarmService.setAlarm(name, newState, time);

                            setState(() {
                              _wajibAlarms[name] = newState;
                            });

                            showMessageToast(
                              context,
                              message: newState
                                  ? 'Alarm $name diaktifkan'
                                  : 'Alarm $name dinonaktifkan',
                              type: ToastType.success,
                            );
                          } catch (e) {
                            showMessageToast(
                              context,
                              message: 'Gagal mengatur alarm: $e',
                              type: ToastType.error,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: EdgeInsets.all(_px(context, 8)),
                          child: Icon(
                            _wajibAlarms[name] == true
                                ? Icons.alarm_on_rounded
                                : Icons.alarm_rounded,
                            color: _wajibAlarms[name] == true
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

  /// Modal untuk input detail sholat (baru)
  Future<void> _showSholatDetailModal(
    BuildContext context,
    String sholatName,
    Map<String, dynamic> jadwalData,
    String jenis,
  ) async {
    bool tepatWaktu = false;
    bool berjamaah = false;
    String tempat = '';

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
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
                  const SizedBox(height: 20),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              (jenis == 'wajib'
                                      ? AppTheme.primaryBlue
                                      : AppTheme.accentGreen)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          jadwalData['icon'] as IconData,
                          color: jenis == 'wajib'
                              ? AppTheme.primaryBlue
                              : AppTheme.accentGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                              jadwalData['time'] as String,
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
                  const SizedBox(height: 24),

                  // Tepat Waktu
                  Text(
                    'Tepat Waktu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionButton(
                          context: context,
                          label: 'Ya',
                          icon: Icons.check_circle_outline_rounded,
                          isSelected: tepatWaktu,
                          onTap: () => setModalState(() => tepatWaktu = true),
                          color: jenis == 'wajib'
                              ? AppTheme.primaryBlue
                              : AppTheme.accentGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionButton(
                          context: context,
                          label: 'Tidak',
                          icon: Icons.cancel_outlined,
                          isSelected: !tepatWaktu,
                          onTap: () => setModalState(() => tepatWaktu = false),
                          color: jenis == 'wajib'
                              ? AppTheme.primaryBlue
                              : AppTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Berjamaah
                  Text(
                    'Berjamaah',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionButton(
                          context: context,
                          label: 'Ya',
                          icon: Icons.groups_rounded,
                          isSelected: berjamaah,
                          onTap: () => setModalState(() => berjamaah = true),
                          color: jenis == 'wajib'
                              ? AppTheme.primaryBlue
                              : AppTheme.accentGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionButton(
                          context: context,
                          label: 'Tidak',
                          icon: Icons.person_rounded,
                          isSelected: !berjamaah,
                          onTap: () => setModalState(() => berjamaah = false),
                          color: jenis == 'wajib'
                              ? AppTheme.primaryBlue
                              : AppTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tempat
                  Text(
                    'Tempat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                        color: jenis == 'wajib'
                            ? AppTheme.primaryBlue
                            : AppTheme.accentGreen,
                      ),
                      _buildPlaceChip(
                        context: context,
                        label: 'Rumah',
                        icon: Icons.home_rounded,
                        isSelected: tempat == 'Rumah',
                        onTap: () => setModalState(() => tempat = 'Rumah'),
                        color: jenis == 'wajib'
                            ? AppTheme.primaryBlue
                            : AppTheme.accentGreen,
                      ),
                      _buildPlaceChip(
                        context: context,
                        label: 'Kantor',
                        icon: Icons.business_rounded,
                        isSelected: tempat == 'Kantor',
                        onTap: () => setModalState(() => tempat = 'Kantor'),
                        color: jenis == 'wajib'
                            ? AppTheme.primaryBlue
                            : AppTheme.accentGreen,
                      ),
                      _buildPlaceChip(
                        context: context,
                        label: 'Lainnya',
                        icon: Icons.location_on_rounded,
                        isSelected: tempat == 'Lainnya',
                        onTap: () => setModalState(() => tempat = 'Lainnya'),
                        color: jenis == 'wajib'
                            ? AppTheme.primaryBlue
                            : AppTheme.accentGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Button Simpan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: tempat.isEmpty
                          ? null
                          : () async {
                              try {
                                // Konversi nama sholat ke format database
                                String sholatKey = sholatName.toLowerCase();
                                if (sholatKey == 'subuh') {
                                  sholatKey = 'subuh';
                                } else if (sholatKey == 'ba\'diyah dzuhur') {
                                  sholatKey = 'ba_diyah_dzuhur';
                                } else if (sholatKey == 'ba\'diyah maghrib') {
                                  sholatKey = 'ba_diyah_maghrib';
                                } else if (sholatKey == 'ba\'diyah isya') {
                                  sholatKey = 'ba_diyah_isya';
                                } else {
                                  sholatKey = sholatKey
                                      .replaceAll(' ', '_')
                                      .replaceAll('\'', '');
                                }

                                print(
                                  'Saving progress: jenis=$jenis, sholat=$sholatKey',
                                );

                                // Simpan ke database via provider
                                final response = await ref
                                    .read(sholatProvider.notifier)
                                    .addProgressSholat(
                                      jenis: jenis,
                                      sholat: sholatKey,
                                      isOnTime: tepatWaktu,
                                      isJamaah: berjamaah,
                                      lokasi: tempat,
                                    );

                                print('Response: $response');

                                if (response != null) {
                                  // Tutup modal
                                  if (mounted) {
                                    Navigator.pop(context, true);
                                    _showCompletionFeedback(sholatName);
                                  }

                                  // Refresh data progress
                                  if (jenis == 'wajib') {
                                    await ref
                                        .read(sholatProvider.notifier)
                                        .fetchProgressSholatWajibHariIni();
                                  } else {
                                    await ref
                                        .read(sholatProvider.notifier)
                                        .fetchProgressSholatSunnahHariIni();
                                  }
                                }
                              } catch (e) {
                                print('Error saving progress: $e');

                                // Ambil message dari exception
                                String errorMessage = 'Gagal menyimpan data';

                                if (e is Exception) {
                                  final errorString = e.toString();
                                  if (errorString.contains('Exception:')) {
                                    errorMessage = errorString
                                        .replaceAll('Exception:', '')
                                        .trim();
                                  }
                                }

                                if (mounted) {
                                  showMessageToast(
                                    context,
                                    message: errorMessage,
                                    type: ToastType.error,
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: jenis == 'wajib'
                            ? AppTheme.primaryBlue
                            : AppTheme.accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                      ),
                      child: const Text(
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

    // Refresh data jika berhasil simpan
    if (result == true && mounted) {
      setState(() {});
    }
  }

  Widget _buildSunnahTab(BuildContext context, jadwal) {
    final small = ResponsiveHelper.isSmallScreen(context);
    final state = ref.watch(sholatProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState['status'] == AuthState.authenticated;
    final progressData = state.progressSunnahHariIni;

    final sunnahList = {
      'Tahajud': {
        'dbKey': 'tahajud',
        'time': jadwal?.sunnah.tahajud ?? 'Sepertiga malam',
        'icon': Icons.nightlight_round,
      },
      'Witir': {
        'dbKey': 'witir',
        'time': jadwal?.sunnah.witir ?? 'Setelah Isya',
        'icon': Icons.nights_stay,
      },
      'Dhuha': {
        'dbKey': 'dhuha',
        'time': jadwal?.sunnah.dhuha ?? 'Pagi hari',
        'icon': Icons.wb_sunny,
      },
      'Qabliyah Subuh': {
        'dbKey': 'qabliyah_subuh',
        'time': jadwal?.sunnah.qabliyahSubuh ?? 'Sebelum Subuh',
        'icon': Icons.wb_twilight,
      },
      'Qabliyah Dzuhur': {
        'dbKey': 'qabliyah_dzuhur',
        'time': jadwal?.sunnah.qabliyahDzuhur ?? 'Sebelum Dzuhur',
        'icon': Icons.wb_sunny_outlined,
      },
      'Ba\'diyah Dzuhur': {
        'dbKey': 'ba_diyah_dzuhur',
        'time': jadwal?.sunnah.baDiyahDzuhur ?? 'Setelah Dzuhur',
        'icon': Icons.wb_sunny,
      },
      'Qabliyah Ashar': {
        'dbKey': 'qabliyah_ashar',
        'time': jadwal?.sunnah.qabliyahAshar ?? 'Sebelum Ashar',
        'icon': Icons.wb_cloudy_outlined,
      },
      'Ba\'diyah Maghrib': {
        'dbKey': 'ba_diyah_maghrib',
        'time': jadwal?.sunnah.baDiyahMaghrib ?? 'Setelah Maghrib',
        'icon': Icons.wb_twilight,
      },
      'Qabliyah Isya': {
        'dbKey': 'qabliyah_isya',
        'time': jadwal?.sunnah.qabliyahIsya ?? 'Sebelum Isya',
        'icon': Icons.nights_stay_outlined,
      },
      'Ba\'diyah Isya': {
        'dbKey': 'ba_diyah_isya',
        'time': jadwal?.sunnah.baDiyahIsya ?? 'Setelah Isya',
        'icon': Icons.nights_stay,
      },
    };

    return ListView.builder(
      padding: _hpad(context).add(EdgeInsets.only(bottom: _px(context, 16))),
      physics: const BouncingScrollPhysics(),
      itemCount: sunnahList.length,
      itemBuilder: (_, i) {
        final name = sunnahList.keys.elementAt(i);
        final jadwalData = sunnahList[name]!;

        // Ambil data progress dari state
        final dbKey = jadwalData['dbKey'] as String;
        final sholatProgress = progressData[dbKey] as Map<String, dynamic>?;
        final isCompleted = sholatProgress?['completed'] as bool? ?? false;
        final isOnTime = sholatProgress?['is_on_time'] as bool? ?? false;
        final isJamaah = sholatProgress?['is_jamaah'] as bool? ?? false;
        final lokasi = sholatProgress?['lokasi'] as String? ?? '';
        final progressId = sholatProgress?['id'] as int?;

        return Container(
          margin: EdgeInsets.only(bottom: _px(context, 8)),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.accentGreen.withValues(alpha: 0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCompleted
                  ? AppTheme.accentGreen.withValues(alpha: 0.15)
                  : Colors.grey.shade200,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                // Check authentication first
                if (!isLoggedIn) {
                  _showLoginRequired();
                  return;
                }

                if (!isCompleted) {
                  // Tampilkan modal untuk input detail sholat
                  await _showSholatDetailModal(
                    context,
                    name,
                    jadwalData,
                    'sunnah',
                  );
                } else {
                  // Jika sudah selesai, tampilkan modal detail dengan opsi hapus
                  _showDetailWithDeleteOption(
                    context,
                    name,
                    jadwalData,
                    'sunnah',
                    sholatProgress,
                    progressId,
                  );
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
                    // Checkbox indicator
                    Container(
                      width: _px(context, 22),
                      height: _px(context, 22),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.accentGreen
                            : Colors.transparent,
                        border: Border.all(
                          color: isCompleted
                              ? AppTheme.accentGreen
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: _px(context, 14),
                            )
                          : null,
                    ),
                    SizedBox(width: _px(context, 12)),

                    // Icon sholat
                    Container(
                      width: _px(context, 40),
                      height: _px(context, 40),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.accentGreen.withValues(alpha: 0.15)
                            : AppTheme.accentGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        jadwalData['icon'] as IconData,
                        color: AppTheme.accentGreen,
                        size: _px(context, 20),
                      ),
                    ),
                    SizedBox(width: _px(context, 12)),

                    // Nama dan waktu sholat
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
                                  : null,
                            ),
                          ),
                          SizedBox(height: _px(context, 2)),
                          Text(
                            jadwalData['time'] as String,
                            style: TextStyle(
                              fontSize: _ts(context, small ? 11 : 12),
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Tampilkan badge info jika sudah selesai
                          if (isCompleted) ...[
                            SizedBox(height: _px(context, 4)),
                            Wrap(
                              spacing: 4,
                              children: [
                                if (isOnTime)
                                  _buildBadge(
                                    context,
                                    'Tepat Waktu',
                                    Icons.check_circle,
                                    Colors.green,
                                  ),
                                if (isJamaah)
                                  _buildBadge(
                                    context,
                                    'Jamaah',
                                    Icons.groups,
                                    Colors.blue,
                                  ),
                                if (lokasi.isNotEmpty)
                                  _buildBadge(
                                    context,
                                    lokasi,
                                    Icons.location_on,
                                    Colors.orange,
                                  ),
                              ],
                            ),
                          ],
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

  // ...existing code...

  /// Modal untuk menampilkan detail progress dengan opsi hapus
  void _showDetailWithDeleteOption(
    BuildContext context,
    String sholatName,
    Map<String, dynamic> jadwalData,
    String jenis,
    Map<String, dynamic>? progressData,
    int? progressId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        (jenis == 'wajib'
                                ? AppTheme.primaryBlue
                                : AppTheme.accentGreen)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    jadwalData['icon'] as IconData,
                    color: jenis == 'wajib'
                        ? AppTheme.primaryBlue
                        : AppTheme.accentGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
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
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Sudah tercatat',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
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
            const SizedBox(height: 24),

            // Info detail
            if (progressData != null) ...[
              _buildInfoRow(
                'Tepat Waktu',
                progressData['is_on_time'] == true ? 'Ya' : 'Tidak',
                Icons.access_time,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Berjamaah',
                progressData['is_jamaah'] == true ? 'Ya' : 'Tidak',
                Icons.groups,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Lokasi',
                progressData['lokasi'] as String? ?? '-',
                Icons.location_on,
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 16),
            ],

            // Button Hapus
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Tutup modal detail
                  Navigator.pop(context);

                  // Tampilkan konfirmasi hapus
                  final confirmed = await _showDeleteConfirmation(
                    context,
                    sholatName,
                    jenis,
                  );

                  if (confirmed == true && progressId != null) {
                    try {
                      // Panggil provider untuk hapus
                      await ref
                          .read(sholatProvider.notifier)
                          .deleteProgressSholat(id: progressId);

                      // Refresh data
                      if (jenis == 'wajib') {
                        ref
                            .read(sholatProvider.notifier)
                            .fetchProgressSholatWajibHariIni();
                      } else {
                        ref
                            .read(sholatProvider.notifier)
                            .fetchProgressSholatSunnahHariIni();
                      }

                      if (mounted) {
                        showMessageToast(
                          context,
                          message:
                              'Progress sholat $sholatName berhasil dihapus',
                          type: ToastType.success,
                        );
                      }
                    } catch (e) {
                      String errorMessage = 'Gagal menghapus data';

                      if (e is Exception) {
                        final errorString = e.toString();
                        if (errorString.contains('Exception:')) {
                          errorMessage = errorString
                              .replaceAll('Exception:', '')
                              .trim();
                        }
                      }

                      if (mounted) {
                        showMessageToast(
                          context,
                          message: errorMessage,
                          type: ToastType.error,
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text(
                  'Hapus Catatan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Button Tutup
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: jenis == 'wajib'
                      ? AppTheme.primaryBlue
                      : AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog konfirmasi hapus progress
  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    String sholatName,
    String jenis,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Hapus Catatan?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan sholat $sholatName? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 15, color: AppTheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget badge kecil untuk menampilkan info detail sholat
  Widget _buildBadge(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Modal untuk edit/hapus progress sholat yang sudah ada
  void _showEditSholatModal(
    BuildContext context,
    String sholatName,
    Map<String, dynamic> jadwalData,
    String jenis,
    Map<String, dynamic>? progressData,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        (jenis == 'wajib'
                                ? AppTheme.primaryBlue
                                : AppTheme.accentGreen)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    jadwalData['icon'] as IconData,
                    color: jenis == 'wajib'
                        ? AppTheme.primaryBlue
                        : AppTheme.accentGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
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
                      const Text(
                        'Sudah tercatat',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Info detail
            if (progressData != null) ...[
              _buildInfoRow(
                'Tepat Waktu',
                progressData['is_on_time'] == true ? 'Ya' : 'Tidak',
                Icons.access_time,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Berjamaah',
                progressData['is_jamaah'] == true ? 'Ya' : 'Tidak',
                Icons.groups,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Lokasi',
                progressData['lokasi'] as String? ?? '-',
                Icons.location_on,
              ),
              const SizedBox(height: 24),
            ],

            // Button Tutup
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: jenis == 'wajib'
                      ? AppTheme.primaryBlue
                      : AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final selectedColor = color ?? AppTheme.primaryBlue;

    return Material(
      color: isSelected
          ? selectedColor.withValues(alpha: 0.1)
          : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? selectedColor : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? selectedColor : AppTheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? selectedColor : AppTheme.onSurfaceVariant,
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
    Color? color,
  }) {
    final selectedColor = color ?? AppTheme.primaryBlue;

    return Material(
      color: isSelected ? selectedColor : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: 6),
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
