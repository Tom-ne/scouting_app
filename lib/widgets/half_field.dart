import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scouting_app/config/match/match_constants.dart';
import 'package:scouting_app/widgets/dataframe_table/reactive_checkbox_supplier.dart';
import 'package:scouting_app/widgets/flippable_image.dart';
import 'package:scouting_app/widgets/images_handling/image_subpart_painter.dart';
import 'package:scouting_app/utils/preferences.dart';

class HalfField extends StatefulWidget {
  final bool Function()? colorBlue;
  final ChangeNotifier? update;
  final double width;
  final double height;
  final bool enabled;
  final CheckBoxSupplier close1;
  final CheckBoxSupplier close2;
  final CheckBoxSupplier close3;
  final CheckBoxSupplier far1;
  final CheckBoxSupplier far2;
  final CheckBoxSupplier far3;
  final CheckBoxSupplier far4;
  final CheckBoxSupplier far5;

  const HalfField({
    super.key,
    this.colorBlue,
    this.update,
    required this.close1,
    required this.close2,
    required this.close3,
    required this.far1,
    required this.far2,
    required this.far3,
    required this.far4,
    required this.far5,
    required this.width,
    required this.height,
    required this.enabled,
  });

  @override
  State<HalfField> createState() => _HalfFieldState();
}

class _HalfFieldState extends State<HalfField> {
  static const double percentCloseX = 0.24;
  static const double percentCloseYStart = 0.145;
  static const double percentCloseYDiff = 0.178;

  static const double percentFarX = 0.79;
  static const double percentFarYStart = 0.093;
  static const double percentFarYDiff = 0.204;

  static const double checkBoxLength = 30;
  late Color currentColor;
  late Widget flippableImage;
  bool flipHorizontal = false;
  bool flipVertical = false;

  double getXPercent(double percent) {
    return percent;
  }

  @override
  void initState() {
    initialValues();
    updateImage();
    widget.update?.addListener(updateFunction);
    UserPreferences.preferencesNotifier.addListener(updateFunction);
    super.initState();
  }

  void initialValues() {
    flipHorizontal =
        UserPreferences.instantGet(UserPreferences.flipFieldHorizontaly)
            as bool;
    flipVertical =
        UserPreferences.instantGet(UserPreferences.flipFieldVerticaly) as bool;
  }

  @override
  void dispose() {
    UserPreferences.preferencesNotifier.removeListener(updateFunction);
    widget.update?.removeListener(updateFunction);
    super.dispose();
  }

  void updateImage() {
    currentColor = widget.colorBlue?.call() ?? false ? Colors.blue : Colors.red;
    flippableImage = Container(
      color: Colors.black87,
      width: widget.width,
      height: widget.height,
      alignment: Alignment.topLeft,
      child: FlippableWidget(
        invertHorizontally: flipHorizontal,
        invertVertically: flipVertical,
        child: getHalfFieldImage(currentColor),
      ),
    );
  }

