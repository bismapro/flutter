import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ZakatPage extends StatefulWidget {
  const ZakatPage({super.key});

  @override
  State<ZakatPage> createState() => _ZakatPageState();
}

class _ZakatPageState extends State<ZakatPage> with TickerProviderStateMixin {
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

  final List<Map<String, dynamic>> _sedekahKhusus = [
    {
      'name': 'Sedekah Ramadhan',
      'description': 'Sedekah khusus bulan Ramadhan',
      'frequency': 'Setiap hari Ramadhan',
      'suggestion': 'Rp 10.000 - Rp 100.000',
      'icon': Icons.mosque,
      'color': Colors.green,
    },
    {
      'name': 'Sedekah Hari Raya',
      'description': 'Sedekah pada Idul Fitri dan Idul Adha',
      'frequency': '2x setahun',
      'suggestion': 'Rp 50.000 - Rp 500.000',
      'icon': Icons.celebration,
      'color': Colors.orange,
    },
    {
      'name': 'Sedekah Bencana',
      'description': 'Sedekah untuk korban bencana alam',
      'frequency': 'Sesuai kebutuhan',
      'suggestion': 'Rp 25.000 - Rp 1.000.000',
      'icon': Icons.favorite,
      'color': Colors.red,
    },
    {
      'name': 'Sedekah Yatim',
      'description': 'Sedekah untuk anak yatim dan dhuafa',
      'frequency': 'Mingguan/Bulanan',
      'suggestion': 'Rp 20.000 - Rp 200.000',
      'icon': Icons.child_care,
      'color': Colors.blue,
    },
    {
      'name': 'Sedekah Pendidikan',
      'description': 'Sedekah untuk pendidikan Islam',
      'frequency': 'Bulanan',
      'suggestion': 'Rp 50.000 - Rp 300.000',
      'icon': Icons.school,
      'color': Colors.purple,
    },
    {
      'name': 'Sedekah Masjid',
      'description': 'Sedekah untuk pembangunan masjid',
      'frequency': 'Sesuai kemampuan',
      'suggestion': 'Rp 10.000 - Rp 500.000',
      'icon': Icons.location_city,
      'color': Colors.teal,
    },
  ];

  final List<Map<String, dynamic>> _sedekahJadwal = [
    {
      'name': 'Sedekah Subuh',
      'time': '05:30 - 07:00',
      'description': 'Sedekah setelah sholat Subuh',
      'icon': Icons.wb_sunny_outlined,
      'color': Colors.orange,
      'suggestion': 'Rp 5.000 - Rp 25.000',
    },
    {
      'name': 'Sedekah Dzuhur',
      'time': '12:30 - 15:00',
      'description': 'Sedekah setelah sholat Dzuhur',
      'icon': Icons.wb_sunny,
      'color': Colors.yellow.shade700,
      'suggestion': 'Rp 10.000 - Rp 50.000',
    },
    {
      'name': 'Sedekah Ashar',
      'time': '15:45 - 17:30',
      'description': 'Sedekah setelah sholat Ashar',
      'icon': Icons.wb_cloudy,
      'color': Colors.blue,
      'suggestion': 'Rp 5.000 - Rp 25.000',
    },
    {
      'name': 'Sedekah Maghrib',
      'time': '18:30 - 19:30',
      'description': 'Sedekah setelah sholat Maghrib',
      'icon': Icons.wb_twilight,
      'color': Colors.deepOrange,
      'suggestion': 'Rp 10.000 - Rp 30.000',
    },
    {
      'name': 'Sedekah Isya',
      'time': '20:00 - 23:00',
      'description': 'Sedekah setelah sholat Isya',
      'icon': Icons.nights_stay,
      'color': Colors.indigo,
      'suggestion': 'Rp 5.000 - Rp 25.000',
    },
    {
      'name': 'Sedekah Jumat',
      'time': 'Setiap Jumat',
      'description': 'Sedekah khusus hari Jumat',
      'icon': Icons.mosque,
      'color': Colors.teal,
      'suggestion': 'Rp 25.000 - Rp 100.000',
    },
    {
      'name': 'Sedekah Malam',
      'time': '20:00 - 04:00',
      'description': 'Sedekah di waktu malam',
      'icon': Icons.bedtime,
      'color': Colors.purple,
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
      backgroundColor: AppTheme.backgroundColor,
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
            // Tab(text: 'Sedekah Khusus'),
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
              children: [
                _buildTrackerTab(),
                _buildSedekahKhususTab(),
                _buildRiwayatTab(),
              ],
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSedekahKhususTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _sedekahKhusus.length,
      itemBuilder: (context, index) {
        final sedekah = _sedekahKhusus[index];
        return _buildSedekahKhususCard(sedekah);
      },
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
              _buildStatCard('15', 'Hari ini', Colors.green),
              const SizedBox(width: 12),
              _buildStatCard('127', 'Bulan ini', Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard('1.2M', 'Total tahun', Colors.orange),
            ],
          ),
          const SizedBox(height: 24),

          // Riwayat sedekah
          const Text(
            'Riwayat Sedekah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
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
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
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
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          riwayat['date'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (riwayat['note'] != null)
                          Text(
                            riwayat['note'],
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'Rp ${riwayat['amount'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSedekahKhususCard(Map<String, dynamic> sedekah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: sedekah['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    sedekah['icon'],
                    color: sedekah['color'],
                    size: 24,
                  ),
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
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sedekah['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSedekahInfo(
                  'Frekuensi',
                  sedekah['frequency'],
                  Icons.schedule,
                ),
                const SizedBox(width: 12),
                _buildSedekahInfo('Saran', sedekah['suggestion'], Icons.money),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showSedekahKhususDialog(sedekah),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sedekah['color'],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Catat Sedekah',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSedekahInfo(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
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
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sedekah['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sedekah['time'],
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
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

  void _showSedekahKhususDialog(Map<String, dynamic> sedekah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Catat ${sedekah['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sedekah['description']),
            const SizedBox(height: 12),
            Text(
              'Saran: ${sedekah['suggestion']}',
              style: TextStyle(
                color: sedekah['color'],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Jumlah sedekah',
                hintText: 'Masukkan nominal...',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSedekahFeedback(sedekah['name']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: sedekah['color'],
              foregroundColor: Colors.white,
            ),
            child: const Text('Catat'),
          ),
        ],
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
