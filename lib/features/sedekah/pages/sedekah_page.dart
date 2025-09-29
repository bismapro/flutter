import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';

class SedekahPage extends StatefulWidget {
  const SedekahPage({super.key});

  @override
  State<SedekahPage> createState() => _SedekahPageState();
}

class _SedekahPageState extends State<SedekahPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Data tracking sedekah harian
  List<Map<String, dynamic>> _sedekahHarian = [
    {'name': 'Sedekah Pagi', 'amount': 0, 'done': false, 'time': 'Pagi'},
    {'name': 'Sedekah Siang', 'amount': 0, 'done': false, 'time': 'Siang'},
    {'name': 'Sedekah Sore', 'amount': 0, 'done': false, 'time': 'Sore'},
    {'name': 'Sedekah Malam', 'amount': 0, 'done': false, 'time': 'Malam'},
  ];

  // Riwayat sedekah
  List<Map<String, dynamic>> _riwayatSedekah = [
    {
      'date': '25 Sep 2025',
      'amount': 50000,
      'type': 'Sedekah Pagi',
      'note': 'Untuk fakir miskin',
    },
    {
      'date': '24 Sep 2025',
      'amount': 25000,
      'type': 'Sedekah Sore',
      'note': 'Untuk anak yatim',
    },
    {
      'date': '23 Sep 2025',
      'amount': 100000,
      'type': 'Sedekah Jumat',
      'note': 'Untuk masjid',
    },
  ];

  final List<Map<String, dynamic>> _sedekahJadwal = [
    {
      'name': 'Sedekah Subuh',
      'time': '05:30 - 07:00',
      'description': 'Sedekah setelah sholat Subuh',
      'icon': Icons.wb_sunny_outlined,
      'color': AppTheme.accentGreen,
      'suggestion': 'Rp 5.000 - Rp 25.000',
    },
    {
      'name': 'Sedekah Dzuhur',
      'time': '12:30 - 15:00',
      'description': 'Sedekah setelah sholat Dzuhur',
      'icon': Icons.wb_sunny,
      'color': AppTheme.primaryBlue,
      'suggestion': 'Rp 10.000 - Rp 50.000',
    },
    {
      'name': 'Sedekah Ashar',
      'time': '15:45 - 17:30',
      'description': 'Sedekah setelah sholat Ashar',
      'icon': Icons.wb_cloudy,
      'color': AppTheme.primaryBlueLight,
      'suggestion': 'Rp 5.000 - Rp 25.000',
    },
    {
      'name': 'Sedekah Maghrib',
      'time': '18:30 - 19:30',
      'description': 'Sedekah setelah sholat Maghrib',
      'icon': Icons.wb_twilight,
      'color': AppTheme.primaryBlueDark,
      'suggestion': 'Rp 10.000 - Rp 30.000',
    },
    {
      'name': 'Sedekah Isya',
      'time': '20:00 - 23:00',
      'description': 'Sedekah setelah sholat Isya',
      'icon': Icons.nights_stay,
      'color': AppTheme.primaryBlue,
      'suggestion': 'Rp 5.000 - Rp 25.000',
    },
    {
      'name': 'Sedekah Jumat',
      'time': 'Setiap Jumat',
      'description': 'Sedekah khusus hari Jumat',
      'icon': Icons.mosque,
      'color': AppTheme.accentGreen,
      'suggestion': 'Rp 25.000 - Rp 100.000',
    },
    {
      'name': 'Sedekah Malam',
      'time': '20:00 - 04:00',
      'description': 'Sedekah di waktu malam',
      'icon': Icons.bedtime,
      'color': AppTheme.accentGreenDark,
      'suggestion': 'Rp 10.000 - Rp 50.000',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          'Tracker Sedekah',
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
            Tab(text: 'Sedekah Harian'),
            Tab(text: 'Riwayat'),
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
                        'خُذْ مِنْ أَمْوَالِهِمْ صَدَقَةً تُطَهِّرُهُمْ وَتُزَكِّيهِم بِهَا',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '"Ambillah zakat dari harta mereka, guna membersihkan dan menyucikan mereka"',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'QS. At-Taubah: 103',
                        style: TextStyle(color: Colors.white60, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress sedekah hari ini
                _buildTodayProgress(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // TabView Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildTrackerTab(), _buildRiwayatTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayProgress() {
    int completedSedekah = _sedekahHarian
        .where((s) => s['done'] == true)
        .length;
    double progress = completedSedekah / _sedekahHarian.length;

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
                'Sedekah Hari Ini',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completedSedekah/${_sedekahHarian.length}',
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
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.accentGreen,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _sedekahJadwal.length,
      itemBuilder: (context, index) {
        final sedekah = _sedekahJadwal[index];
        return _buildSedekahCard(sedekah);
      },
    );
  }

  Widget _buildRiwayatTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistik sedekah
          Row(
            children: [
              _buildStatCard('15', 'Hari ini', AppTheme.accentGreen),
              const SizedBox(width: 12),
              _buildStatCard('127', 'Bulan ini', AppTheme.primaryBlue),
              const SizedBox(width: 12),
              _buildStatCard('1.2M', 'Total tahun', AppTheme.primaryBlueDark),
            ],
          ),
          const SizedBox(height: 24),

          // Riwayat sedekah
          const Text(
            'Riwayat Sedekah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          ..._riwayatSedekah.map((riwayat) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppTheme.accentGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          riwayat['type'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        Text(
                          riwayat['date'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        if (riwayat['note'] != null)
                          Text(
                            riwayat['note'],
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'Rp ${riwayat['amount'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSedekahCard(Map<String, dynamic> sedekah) {
    bool isCompleted = sedekah['done'] ?? false;

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
                color: sedekah['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(sedekah['icon'], color: sedekah['color'], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sedekah['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sedekah['description'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sedekah['time'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Saran: ${sedekah['suggestion']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: sedekah['color'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: isCompleted,
                onChanged: (value) {
                  setState(() {
                    sedekah['done'] = value ?? false;
                  });
                  if (value == true) {
                    _showSedekahFeedback(sedekah['name']);
                  }
                },
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

  void _showSedekahFeedback(String sedekahName) {
    final feedbacks = [
      'Barakallahu fiik! Semoga sedekah diterima Allah SWT 🤲',
      'Subhanallah! Allah akan melipatgandakan pahala sedekah 💚',
      'Alhamdulillah! Sedekah adalah investasi akhirat ✨',
      'Maa syaa Allah! Sedekah menolak bala dan musibah 🕌',
      'Jazakallahu khairan! Terus istiqomah bersedekah 🌟',
    ];

    final randomFeedback =
        feedbacks[DateTime.now().millisecond % feedbacks.length];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(randomFeedback),
        backgroundColor: AppTheme.primaryBlue,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
