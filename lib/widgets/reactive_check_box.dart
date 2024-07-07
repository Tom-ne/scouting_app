import 'package:flutter/material.dart';

class ReactiveCheckBox extends StatefulWidget {
  final double width;
  final Alignment alignment;
  final bool Function(bool?) onSelected;
  final ChangeNotifier? setStateNotifier;
  final Color? Function()? activeColor;
  final Color? Function()? checkColor;
  final OutlinedBorder? shape;
  final Color? color;

  const ReactiveCheckBox({
    super.key,
    this.width = 24.0,
    this.alignment = Alignment.center,
    required this.onSelected,
    this.activeColor,
    this.checkColor,
    this.shape = const CircleBorder(),
    this.color,
    this.setStateNotifier,
  });

  @override
  State<ReactiveCheckBox> createState() => _ReactiveCheckBoxState();
}

class _ReactiveCheckBoxState extends State<ReactiveCheckBox> {
  Color? activeColor;
  Color? checkColor;

  @override
  void initState() {
    super.initState();
    widget.setStateNotifier?.addListener.call(update);
  }

  @override
  void dispose() {
    widget.setStateNotifier?.removeListener.call(update);
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  void onChanged(bool? newValue) {
    setState(() {
      widget.onSelected(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onSelected(null)) {
      activeColor = widget.activeColor?.call();
      checkColor = widget.checkColor?.call();
    }
    return Container(
      alignment: widget.alignment,
      width: widget.width,
      child: Checkbox(
        shape: widget.shape,
        side: widget.color != null ? BorderSide(color: widget.color!, width: 2) : null,
        activeColor: activeColor,
        checkColor: checkColor,
        value: widget.onSelected(null),
        onChanged: onChanged,
        tristate: false,
      ),
    );
  }
}
