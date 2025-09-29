import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../data/services/alarm_service.dart';

class AlarmSettingsPage extends StatefulWidget {
  const AlarmSettingsPage({super.key});

  @override
  State<AlarmSettingsPage> createState() => _AlarmSettingsPageState();
}

class _AlarmSettingsPageState extends State<AlarmSettingsPage> {
  final AlarmService _alarmService = AlarmService();
  Map<String, bool> _alarmStates = {};
  bool _isLoading = true;

  final List<Map<String, dynamic>> _prayers = [
    {
      'name': 'Fajr',
      'time': '05:41',
      'icon': Icons.wb_sunny_outlined,
      'color': Colors.orange.shade300,
      'description': 'Sholat Subuh',
    },
    {
      'name': 'Dhuhr',
      'time': '12:00',
      'icon': Icons.wb_sunny,
      'color': Colors.yellow.shade600,
      'description': 'Sholat Dzuhur',
    },
    {
      'name': 'Asr',
      'time': '15:14',
      'icon': Icons.wb_cloudy,
      'color': Colors.orange.shade600,
      'description': 'Sholat Ashar',
    },
    {
      'name': 'Maghrib',
      'time': '18:02',
      'icon': Icons.wb_twilight,
      'color': Colors.deepOrange.shade400,
      'description': 'Sholat Maghrib',
    },
    {
      'name': 'Isha',
      'time': '19:11',
      'icon': Icons.nights_stay,
      'color': Colors.indigo.shade400,
      'description': 'Sholat Isya',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAlarmStates();
  }

  Future<void> _loadAlarmStates() async {
    try {
      final states = await _alarmService.getAllAlarmStates();
      setState(() {
        _alarmStates = states;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading alarm states: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAlarm(String prayerName, bool enabled) async {
    try {
      await _alarmService.setAlarm(prayerName, enabled);
      setState(() {
        _alarmStates[prayerName] = enabled;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Alarm sholat $prayerName telah diaktifkan'
                : 'Alarm sholat $prayerName telah dinonaktifkan',
          ),
          backgroundColor: enabled ? AppTheme.accentGreen : Colors.grey,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengatur alarm: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _testAdzan() async {
    try {
      await _alarmService.stopAdzan(); // Stop any playing adzan first
      await Future.delayed(const Duration(milliseconds: 500));
      await _alarmService.playAdzanTest();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memainkan suara adzan...'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memainkan adzan: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Pengaturan Alarm Sholat',
          style: TextStyle(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.backgroundWhite,
        iconTheme: const IconThemeData(color: AppTheme.onSurface),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue,
                          AppTheme.primaryBlue.withValues(alpha: .8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: .3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.alarm, color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Alarm Sholat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aktifkan alarm untuk mengingatkan waktu sholat dengan suara adzan yang merdu',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .9),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Test Adzan Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _testAdzan,
                            icon: const Icon(Icons.volume_up, size: 20),
                            label: const Text('Test Suara Adzan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: .2,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: .3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Waktu Sholat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih waktu sholat yang ingin diaktifkan alarmnya',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Prayer List
                  ...List.generate(_prayers.length, (index) {
                    final prayer = _prayers[index];
                    final isEnabled = _alarmStates[prayer['name']] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isEnabled
                              ? AppTheme.accentGreen.withValues(alpha: .3)
                              : Colors.grey.shade200,
                          width: isEnabled ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isEnabled
                                ? AppTheme.accentGreen.withValues(alpha: .1)
                                : (prayer['color'] as Color).withValues(
                                    alpha: .1,
                                  ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            prayer['icon'] as IconData,
                            color: isEnabled
                                ? AppTheme.accentGreen
                                : prayer['color'] as Color,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          prayer['description'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isEnabled
                                ? AppTheme.accentGreen
                                : AppTheme.onSurface,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppTheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              prayer['time'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: Switch(
                          value: isEnabled,
                          onChanged: (value) =>
                              _toggleAlarm(prayer['name'] as String, value),
                          activeThumbColor: AppTheme.accentGreen,
                          activeTrackColor: AppTheme.accentGreen.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Additional Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentGreen.withValues(alpha: .2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.accentGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Informasi',
                              style: TextStyle(
                                color: AppTheme.accentGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Alarm akan berbunyi dengan suara adzan pada waktu yang ditentukan\n'
                          '• Pastikan notifikasi aplikasi tidak diblokir\n'
                          '• Alarm akan tetap berjalan meski aplikasi ditutup\n'
                          '• Volume adzan akan mengikuti volume media device',
                          style: TextStyle(
                            color: AppTheme.onSurface,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Extra bottom padding for navigation bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _alarmService.stopAdzan();
    super.dispose();
  }
}
