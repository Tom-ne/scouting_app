import 'package:flutter/material.dart';

class ImageSubpartPainter extends CustomPainter {
  final ImageInfo imageInfo;
  final Rect subpartRect;

  ImageSubpartPainter(this.imageInfo, this.subpartRect);

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the destination rectangle to fit the subpartRect into the canvas
    final dstRect = Offset.zero & size;

    // Draw the subpart of the image onto the canvas
    canvas.drawImageRect(
      imageInfo.image,
      subpartRect, // Source rectangle (subpart of the image)
      dstRect, // Destination rectangle (canvas size)
      Paint(), // Paint
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}