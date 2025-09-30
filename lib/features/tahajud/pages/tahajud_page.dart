import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:intl/intl.dart';

class TahajudPage extends StatefulWidget {
  const TahajudPage({super.key});

  @override
  State<TahajudPage> createState() => _TahajudPageState();
}

class _TahajudPageState extends State<TahajudPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // Challenge data
  int currentStreak = 7;
  int longestStreak = 15;
  int totalDays = 45;
  int currentLevel = 3;
  int tahajudCount = 45;
  bool todayCompleted = false;
  bool isPremium = true; // For demo purposes

  // Weekly progress (last 7 days)
  final List<bool> weeklyProgress = [
    true,
    true,
    false,
    true,
    true,
    true,
    false,
  ];

  // Calendar data - tahajud completed dates
  final Set<DateTime> completedDates = {
    DateTime(2025, 9, 24),
    DateTime(2025, 9, 25),
    DateTime(2025, 9, 27),
    DateTime(2025, 9, 28),
    DateTime(2025, 9, 29),
    DateTime(2025, 9, 30),
    DateTime(2025, 9, 22),
    DateTime(2025, 9, 20),
    DateTime(2025, 9, 18),
    DateTime(2025, 9, 16),
    DateTime(2025, 9, 15),
    DateTime(2025, 9, 13),
    DateTime(2025, 9, 11),
    DateTime(2025, 9, 10),
    DateTime(2025, 9, 8),
  };

  DateTime selectedMonth = DateTime.now();
  PageController calendarPageController = PageController();

  // Available badges
  final List<Map<String, dynamic>> badges = [
    {
      'id': 'first_step',
      'name': 'Langkah Pertama',
      'description': 'Lakukan tahajud pertama kali',
      'icon': Icons.star_rounded,
      'color': Colors.amber,
      'achieved': true,
      'date': DateTime(2025, 8, 15),
    },
    {
      'id': 'week_warrior',
      'name': 'Pejuang Seminggu',
      'description': 'Tahajud 7 hari berturut-turut',
      'icon': Icons.military_tech_rounded,
      'color': Colors.blue,
      'achieved': true,
      'date': DateTime(2025, 9, 10),
    },
    {
      'id': 'night_guardian',
      'name': 'Penjaga Malam',
      'description': 'Tahajud 30 hari dalam sebulan',
      'icon': Icons.shield_rounded,
      'color': Colors.purple,
      'achieved': false,
    },
    {
      'id': 'consistent_soul',
      'name': 'Jiwa Istiqomah',
      'description': 'Tahajud 100 hari total',
      'icon': Icons.psychology_rounded,
      'color': Colors.green,
      'achieved': false,
    },
    {
      'id': 'diamond_devotee',
      'name': 'Berlian Ibadah',
      'description': 'Tahajud 365 hari total',
      'icon': Icons.diamond_rounded,
      'color': Colors.cyan,
      'achieved': false,
    },
  ];

  // Challenge levels
  final List<Map<String, dynamic>> levels = [
    {'level': 1, 'name': 'Pemula', 'minDays': 0, 'color': Colors.grey},
    {'level': 2, 'name': 'Pembelajar', 'minDays': 7, 'color': Colors.blue},
    {'level': 3, 'name': 'Pejuang', 'minDays': 30, 'color': Colors.purple},
    {'level': 4, 'name': 'Ahli', 'minDays': 100, 'color': Colors.orange},
    {'level': 5, 'name': 'Master', 'minDays': 365, 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: currentStreak / 30.0)
        .animate(
          CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
        );

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _markTodayComplete() {
    if (!todayCompleted && isPremium) {
      setState(() {
        todayCompleted = true;
        currentStreak++;
        tahajudCount++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Alhamdulillah! Tahajud hari ini berhasil dicatat',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.05),
              AppTheme.backgroundWhite,
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildStreakCard(),
                // _buildProgressSection(),
                _buildWeeklyProgress(),
                _buildCalendarSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.15),
                      AppTheme.accentGreen.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.nightlight_round,
                  color: AppTheme.primaryBlue,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tahajud Challenge',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Bangun di malam hari untuk beribadah',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Quote Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.1),
                  AppTheme.accentGreen.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'وَمِنَ اللَّيْلِ فَتَهَجَّدْ بِهِ نَافِلَةً لَّكَ',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '"Dan pada sebagian malam, maka lakukanlah shalat tahajud sebagai suatu ibadah tambahan bagimu"',
                  style: TextStyle(
                    color: AppTheme.onSurface.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'QS. Al-Isra: 79',
                  style: TextStyle(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Streak Saat Ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$currentStreak',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'hari',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStreakStat('Terpanjang', '$longestStreak hari'),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(child: _buildStreakStat('Total', '$tahajudCount hari')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    final nextLevel = levels.firstWhere(
      (level) => level['minDays'] > tahajudCount,
      orElse: () => levels.last,
    );
    final progress = tahajudCount / nextLevel['minDays'];

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
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
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.2),
                      AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Progress Menuju Level Berikutnya',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${nextLevel['level']}: ${nextLevel['name']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
              Text(
                '${tahajudCount}/${nextLevel['minDays']} hari',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    Container(
                      width:
                          MediaQuery.of(context).size.width *
                          progress *
                          _progressAnimation.value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGreen.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
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
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentGreen.withValues(alpha: 0.2),
                      AppTheme.accentGreen.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_view_week_rounded,
                  color: AppTheme.accentGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Progress 7 Hari Terakhir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
              final isCompleted = weeklyProgress[index];

              return Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.accentGreen
                          : AppTheme.accentGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_rounded : Icons.close_rounded,
                      color: isCompleted
                          ? Colors.white
                          : AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                      size: 18,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
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
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.2),
                      AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Kalender Tahajud',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCalendarHeader(),
          const SizedBox(height: 16),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              selectedMonth = DateTime(
                selectedMonth.year,
                selectedMonth.month - 1,
              );
            });
          },
          icon: Icon(Icons.chevron_left_rounded, color: AppTheme.primaryBlue),
        ),
        Text(
          DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              selectedMonth = DateTime(
                selectedMonth.year,
                selectedMonth.month + 1,
              );
            });
          },
          icon: Icon(Icons.chevron_right_rounded, color: AppTheme.primaryBlue),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Days of week header
    final daysOfWeek = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Column(
      children: [
        // Header with day names
        Row(
          children: daysOfWeek.map((day) {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        ...List.generate((daysInMonth + firstDayWeekday - 1 + 6) ~/ 7, (
          weekIndex,
        ) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber =
                    weekIndex * 7 + dayIndex - firstDayWeekday + 2;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return Expanded(child: Container());
                }

                final currentDate = DateTime(
                  selectedMonth.year,
                  selectedMonth.month,
                  dayNumber,
                );
                final isCompleted = completedDates.contains(
                  DateTime(
                    currentDate.year,
                    currentDate.month,
                    currentDate.day,
                  ),
                );
                final isToday =
                    DateTime.now().year == currentDate.year &&
                    DateTime.now().month == currentDate.month &&
                    DateTime.now().day == currentDate.day;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isCompleted) {
                          completedDates.removeWhere(
                            (date) =>
                                date.year == currentDate.year &&
                                date.month == currentDate.month &&
                                date.day == currentDate.day,
                          );
                        } else {
                          completedDates.add(
                            DateTime(
                              currentDate.year,
                              currentDate.month,
                              currentDate.day,
                            ),
                          );
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.accentGreen
                            : isToday
                            ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: AppTheme.primaryBlue, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isCompleted
                                    ? Colors.white
                                    : isToday
                                    ? AppTheme.primaryBlue
                                    : AppTheme.onSurface,
                              ),
                            ),
                            if (isCompleted)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 12,
                                    color: AppTheme.accentGreen,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
        const SizedBox(height: 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCalendarLegend(AppTheme.accentGreen, 'Tahajud dilakukan'),
            const SizedBox(width: 20),
            _buildCalendarLegend(
              AppTheme.primaryBlue.withValues(alpha: 0.3),
              'Hari ini',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: todayCompleted
              ? [Colors.grey, Colors.grey.shade400]
              : [AppTheme.primaryBlue, AppTheme.accentGreen],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (todayCompleted ? Colors.grey : AppTheme.primaryBlue)
                .withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: todayCompleted ? null : _markTodayComplete,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: Icon(
          todayCompleted ? Icons.check_circle_rounded : Icons.add_rounded,
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          todayCompleted ? 'Selesai' : 'Catat Tahajud',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
