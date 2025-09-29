import 'package:flutter/material.dart';

/// Widget untuk section header dengan styling yang konsisten
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFF1E88E5), size: 24),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
