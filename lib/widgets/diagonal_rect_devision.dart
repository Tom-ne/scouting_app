import 'package:flutter/material.dart';

class DiagonalSplitBackground extends StatelessWidget {
  final Color color1;
  final Color color2;
  final Widget? child;

  const DiagonalSplitBackground({
    super.key,
    required this.color1,
    required this.color2,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: DiagonalSplitPainter(color1: color1, color2: color2),
      isComplex: false,
      child: child,
    );
  }
}

class DiagonalSplitPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  DiagonalSplitPainter({
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;

    final path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    final path2 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
