import 'package:flutter/material.dart';

class TabScoutContent extends StatefulWidget {
  final String tabKey;
  final TextStyle textStyle;
  final ChangeNotifier? changeNotifier;
  final Widget? icon;
  final Widget? iconSecondState;
  final bool Function()? hideIcon;
  final void Function()? onUpdate;

  const TabScoutContent({
    super.key,
    required this.tabKey,
    required this.textStyle,
    this.changeNotifier,
    this.icon,
    this.iconSecondState,
    this.hideIcon,
    this.onUpdate,
  });

  @override
  State<TabScoutContent> createState() => _TabScoutContentState();
}

class _TabScoutContentState extends State<TabScoutContent> {
  @override
  void initState() {
    widget.changeNotifier?.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    widget.changeNotifier?.removeListener(update);
    super.dispose();
  }

  void update() {
    setState(() {
      widget.onUpdate?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Visibility(
          visible: widget.icon != null && !(widget.hideIcon?.call() ?? false),
          child: widget.icon!,
        ),
        Text(
          widget.tabKey,
          style: widget.textStyle,
        ),
      ],
    );
  }
}