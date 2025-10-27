import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/core/utils/connection/connection_provider.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';

class OfflineBadge extends ConsumerWidget {
  const OfflineBadge({super.key});

  double _t(BuildContext context, double base) =>
      ResponsiveHelper.adaptiveTextSize(context, base);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionProvider);

    if (connectionState.isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.orange.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Anda sedang offline.',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: _t(context, 12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
