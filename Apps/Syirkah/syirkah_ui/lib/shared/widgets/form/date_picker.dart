import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:syirkah/core/utils/constants.dart';
import 'package:syirkah/modules/ecommerce/utils/dimens.dart';

class FormDatePicker extends StatefulWidget {
  final DateTime? defaultDate;
  final ValueChanged<DateTime> onChanged;
  final double width;
  final double height;
  final String? label;

  const FormDatePicker({
    super.key,
    this.defaultDate,
    required this.onChanged,
    this.width = 120,
    this.height = 50,
    this.label,
  });

  @override
  State<FormDatePicker> createState() => FormDatePickerState();
}

class FormDatePickerState extends State<FormDatePicker> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        widget.label!,
        style: const TextStyle(
            fontWeight: fontWeightBold, fontSize: titleMediumFontSize),
      ),
      GestureDetector(
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(3))),
          child: Text(
            formated(widget.defaultDate ?? selectedDate),
            textAlign: TextAlign.center,
            style: const TextStyle(
                textBaseline: TextBaseline.alphabetic,
                fontSize: titleMediumFontSize),
          ),
        ),
        onTap: () async {
          var newDate = await showDatePicker(
            context: context,
            initialDate: widget.defaultDate,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );

          // Don't change the date if the date picker returns null.
          if (newDate == null) {
            return;
          }
          setState(() {
            selectedDate = newDate;
          });
          widget.onChanged(selectedDate);
        },
      )
    ]);
  }
}

formated(DateTime selectedDate) => intl.DateFormat.yMd().format(selectedDate);
