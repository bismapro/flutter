import 'package:flutter/material.dart';
import '../models/child_data.dart';
import '../widgets/child_card.dart';
import '../widgets/summary_stats_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/section_header.dart';
import 'detail_report_page.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data untuk demonstrasi
  List<ChildData> children = [
    const ChildData(
      name: 'Ahmad',
      avatarUrl: '👦',
      prayerStreak: 15,
      quranProgress: 65,
      totalBadges: 12,
      prayedToday: true,
    ),
    const ChildData(
      name: 'Fatimah',
      avatarUrl: '👧',
      prayerStreak: 22,
      quranProgress: 80,
      totalBadges: 18,
      prayedToday: true,
    ),
  ];

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

  /// Calculate average badges for summary
  int get averageBadges {
    if (children.isEmpty) return 0;
    return (children.map((c) => c.totalBadges).reduce((a, b) => a + b) /
            children.length)
        .round();
  }

  /// Calculate prayer completion percentage
  double get prayerCompletionRate {
    if (children.isEmpty) return 0.0;
    final completedCount = children.where((c) => c.prayedToday).length;
    return completedCount / children.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monitoring Keluarga',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Monitor aktivitas ibadah keluarga',
                    style: TextStyle(fontSize: 16, color: Color(0xFF4A5568)),
                  ),
                  const SizedBox(height: 20),
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF1E88E5),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color(0xFF4A5568),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      tabs: const [
                        Tab(text: 'Monitoring'),
                        Tab(text: 'Challenges'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildMonitoringTab(), _buildChallengesTab()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddChildDialog(context),
        backgroundColor: const Color(0xFF26A69A),
        elevation: 4,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Tambah Anak',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Tab Monitoring - menampilkan daftar anak dan statistik mereka
  Widget _buildMonitoringTab() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Statistics
            SummaryStatsCard(
              totalChildren: children.length,
              prayerCompletionRate: '${(prayerCompletionRate * 100).toInt()}%',
              averageBadges: averageBadges,
            ),

            const SizedBox(height: 24),

            // Children Cards Section
            const SectionHeader(title: 'Aktivitas Anak'),
            const SizedBox(height: 16),

            if (children.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.family_restroom, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada anak yang ditambahkan',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap tombol + untuk menambah anak',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Children list
              ...children.map(
                (child) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ChildCard(
                    child: child,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailReportPage(child: child),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Quick Actions Section
            const SectionHeader(title: 'Quick Actions'),
            const SizedBox(height: 16),
            _buildQuickActions(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Quick Actions grid
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: QuickActionCard(
            icon: Icons.analytics_outlined,
            label: 'Lihat Laporan',
            color: const Color(0xFF1E88E5),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DetailReportPage()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuickActionCard(
            icon: Icons.emoji_events,
            label: 'Beri Reward',
            color: const Color(0xFFFF9800),
            onTap: () => _showRewardDialog(context),
          ),
        ),
      ],
    );
  }

  /// Tab Challenges - menampilkan tantangan dan achievement
  Widget _buildChallengesTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Tantangan Aktif'),
          const SizedBox(height: 16),

          // Weekly Challenge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6A11CB).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Tantangan Mingguan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sholat berjamaah 7 hari berturut-turut',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Progress: 4/7 hari',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 4 / 7,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.yellow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Reward: 100 poin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Achievement Gallery
          const SectionHeader(title: 'Achievement Terbaru'),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildAchievementCard(
                'Sholat Streak 7 Hari',
                Icons.local_fire_department,
                Colors.orange,
                'Ahmad',
              ),
              _buildAchievementCard(
                'Al-Fatihah Master',
                Icons.menu_book,
                Colors.green,
                'Fatimah',
              ),
              _buildAchievementCard(
                'Early Bird Prayer',
                Icons.wb_sunny,
                Colors.amber,
                'Ahmad',
              ),
              _buildAchievementCard(
                'Perfect Week',
                Icons.star,
                Colors.purple,
                'Fatimah',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Achievement Card
  Widget _buildAchievementCard(
    String title,
    IconData icon,
    Color color,
    String achiever,
  ) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            achiever,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog untuk menambah anak
  void _showAddChildDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Anak Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Anak',
                border: OutlineInputBorder(),
              ),
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
              if (nameController.text.isNotEmpty) {
                setState(() {
                  children.add(
                    ChildData(
                      name: nameController.text,
                      avatarUrl: '👶',
                      prayerStreak: 0,
                      quranProgress: 0,
                      totalBadges: 0,
                      prayedToday: false,
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${nameController.text} berhasil ditambahkan!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  /// Dialog untuk memberi reward
  void _showRewardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beri Reward'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 48),
            SizedBox(height: 16),
            Text('Fitur reward akan segera hadir!'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
