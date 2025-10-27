import 'package:flutter/material.dart';

class CustomCenterDockedFAB extends FloatingActionButtonLocation {
  final double offsetY;

  const CustomCenterDockedFAB({this.offsetY = 0});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    final scaffoldSize = scaffoldGeometry.scaffoldSize;

    // posisi horizontal: tengah
    final x = (scaffoldSize.width - fabSize.width) / 2;

    // posisi vertical: nempel bawah (dock)
    final y =
        scaffoldSize.height -
        fabSize.height -
        scaffoldGeometry.minInsets.bottom;

    // geser ke bawah sesuai offset
    return Offset(x, y - offsetY);
  }
}
