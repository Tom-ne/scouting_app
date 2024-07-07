import 'package:flutter/material.dart';
import 'package:scouting_app/widgets/buttons/dialog_button.dart';

class DenyButton extends StatefulBuilder {
  DenyButton({
    super.key,
    void Function()? onPressed,
    EdgeInsets? padding,
    EdgeInsets? childPadding,
    String? text,
    Widget? child,
  }) : super(builder: (context, setState) {
          return DialogButton(
              onPressed: onPressed,
              padding: padding,
              childPadding: childPadding,
              buttonColor: Colors.red.shade800,
              splashColor: Colors.red.shade700,
              child: child ??
                  Text(
                    text ?? '',
                    style: const TextStyle(color: Colors.white),
                  ));
        });
}
