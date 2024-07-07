import 'package:flutter/material.dart';
import 'package:scouting_app/widgets/reactive_check_box.dart';
import 'package:scouting_app/widgets/dataframe_table/widget_supplier.dart';

class CheckBoxSupplier extends WidgetSupplier with ChangeNotifier {
  bool isChecked;
  bool _enabled = true;

  CheckBoxSupplier({bool? checked, bool enabled = true})
      : isChecked = checked ?? false,
        _enabled = enabled;

  @override
  String get name => "checkbox";

  @override
  Widget get widget => _enabled
      ? Center(
          child: Transform.scale(
            scale: 1.3,
            child: ReactiveCheckBox(
              onSelected: (newValue) {
                if (newValue == null) return isChecked;
                isChecked = newValue;
                notifyListeners();
                return isChecked;
              },
              activeColor: () => Colors.blueGrey,
              checkColor: () => Colors.green,
              shape: const BeveledRectangleBorder(),
            ),
          ),
        )
      : Center(
          child: Transform.scale(
              scale: 1.3,
              child: Checkbox(
                activeColor: Colors.blueGrey,
                checkColor: Colors.green,
                onChanged: null,
                value: isChecked,
                shape: const BeveledRectangleBorder(),
              )),
        );

  Widget get clearWidget => _enabled
      ? Center(
          child: Transform.scale(
            scale: 1.75,
            child: ReactiveCheckBox(
              onSelected: (newValue) {
                if (newValue == null) return isChecked;
                isChecked = newValue;
                notifyListeners();
                return isChecked;
              },
              activeColor: () => Colors.black.withOpacity(0.6),
              checkColor: () => Colors.transparent,
              shape: null,
              color: Colors.white.withOpacity(0),
            ),
          ),
        )
      : Center(
          child: Transform.scale(
              scale: 1.3,
              child: Checkbox(
                activeColor: Colors.blueGrey,
                checkColor: Colors.green,
                onChanged: null,
                value: isChecked,
                shape: const BeveledRectangleBorder(),
              )),
        );

  void enable() {
    _enabled = true;
  }

  void disable() {
    _enabled = false;
  }
}
