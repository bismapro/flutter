import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class SholatPage extends StatefulWidget {
  const SholatPage({super.key});

  @override
  State<SholatPage> createState() => _SholatPageState();
}

class _SholatPageState extends State<SholatPage> with TickerProviderStateMixin {
  late TabController _tabController;

  // Data tracking sholat (untuk demo)
  Map<String, bool> _sholatFardhuStatus = {
    'Subuh': false,
    'Dzuhur': false,
    'Ashar': false,
    'Maghrib': false,
    'Isya': false,
  };

  Map<String, bool> _sholatSunnahStatus = {
    'Tahajud': false,
    'Dhuha': false,
    'Qabliyah Subuh': false,
    'Qabliyah Dzuhur': false,
    'Ba\'diyah Dzuhur': false,
    'Qabliyah Ashar': false,
    'Ba\'diyah Maghrib': false,
    'Qabliyah Isya': false,
    'Ba\'diyah Isya': false,
    'Witir': false,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Tracker Sholat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Sholat Fardhu'),
            Tab(text: 'Sholat Sunnah'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header dengan motivasi
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '"Dan tegakkanlah sholat dan tunaikanlah zakat"',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'QS. Al-Baqarah: 43',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress today
                _buildTodayProgress(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // TabView Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildFardhuTab(), _buildSunnahTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayProgress() {
    int completedFardhu = _sholatFardhuStatus.values.where((v) => v).length;
    double progress = completedFardhu / 5.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress Hari Ini',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completedFardhu/5',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFardhuTab() {
    final currentHour = DateTime.now().hour;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildSholatCard(
          'Subuh',
          '05:30',
          '06:15',
          Icons.wb_sunny_outlined,
          _sholatFardhuStatus['Subuh']!,
          _canPerformSholat('Subuh', currentHour),
          (value) => setState(() => _sholatFardhuStatus['Subuh'] = value),
          AppTheme.accentGreen,
        ),
        _buildSholatCard(
          'Dzuhur',
          '12:15',
          '15:30',
          Icons.wb_sunny,
          _sholatFardhuStatus['Dzuhur']!,
          _canPerformSholat('Dzuhur', currentHour),
          (value) => setState(() => _sholatFardhuStatus['Dzuhur'] = value),
          AppTheme.primaryBlue,
        ),
        _buildSholatCard(
          'Ashar',
          '15:30',
          '18:00',
          Icons.wb_cloudy,
          _sholatFardhuStatus['Ashar']!,
          _canPerformSholat('Ashar', currentHour),
          (value) => setState(() => _sholatFardhuStatus['Ashar'] = value),
          AppTheme.primaryBlueLight,
        ),
        _buildSholatCard(
          'Maghrib',
          '18:15',
          '19:30',
          Icons.wb_twilight,
          _sholatFardhuStatus['Maghrib']!,
          _canPerformSholat('Maghrib', currentHour),
          (value) => setState(() => _sholatFardhuStatus['Maghrib'] = value),
          AppTheme.primaryBlueDark,
        ),
        _buildSholatCard(
          'Isya',
          '19:45',
          '05:00',
          Icons.nights_stay,
          _sholatFardhuStatus['Isya']!,
          _canPerformSholat('Isya', currentHour),
          (value) => setState(() => _sholatFardhuStatus['Isya'] = value),
          AppTheme.accentGreenDark,
        ),
      ],
    );
  }

  Widget _buildSunnahTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildSunnahSection('Sholat Malam', [
          _buildSunnahSholatCard('Tahajud', '03:00 - 05:00', Icons.bedtime),
          _buildSunnahSholatCard('Witir', '20:00 - 05:00', Icons.nights_stay),
        ]),
        const SizedBox(height: 16),
        _buildSunnahSection('Sholat Siang', [
          _buildSunnahSholatCard('Dhuha', '07:00 - 11:00', Icons.wb_sunny),
        ]),
        const SizedBox(height: 16),
        _buildSunnahSection('Sholat Rawatib', [
          _buildSunnahSholatCard(
            'Qabliyah Subuh',
            '05:00 - 05:30',
            Icons.wb_sunny_outlined,
          ),
          _buildSunnahSholatCard(
            'Qabliyah Dzuhur',
            '12:00 - 12:15',
            Icons.wb_sunny,
          ),
          _buildSunnahSholatCard(
            'Ba\'diyah Dzuhur',
            '12:45 - 15:30',
            Icons.wb_sunny,
          ),
          _buildSunnahSholatCard(
            'Qabliyah Ashar',
            '15:00 - 15:30',
            Icons.wb_cloudy,
          ),
          _buildSunnahSholatCard(
            'Ba\'diyah Maghrib',
            '18:45 - 19:30',
            Icons.wb_twilight,
          ),
          _buildSunnahSholatCard(
            'Qabliyah Isya',
            '19:30 - 19:45',
            Icons.nights_stay,
          ),
          _buildSunnahSholatCard(
            'Ba\'diyah Isya',
            '20:15 - 23:00',
            Icons.nights_stay,
          ),
        ]),
      ],
    );
  }

  Widget _buildSholatCard(
    String name,
    String startTime,
    String endTime,
    IconData icon,
    bool isCompleted,
    bool canPerform,
    Function(bool) onChanged,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$startTime - $endTime',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: canPerform
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      canPerform ? 'Waktu Sholat' : 'Belum Waktunya',
                      style: TextStyle(
                        fontSize: 11,
                        color: canPerform ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: isCompleted,
                onChanged: canPerform
                    ? (value) {
                        onChanged(value ?? false);
                        if (value == true) {
                          _showCompletionFeedback(name);
                        }
                      }
                    : null,
                activeColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunnahSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSunnahSholatCard(String name, String time, IconData icon) {
    bool isCompleted = _sholatSunnahStatus[name] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurface,
          ),
        ),
        subtitle: Text(
          time,
          style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
        ),
        trailing: Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: isCompleted,
            onChanged: (value) {
              setState(() {
                _sholatSunnahStatus[name] = value ?? false;
              });
              if (value == true) {
                _showCompletionFeedback(name);
              }
            },
            activeColor: AppTheme.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  bool _canPerformSholat(String sholatName, int currentHour) {
    // Simulasi waktu sholat (dalam kondisi nyata akan menggunakan perhitungan waktu sholat)
    switch (sholatName) {
      case 'Subuh':
        return currentHour >= 5 && currentHour < 7;
      case 'Dzuhur':
        return currentHour >= 12 && currentHour < 15;
      case 'Ashar':
        return currentHour >= 15 && currentHour < 18;
      case 'Maghrib':
        return currentHour >= 18 && currentHour < 20;
      case 'Isya':
        return currentHour >= 20 || currentHour < 5;
      default:
        return true;
    }
  }

  void _showCompletionFeedback(String sholatName) {
    final feedbacks = [
      'Alhamdulillahi rabbil alamiin! 🤲',
      'Barakallahu fiik! ✨',
      'Semoga berkah sholat $sholatName nya! 🕌',
      'Istiqomah selalu ya! 💚',
      'Sholat adalah tiang agama! 🕊️',
    ];

    final randomFeedback =
        feedbacks[DateTime.now().millisecond % feedbacks.length];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(randomFeedback),
        backgroundColor: AppTheme.primaryBlue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
