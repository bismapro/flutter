// lib/utils/responsive.dart
import 'package:flutter/material.dart';

/// Breakpoints ala material (silakan ubah sesuai kebutuhan)
enum DeviceSize { mobile, tablet, desktop }

class Responsive {
  final BuildContext context;
  final Size _size;
  final double _textScale;
  final Orientation _orientation;
  final double _devicePixelRatio;

  Responsive._(
    this.context,
    this._size,
    this._textScale,
    this._orientation,
    this._devicePixelRatio,
  );

  factory Responsive.of(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Responsive._(
      context,
      mq.size,
      mq.textScaleFactor,
      mq.orientation,
      mq.devicePixelRatio,
    );
  }

  // --- Info dasar ---
  double get width => _size.width;
  double get height => _size.height;
  Orientation get orientation => _orientation;
  double get dpr => _devicePixelRatio;

  // --- Breakpoint detection ---
  DeviceSize get deviceSize {
    final w = width;
    if (w >= 1024) return DeviceSize.desktop;
    if (w >= 600) return DeviceSize.tablet;
    return DeviceSize.mobile;
  }

  bool get isMobile => deviceSize == DeviceSize.mobile;
  bool get isTablet => deviceSize == DeviceSize.tablet;
  bool get isDesktop => deviceSize == DeviceSize.desktop;

  // --- Helper ukuran relatif ---
  /// width * percent (0..1)
  double wp(double percent) => width * percent;

  /// height * percent (0..1)
  double hp(double percent) => height * percent;

  /// Spacing konsisten (skala berdasarkan lebar)
  double space(double units) =>
      (width / 375.0) * units; // 375 = baseline iPhone 11/Pixel 3 width

  // --- Typography scaling aman ---
  /// Skala font yang lebih stabil (kombinasi logical + textScale pengguna)
  double sp(double font) {
    final scale = width / 375.0; // ganti baseline sesuai desain
    final value = font * scale;
    // batasi supaya tidak ekstrem saat textScale besar/kecil
    return value / (_textScale.clamp(0.85, 1.3));
  }

  // --- Nilai responsif berdasarkan breakpoint ---
  T pick<T>({required T mobile, T? tablet, T? desktop}) {
    switch (deviceSize) {
      case DeviceSize.mobile:
        return mobile;
      case DeviceSize.tablet:
        return (tablet ?? mobile);
      case DeviceSize.desktop:
        return (desktop ?? tablet ?? mobile);
    }
  }
}

/// Widget builder berbasis breakpoint (opsional jika suka gaya declarative)
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    if (r.isDesktop && desktop != null) return desktop!(context);
    if (r.isTablet && tablet != null) return tablet!(context);
    return mobile(context);
  }
}
