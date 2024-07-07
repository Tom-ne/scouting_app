import 'package:flutter/material.dart';
import 'package:scouting_app/widgets/buttons/dialog_button.dart';

class AcceptButton extends StatefulBuilder {
  AcceptButton({
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
              buttonColor: Theme.of(context).primaryColor,
              splashColor: Theme.of(context).secondaryHeaderColor,
              child: child ??
                  Text(
                    text ?? '',
                    style: const TextStyle(color: Colors.white),
                  ));
        });
}
