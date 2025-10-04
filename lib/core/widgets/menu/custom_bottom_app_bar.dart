import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import '../../../../app/theme.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomAppBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(
              FlutterIslamicIcons.prayingPerson,
              'Sholat',
              1,
            ), // ← ganti jadi ikon rukuk
            _buildNavItem(FlutterIslamicIcons.quran2, 'Al-Quran', 2),
            _buildNavItem(FlutterIslamicIcons.family, 'Monitoring', 3),
            _buildNavItem(Icons.forum_outlined, 'Community', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.primaryBlue
                    : AppTheme.onSurfaceVariant,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