  Widget getHalfFieldImage(Color color) {
    bool blueHalf = color == Colors.blue;
    return FutureBuilder<ImageInfo>(
      future: _fetchImageInfo(MatchConstants.fieldImage),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return cropHalf(snapshot.data!, blueHalf);
        } else {
          return const SizedBox
              .shrink(); // Placeholder or loading indicator can be added here
        }
      },
    );
  }

  Widget cropHalf(ImageInfo info, bool isRightHalf) {
    Size imageSize =
        Size(info.image.width.toDouble(), info.image.height.toDouble());
    double cropedWidth = imageSize.width * 0.45;
    Rect subpartRect = Rect.fromLTWH(isRightHalf ? 0 : cropedWidth, 0,
        imageSize.width - cropedWidth, imageSize.height);
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: ImageSubpartPainter(info, subpartRect),
        child: const SizedBox.expand(),
      ),
    );
  }

  Future<ImageInfo> _fetchImageInfo(ImageProvider imageProvider) async {
    final completer = Completer<ImageInfo>();
    final imageStream = imageProvider.resolve(const ImageConfiguration());
    imageStream.addListener(ImageStreamListener((info, synchronousCall) {
      completer.complete(info);
    }));
    return completer.future;
  }

  void updateFunction() {
    setState(() {
      updateImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enabled) {
      widget.close1.enable();
      widget.close2.enable();
      widget.close3.enable();
      widget.far1.enable();
      widget.far2.enable();
      widget.far3.enable();
      widget.far4.enable();
      widget.far5.enable();
    } else {
      widget.close1.disable();
      widget.close2.disable();
      widget.close3.disable();
      widget.far1.disable();
      widget.far2.disable();
      widget.far3.disable();
      widget.far4.disable();
      widget.far5.disable();
    }
    List<Widget> closeCheckboxes = [
      SizedBox(
        height: (widget.height * percentCloseYStart) - checkBoxLength / 2,
      ),
      Container(
        color: currentColor,
        width: checkBoxLength,
        height: checkBoxLength,
        child: widget.close1.widget,
      ),
      SizedBox(
        height: (widget.height * percentCloseYDiff) - checkBoxLength,
      ),
      Container(
        color: currentColor,
        width: checkBoxLength,
        height: checkBoxLength,
        child: widget.close2.widget,
      ),
      SizedBox(
        height: (widget.height * percentCloseYDiff) - checkBoxLength,
      ),
      Container(
        color: currentColor,
        width: checkBoxLength,
        height: checkBoxLength,
        child: widget.close3.widget,
      ),
      SizedBox(
        height:
            (widget.height * (1 - percentCloseYStart - 2 * percentCloseYDiff)) -
                checkBoxLength / 2,
      ),
    ];
    List<Widget> farCheckboxes = [
      SizedBox(
        height: (widget.height * percentFarYStart) - checkBoxLength / 2,
      ),
      Container(
        color: currentColor,
        width: checkBoxLength,
        height: checkBoxLength,
        child: widget.far1.widget,
      ),
      SizedBox(
        height: (widget.height * percentFarYDiff) - checkBoxLength,
      ),
      Container(
        color: currentColor,
        width: checkBoxLength,
        height: checkBoxLength,
        child: widget.far2.widget,
      ),
      SizedBox(
        height: (widget.height * percentFarYDiff) - checkBoxLength,
      ),
      Container(
        color: currentColor,
        width: checkBoxLength,
        height: checkBoxLength,
        child: widget.far3.widget,
      ),
      SizedBox(
        height: (widget.height * percentFarYDiff) - checkBoxLength,
      ),
      Container(
        color: currentColor,
        width: checkBoxLength,
        height: checkBoxLength,
        child: widget.far4.widget,
      ),
      SizedBox(
        height: (widget.height * percentFarYDiff) - checkBoxLength,
      ),
      Container(
        color: currentColor,
        width: checkBoxLength,
        height: checkBoxLength,
        child: widget.far5.widget,
      ),
      SizedBox(
        height: (widget.height * (1 - percentFarYStart - 4 * percentFarYDiff)) -
            checkBoxLength / 2,
      ),
    ];
    List<Widget> checkboxRowChildren = [
      SizedBox(
        width: widget.width * getXPercent(percentCloseX) - checkBoxLength / 2,
      ),
      Column(
        children:
            flipVertical ? closeCheckboxes.reversed.toList() : closeCheckboxes,
      ),
      SizedBox(
        width: widget.width * getXPercent(percentFarX - percentCloseX) -
            checkBoxLength / 2,
      ),
      Column(
        children:
            flipVertical ? farCheckboxes.reversed.toList() : farCheckboxes,
      ),
      SizedBox(
        width:
            (widget.width * getXPercent(1 - percentFarX) - checkBoxLength / 2),
      ),
    ];

    List<Widget> closeNotes = [
      SizedBox(
        height: (widget.height * percentCloseYStart) - checkBoxLength / 2,
      ),
      Container(
        alignment: Alignment.center,
        width: checkBoxLength,
        height: checkBoxLength,
        child: const Text(
          "C1",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: (widget.height * percentCloseYDiff) - checkBoxLength,
      ),
      Container(
        alignment: Alignment.center,
        width: checkBoxLength,
        height: checkBoxLength,
        child: const Text(
          "C2",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: (widget.height * percentCloseYDiff) - checkBoxLength,
      ),
      Container(
        alignment: Alignment.center,
        width: checkBoxLength,
        height: checkBoxLength,
        child: const Text(
          "C3",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height:
            (widget.height * (1 - percentCloseYStart - 2 * percentCloseYDiff)) -
                checkBoxLength / 2,
      ),
    ];
    List<Widget> farNotes = [
      SizedBox(
        height: (widget.height * percentFarYStart) - checkBoxLength / 2,
      ),
      Container(
        alignment: Alignment.center,
        width: checkBoxLength,
        height: checkBoxLength,
        child: const Text(
          "F1",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: (widget.height * percentFarYDiff) - checkBoxLength,
      ),
      Container(
        alignment: Alignment.center,
        width: checkBoxLength,
        height: checkBoxLength,
        child: const Text(
          "F2",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: (widget.height * percentFarYDiff) - checkBoxLength,
      ),
      Container(
        alignment: Alignment.center,
        width: checkBoxLength,
        height: checkBoxLength,
        child: const Text(
          "F3",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: (widget.height * percentFarYDiff) - checkBoxLength,
      ),
      Container(
        alignment: Alignment.center,
        width: checkBoxLength,
        height: checkBoxLength,
        child: const Text(
          "F4",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: (widget.height * percentFarYDiff) - checkBoxLength,
      ),
      Container(
        alignment: Alignment.center,
        width: checkBoxLength,
        height: checkBoxLength,
        child: const Text(
          "F5",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: (widget.height * (1 - percentFarYStart - 4 * percentFarYDiff)) -
            checkBoxLength / 2,
      ),
    ];
    List<Widget> rowChildren = [
      SizedBox(
        width: widget.width * getXPercent(percentCloseX) -
            checkBoxLength / 2 -
            (3 / 2) * checkBoxLength,
      ),
      Column(
        children: flipVertical ? closeNotes.reversed.toList() : closeNotes,
      ),
      SizedBox(
        width: widget.width * getXPercent(percentFarX - percentCloseX) -
            checkBoxLength / 2,
      ),
      Column(
        children: flipVertical ? farNotes.reversed.toList() : farNotes,
      ),
      SizedBox(
        width: (widget.width * getXPercent(1 - percentFarX) -
            checkBoxLength / 2 +
            (3 / 2) * checkBoxLength),
      ),
    ];
    return Stack(
      children: [
        flippableImage,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: (flipHorizontal ^ (currentColor == Colors.blue))
              ? checkboxRowChildren
              : checkboxRowChildren.reversed.toList(),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: (flipHorizontal ^ (currentColor == Colors.blue))
              ? rowChildren
              : rowChildren.reversed.toList(),
        ),
      ],
    );
  }
}
