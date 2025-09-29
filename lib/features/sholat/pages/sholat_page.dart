import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';

class SholatPage extends StatefulWidget {
  const SholatPage({super.key});

  @override
  State<SholatPage> createState() => _SholatPageState();
}

class _SholatPageState extends State<SholatPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  DateTime selectedDate = DateTime.now();
  bool _showAlert = true;
  bool _isScrolled = false;

  // Data tracking sholat (untuk demo)
  final Map<String, bool> _sholatFardhuStatus = {
    'Fajr': false,
    'Subuh': false,
    'Dzuhur': false,
    'Ashar': false,
    'Maghrib': false,
    'Isha': false,
  };

  final Map<String, bool> _sholatSunnahStatus = {
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
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 50;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Date and Time',
          style: TextStyle(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        backgroundColor: _isScrolled
            ? AppTheme.backgroundWhite.withValues(alpha: .95)
            : AppTheme.backgroundWhite,
        iconTheme: const IconThemeData(color: AppTheme.onSurface),
        elevation: _isScrolled ? 4 : 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildTabBar(),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Calendar Header (tanpa week calendar)
              _buildCalendarHeader(),
              const SizedBox(height: 20),

              // Progress cards (separate)
              _buildProgressCards(),
              const SizedBox(height: 20),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildFardhuTab(), _buildSunnahTab()],
                ),
              ),
            ],
          ),

          // Alert Widget
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/alarm-settings');
        },
        backgroundColor: AppTheme.accentGreen,
        child: const Icon(Icons.alarm, color: AppTheme.backgroundWhite),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Date Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedDate = selectedDate.subtract(
                      const Duration(days: 1),
                    );
                  });
                },
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Text(
                _formatDateHeader(selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedDate = selectedDate.add(const Duration(days: 1));
                  });
                },
                icon: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: const BoxDecoration(color: AppTheme.primaryBlue),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.backgroundWhite,
        labelColor: AppTheme.backgroundWhite,
        unselectedLabelColor: AppTheme.backgroundWhite.withValues(alpha: .7),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Sholat Fardhu'),
          Tab(text: 'Sholat Sunnah'),
        ],
      ),
    );
  }

  Widget _buildProgressCards() {
    int completedFardhu = _sholatFardhuStatus.values.where((v) => v).length;
    int completedSunnah = _sholatSunnahStatus.values.where((v) => v).length;
    double progressFardhu = completedFardhu / 6.0;
    double progressSunnah = completedSunnah / 10.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Fardhu Progress
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: .2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Fardhu',
                        style: TextStyle(
                          color: AppTheme.backgroundWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$completedFardhu/6',
                        style: const TextStyle(
                          color: AppTheme.backgroundWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressFardhu,
                      backgroundColor: AppTheme.backgroundWhite.withValues(
                        alpha: 0.3,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.accentGreen,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Sunnah Progress
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGreen.withValues(alpha: .2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sunnah',
                        style: TextStyle(
                          color: AppTheme.backgroundWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$completedSunnah/10',
                        style: const TextStyle(
                          color: AppTheme.backgroundWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressSunnah,
                      backgroundColor: AppTheme.backgroundWhite.withValues(
                        alpha: 0.3,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryBlue,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFardhuTab() {
    final prayerTimes = [
      {
        'name': 'Fajr',
        'time': '5:41 AM',
        'icon': Icons.wb_sunny_outlined,
        'isActive': true,
      },
      {
        'name': 'Subuh',
        'time': '5:41 AM',
        'icon': Icons.wb_sunny_outlined,
        'isActive': false,
      },
      {
        'name': 'Dzuhur',
        'time': '1:30 PM',
        'icon': Icons.wb_sunny,
        'isActive': false,
      },
      {
        'name': 'Asr',
        'time': '5:00 PM',
        'icon': Icons.wb_cloudy,
        'isActive': false,
      },
      {
        'name': 'Maghrib',
        'time': '6:35 PM',
        'icon': Icons.wb_twilight,
        'isActive': false,
      },
      {
        'name': 'Isha',
        'time': '8:30 PM',
        'icon': Icons.nights_stay,
        'isActive': false,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: prayerTimes.length,
      itemBuilder: (context, index) {
        final prayer = prayerTimes[index];
        final isCompleted = _sholatFardhuStatus[prayer['name']] ?? false;
        final isActive = prayer['isActive'] as bool;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.accentGreen : AppTheme.backgroundWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppTheme.accentGreen : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? AppTheme.accentGreen.withValues(alpha: .2)
                    : Colors.grey.withValues(alpha: .05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.backgroundWhite.withValues(alpha: .2)
                    : AppTheme.primaryBlue.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                prayer['icon'] as IconData,
                color: isActive
                    ? AppTheme.backgroundWhite
                    : AppTheme.primaryBlue,
                size: 24,
              ),
            ),
            title: Text(
              prayer['name'] as String,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: isActive ? AppTheme.backgroundWhite : AppTheme.onSurface,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  prayer['time'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppTheme.backgroundWhite
                        : AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Transform.scale(
                  scale: 1.3,
                  child: Checkbox(
                    value: isCompleted,
                    onChanged: (value) {
                      setState(() {
                        _sholatFardhuStatus[prayer['name'] as String] =
                            value ?? false;
                      });
                      if (value == true) {
                        _showCompletionFeedback(prayer['name'] as String);
                        // Show alert when prayer is completed
                        setState(() {
                          _showAlert = true;
                        });
                      }
                    },
                    activeColor: isActive
                        ? AppTheme.backgroundWhite
                        : AppTheme.accentGreen,
                    checkColor: isActive
                        ? AppTheme.accentGreen
                        : AppTheme.backgroundWhite,
                    side: BorderSide(
                      color: isActive
                          ? AppTheme.backgroundWhite
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
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

  Widget _buildSunnahTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSunnahSection('Sholat Malam', [
            _buildSunnahSholatCard('Tahajud', '03:00 - 05:00', Icons.bedtime),
            _buildSunnahSholatCard('Witir', '20:00 - 05:00', Icons.nights_stay),
          ]),
          const SizedBox(height: 24),
          _buildSunnahSection('Sholat Siang', [
            _buildSunnahSholatCard('Dhuha', '07:00 - 11:00', Icons.wb_sunny),
          ]),
          const SizedBox(height: 24),
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
          const SizedBox(height: 100), // Extra space for navigation
        ],
      ),
    );
  }

  Widget _buildSunnahSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .05),
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
            color: AppTheme.primaryBlue.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.onSurface,
          ),
        ),
        subtitle: Text(
          time,
          style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
        ),
        trailing: Transform.scale(
          scale: 1.3,
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
            activeColor: AppTheme.accentGreen,
            checkColor: AppTheme.backgroundWhite,
            side: BorderSide(color: Colors.grey.shade400, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
