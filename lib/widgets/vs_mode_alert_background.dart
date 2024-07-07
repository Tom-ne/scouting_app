import 'dart:math';

import 'package:flutter/material.dart';

class VsModeAlertBackground extends StatelessWidget {
  final Color color1;
  final Color color2;
  final double? diagonalWidth;
  final bool? diagonalDirection;
  final double? sliceBottomTop;
  final Widget? child;

  const VsModeAlertBackground({
    super.key,
    required this.color1,
    required this.color2,
    this.diagonalWidth,
    this.diagonalDirection,
    this.sliceBottomTop,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: VsModeAlertBackgroundPainter(
        color1: color1,
        color2: color2,
        diagonalWidthInput: diagonalWidth,
        diagonalDirection: diagonalDirection,
        sliceBottomTop: sliceBottomTop,
      ),
      isComplex: false,
      child: child,
    );
  }
}

class VsModeAlertBackgroundPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double? diagonalWidthInput;
  final bool? diagonalDirection;
  final double? sliceBottomTop;
  late final double _sliceBottomTop = sliceBottomTop ?? 0;
  late final double diagonalWidth = diagonalWidthInput ?? 80;

  VsModeAlertBackgroundPainter({
    required this.color1,
    required this.color2,
    this.diagonalWidthInput,
    this.diagonalDirection,
    this.sliceBottomTop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = color1
      ..strokeWidth = 0;
    final paint2 = Paint()
      ..color = color2
      ..strokeWidth = 0;

    final path0 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, min<double>(size.height, _sliceBottomTop))
      ..lineTo((size.width + diagonalWidth) / 2, min<double>(size.height, _sliceBottomTop))
      ..lineTo((size.width - diagonalWidth) / 2, size.height - min<double>(size.height, _sliceBottomTop))
      ..lineTo((size.width - diagonalWidth) / 2, size.height - min<double>(size.height, _sliceBottomTop))
      ..lineTo(0, size.height - min<double>(size.height, _sliceBottomTop))
      ..close();
    
    final Path path1;
    if (diagonalDirection == false) {
      path1 = path0.transform((Matrix4.identity()..translate(0.0, size.height)..scale(1.0, -1.0)).storage);
    }
    else {
      path1 = path0;
    }
    final path2 = path1.transform((Matrix4.identity()..translate(size.width, size.height)..scale(-1.0, -1.0)).storage);
    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
