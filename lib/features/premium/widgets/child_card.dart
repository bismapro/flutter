import 'package:flutter/material.dart';
import '../models/child_data.dart';

/// Widget untuk menampilkan card informasi anak
class ChildCard extends StatelessWidget {
  final ChildData child;
  final VoidCallback? onTap;

  const ChildCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row dengan Avatar dan Info
          Row(
            children: [
              // Avatar dengan gradient background
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E88E5), Color(0xFF26A69A)],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E88E5).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    child.avatarUrl,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          child.prayedToday
                              ? Icons.check_circle
                              : Icons.warning_rounded,
                          size: 18,
                          color: child.prayedToday
                              ? const Color(0xFF26A69A)
                              : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            child.prayedToday
                                ? 'Sholat hari ini lengkap'
                                : 'Ada sholat terlewat',
                            style: TextStyle(
                              fontSize: 13,
                              color: child.prayedToday
                                  ? const Color(0xFF26A69A)
                                  : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge Count dengan styling yang lebih menarik
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF26A69A).withOpacity(0.1),
                      const Color(0xFF26A69A).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF26A69A).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 18,
                      color: Color(0xFF26A69A),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${child.totalBadges}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF26A69A),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Divider dengan styling yang lebih soft
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Stats Row dengan spacing yang lebih baik
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.local_fire_department,
                '${child.prayerStreak} hari',
                'Streak Sholat',
              ),
              Container(
                width: 1,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.grey.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              _buildStatItem(
                Icons.menu_book,
                '${child.quranProgress}%',
                'Progres Quran',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1E88E5), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
