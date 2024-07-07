import 'package:flutter/material.dart';

class DialogButton extends StatelessWidget {
  final void Function()? onPressed;
  final EdgeInsets? padding;
  final EdgeInsets? childPadding;
  final Color buttonColor;
  final Color splashColor;
  final Widget child;

  const DialogButton({
    super.key,
    this.onPressed,
    this.padding,
    this.childPadding,
    required this.buttonColor,
    required this.splashColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 5),
      child: InkWell(
        onTap: onPressed,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        splashColor: splashColor,
        child: Container(
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: childPadding ??
              const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: child,
        ),
      ),
    );
  }
}
