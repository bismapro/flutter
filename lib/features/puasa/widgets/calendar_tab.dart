import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';

class CalendarTab extends StatefulWidget {
  final Map<DateTime, Map<String, dynamic>> puasaData;
  final Function(DateTime, Map<String, dynamic>?) onDayTap;
  final Function(DateTime) onMarkFasting;

  const CalendarTab({
    super.key,
    required this.puasaData,
    required this.onDayTap,
    required this.onMarkFasting,
  });

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    return Column(
      children: [
        // Mini Statistics
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop
                ? 32.0
                : isTablet
                ? 28.0
                : 24.0,
          ),
          child: Row(
            children: [
              _buildStatCard('12', 'Bulan ini', AppTheme.accentGreen, isTablet),
              SizedBox(width: isTablet ? 16 : 12),
              _buildStatCard(
                '156',
                'Total tahun',
                AppTheme.primaryBlue,
                isTablet,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              _buildStatCard(
                '8',
                'Beruntun',
                AppTheme.primaryBlueDark,
                isTablet,
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 24 : 20),

        // Calendar Widget (enlarged and responsive)
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: isDesktop
                  ? 32.0
                  : isTablet
                  ? 28.0
                  : 24.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 22 : 20),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Column(
              children: [
                // Calendar Header
                Container(
                  padding: EdgeInsets.all(isTablet ? 24 : 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryBlue.withValues(alpha: 0.05),
                        AppTheme.accentGreen.withValues(alpha: 0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isTablet ? 22 : 20),
                      topRight: Radius.circular(isTablet ? 22 : 20),
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
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: AppTheme.primaryBlue,
                          size: isTablet ? 32 : 28,
                        ),
                      ),
                      Text(
                        _getMonthYear(_selectedDate),
                        style: TextStyle(
                          fontSize: isDesktop
                              ? 22
                              : isTablet
                              ? 20
                              : 18,
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
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.primaryBlue,
                          size: isTablet ? 32 : 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // Calendar Days
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 20),
                    child: _buildCalendarGrid(),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isTablet ? 24 : 20),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

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
        Container(
          padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
          child: Row(
            children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurfaceVariant,
                          fontSize: isTablet ? 15 : 14,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        // Calendar days grid - made larger and more responsive
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: isDesktop
                  ? 1.2
                  : isTablet
                  ? 1.1
                  : 1.0,
              crossAxisSpacing: isTablet ? 8 : 4,
              mainAxisSpacing: isTablet ? 8 : 4,
            ),
            itemCount: 42, // 6 weeks
            physics: const NeverScrollableScrollPhysics(),
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
              final puasaInfo = widget.puasaData[dateKey];
              final isToday =
                  date.day == DateTime.now().day &&
                  date.month == DateTime.now().month &&
                  date.year == DateTime.now().year;

              return GestureDetector(
                onTap: () => widget.onDayTap(date, puasaInfo),
                child: Container(
                  margin: EdgeInsets.all(isTablet ? 4 : 2),
                  decoration: BoxDecoration(
                    gradient: puasaInfo != null
                        ? LinearGradient(
                            colors: puasaInfo['status'] == 'completed'
                                ? [
                                    AppTheme.accentGreen.withValues(alpha: 0.2),
                                    AppTheme.accentGreen.withValues(alpha: 0.1),
                                  ]
                                : [
                                    AppTheme.primaryBlue.withValues(alpha: 0.2),
                                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                                  ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                    border: isToday
                        ? Border.all(
                            color: AppTheme.primaryBlue,
                            width: isTablet ? 3 : 2,
                          )
                        : puasaInfo != null
                        ? Border.all(
                            color: puasaInfo['status'] == 'completed'
                                ? AppTheme.accentGreen.withValues(alpha: 0.3)
                                : AppTheme.primaryBlue.withValues(alpha: 0.3),
                            width: 1,
                          )
                        : Border.all(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            width: 1,
                          ),
                    boxShadow: puasaInfo != null
                        ? [
                            BoxShadow(
                              color:
                                  (puasaInfo['status'] == 'completed'
                                          ? AppTheme.accentGreen
                                          : AppTheme.primaryBlue)
                                      .withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayNumber.toString(),
                          style: TextStyle(
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: puasaInfo != null
                                ? (puasaInfo['status'] == 'completed'
                                      ? AppTheme.accentGreen
                                      : AppTheme.primaryBlue)
                                : isToday
                                ? AppTheme.primaryBlue
                                : AppTheme.onSurface,
                            fontSize: isDesktop
                                ? 18
                                : isTablet
                                ? 16
                                : 14,
                          ),
                        ),
                        if (puasaInfo != null) ...[
                          SizedBox(height: isTablet ? 4 : 2),
                          Container(
                            width: isTablet ? 8 : 6,
                            height: isTablet ? 8 : 6,
                            decoration: BoxDecoration(
                              color: puasaInfo['status'] == 'completed'
                                  ? AppTheme.accentGreen
                                  : AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
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

  Widget _buildStatCard(
    String value,
    String label,
    Color color,
    bool isTablet,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isTablet ? 18 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: isTablet ? 6 : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                color: AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
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
}
