import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';

class PuasaPage extends StatefulWidget {
  const PuasaPage({super.key});

  @override
  State<PuasaPage> createState() => _PuasaPageState();
}

class _PuasaPageState extends State<PuasaPage> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  // Data puasa (untuk demo)
  Map<DateTime, Map<String, dynamic>> _puasaData = {};

  final List<Map<String, dynamic>> _puasaWajib = [
    {
      'name': 'Puasa Ramadhan',
      'description': 'Puasa wajib selama bulan Ramadhan',
      'duration': '29-30 hari',
      'period': 'Ramadhan 1446 H',
      'color': AppTheme.accentGreen,
      'icon': Icons.mosque,
    },
  ];

  final List<Map<String, dynamic>> _puasaSunnah = [
    {
      'name': 'Puasa Senin Kamis',
      'description': 'Puasa sunnah setiap hari Senin dan Kamis',
      'duration': 'Mingguan',
      'period': 'Setiap minggu',
      'color': AppTheme.primaryBlue,
      'icon': Icons.calendar_today,
    },
    {
      'name': 'Puasa Ayyamul Bidh',
      'description': 'Puasa tanggal 13, 14, 15 setiap bulan Hijriah',
      'duration': '3 hari',
      'period': 'Setiap bulan',
      'color': AppTheme.primaryBlueDark,
      'icon': Icons.brightness_3,
    },
    {
      'name': 'Puasa Daud',
      'description': 'Puasa sehari berbuka sehari',
      'duration': 'Bergantian',
      'period': 'Kontinyu',
      'color': AppTheme.primaryBlueLight,
      'icon': Icons.swap_horiz,
    },
    {
      'name': 'Puasa 6 Syawal',
      'description': 'Puasa 6 hari di bulan Syawal',
      'duration': '6 hari',
      'period': 'Syawal',
      'color': AppTheme.accentGreenDark,
      'icon': Icons.star,
    },
    {
      'name': 'Puasa Muharram',
      'description': 'Puasa tanggal 9 dan 10 Muharram (Asyura)',
      'duration': '1-2 hari',
      'period': 'Muharram',
      'color': AppTheme.errorColor,
      'icon': Icons.event_note,
    },
    {
      'name': 'Puasa Syaban',
      'description': 'Puasa sunnah di bulan Syaban',
      'duration': 'Fleksibel',
      'period': 'Syaban',
      'color': AppTheme.accentGreen,
      'icon': Icons.nightlight_round,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Inisialisasi data sample untuk demo
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      if (date.weekday == DateTime.monday ||
          date.weekday == DateTime.thursday) {
        _puasaData[DateTime(date.year, date.month, date.day)] = {
          'type': 'Senin Kamis',
          'status': i < 10 ? 'completed' : 'planned',
          'notes': 'Puasa Senin Kamis',
        };
      }
    }
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
          'Kalender Puasa',
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
            Tab(text: 'Kalender'),
            Tab(text: 'Puasa Wajib'),
            Tab(text: 'Puasa Sunnah'),
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
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'وَأَن تَصُومُوا خَيْرٌ لَّكُمْ إِن كُنتُمْ تَعْلَمُونَ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '"Dan berpuasa lebih baik bagimu jika kamu mengetahui"',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'QS. Al-Baqarah: 184',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // TabView Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCalendarTab(),
                _buildWajibTab(),
                _buildSunnahTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      children: [
        // Mini Statistics
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildStatCard('12', 'Bulan ini', AppTheme.accentGreen),
              const SizedBox(width: 12),
              _buildStatCard('156', 'Total tahun', AppTheme.primaryBlue),
              const SizedBox(width: 12),
              _buildStatCard('8', 'Beruntun', AppTheme.primaryBlueDark),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Calendar Widget (simplified)
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
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
            child: Column(
              children: [
                // Calendar Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month - 1,
                            );
                          });
                        },
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      Text(
                        _getMonthYear(_selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month + 1,
                            );
                          });
                        },
                        icon: const Icon(
                          Icons.chevron_right,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                // Calendar Days
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildCalendarGrid(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        // Weekday headers
        Row(
          children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),

        // Calendar days grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 42, // 6 weeks
            itemBuilder: (context, index) {
              final dayNumber = index - startingWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                dayNumber,
              );
              final dateKey = DateTime(date.year, date.month, date.day);
              final puasaInfo = _puasaData[dateKey];

              return GestureDetector(
                onTap: () => _showDayDetail(date, puasaInfo),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: puasaInfo != null
                        ? (puasaInfo['status'] == 'completed'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2))
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        date.day == DateTime.now().day &&
                            date.month == DateTime.now().month &&
                            date.year == DateTime.now().year
                        ? Border.all(color: AppTheme.primaryBlue, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayNumber.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: puasaInfo != null
                                ? Colors.white
                                : AppTheme.onSurface,
                          ),
                        ),
                        if (puasaInfo != null)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: puasaInfo['status'] == 'completed'
                                  ? Colors.green
                                  : Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWajibTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _puasaWajib.length,
      itemBuilder: (context, index) {
        final puasa = _puasaWajib[index];
        return _buildPuasaCard(puasa, isWajib: true);
      },
    );
  }

  Widget _buildSunnahTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _puasaSunnah.length,
      itemBuilder: (context, index) {
        final puasa = _puasaSunnah[index];
        return _buildPuasaCard(puasa, isWajib: false);
      },
    );
  }

  Widget _buildPuasaCard(Map<String, dynamic> puasa, {required bool isWajib}) {
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
                    color: puasa['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(puasa['icon'], color: puasa['color'], size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            puasa['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isWajib
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isWajib ? 'WAJIB' : 'SUNNAH',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isWajib ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        puasa['description'],
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
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip('Durasi', puasa['duration'], Icons.schedule),
                const SizedBox(width: 12),
                _buildInfoChip('Periode', puasa['period'], Icons.event),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showPuasaDetail(puasa),
                style: ElevatedButton.styleFrom(
                  backgroundColor: puasa['color'],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Lihat Detail & Tracking',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
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
              style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthYear(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showDayDetail(DateTime date, Map<String, dynamic>? puasaInfo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${date.day} ${_getMonthYear(date)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            if (puasaInfo != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: puasaInfo['status'] == 'completed'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      puasaInfo['status'] == 'completed'
                          ? Icons.check_circle
                          : Icons.schedule,
                      color: puasaInfo['status'] == 'completed'
                          ? Colors.green
                          : Colors.blue,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      puasaInfo['type'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      puasaInfo['status'] == 'completed'
                          ? 'Puasa telah diselesaikan'
                          : 'Puasa direncanakan',
                      style: TextStyle(color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Text(
                'Tidak ada rencana puasa',
                style: TextStyle(color: AppTheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _markFasting(date);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tandai Puasa'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPuasaDetail(Map<String, dynamic> puasa) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detail ${puasa['name']} - Fitur dalam pengembangan'),
        backgroundColor: AppTheme.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markFasting(DateTime date) {
    setState(() {
      final dateKey = DateTime(date.year, date.month, date.day);
      _puasaData[dateKey] = {
        'type': 'Puasa Sunnah',
        'status': 'completed',
        'notes': 'Puasa sunnah',
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alhamdulillah! Puasa telah ditandai 🤲'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
