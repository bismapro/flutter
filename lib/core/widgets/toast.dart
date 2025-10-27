import 'package:flutter/material.dart';

enum ToastType { success, error, info, warning }

class MessageToast extends StatelessWidget {
  final String message;
  final ToastType type;
  final VoidCallback? onDismiss;

  const MessageToast({
    super.key,
    required this.message,
    required this.type,
    this.onDismiss,
  });

  Color _backgroundColor() {
    switch (type) {
      case ToastType.success:
        return Colors.green.shade50;
      case ToastType.error:
        return Colors.red.shade50;
      case ToastType.warning:
        return Colors.orange.shade50;
      case ToastType.info:
        return Colors.blue.shade50;
    }
  }

  Color _borderColor() {
    switch (type) {
      case ToastType.success:
        return Colors.green.shade200;
      case ToastType.error:
        return Colors.red.shade200;
      case ToastType.warning:
        return Colors.orange.shade200;
      case ToastType.info:
        return Colors.blue.shade200;
    }
  }

  IconData _icon() {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }

  Color _iconColor() {
    switch (type) {
      case ToastType.success:
        return Colors.green.shade700;
      case ToastType.error:
        return Colors.red.shade700;
      case ToastType.warning:
        return Colors.orange.shade700;
      case ToastType.info:
        return Colors.blue.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDismiss?.call(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _backgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor()),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(_icon(), color: _iconColor()),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: TextStyle(color: _iconColor())),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fungsi helper untuk menampilkan toast overlay
void showMessageToast(
  BuildContext context, {
  required String message,
  ToastType type = ToastType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: MessageToast(
          message: message,
          type: type,
          onDismiss: () {
            overlayEntry.remove();
          },
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}
