import 'package:flutter/material.dart';

class ReactiveTextField extends StatefulWidget {
  final InputDecoration Function(String)? onChanged;
  final TextEditingController? textController;

  const ReactiveTextField({
    super.key,
    this.onChanged,
    this.textController,
  });

  @override
  State<ReactiveTextField> createState() => _ReactiveTextFieldState();
}

class _ReactiveTextFieldState extends State<ReactiveTextField> {
  late final textController = widget.textController ?? TextEditingController();
  InputDecoration decoration = const InputDecoration();

  void onChanged(String newValue) {
    setState(() {
      decoration = widget.onChanged?.call(newValue) ?? const InputDecoration();
    });
  }

  @override
  void initState() {
    super.initState();
    onChanged(textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      onChanged: onChanged,
      decoration: decoration,
    );
  }
}
