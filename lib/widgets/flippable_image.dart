import 'package:flutter/material.dart';

class FlippableWidget extends StatelessWidget {
  final Widget child;
  final bool invertHorizontally;
  final bool invertVertically;

  const FlippableWidget({
    super.key,
    required this.child,
    this.invertHorizontally = false,
    this.invertVertically = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..scale(invertHorizontally ? -1.0 : 1.0, invertVertically ? -1.0 : 1.0),
      alignment: Alignment.center,
      child: child,
    );
  }
}
