import 'package:flutter/material.dart';
import 'package:syirkah/core/utils/constants.dart';

class DropFilter extends StatefulWidget {
  final Function(String?) onSelect;
  final String? label;
  final String? hint;
  final List<String> data;
  final double width;
  final double height;

  const DropFilter(
      {super.key,
      required this.onSelect,
      this.label,
      this.width = 180,
      this.height = 50,
      this.hint = '',
      required this.data});

  @override
  State<DropFilter> createState() => _DropFilterState();
}

class _DropFilterState extends State<DropFilter> {
  @override
  Widget build(BuildContext context) {
    var selectedDate = '';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        widget.label!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: titleMediumFontSize,
        ),
      ),
      Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(3))),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              disabledBorder: UnderlineInputBorder(),
             // border: OutlineInputBorder(),
            ),
            value: widget.data[0],
            hint: Text(widget.hint!),
            items: items(widget.data),
            onChanged: (value) {
              setState(() {
                selectedDate = value!;
              });
              widget.onSelect(selectedDate);
            },
          ))
    ]);
  }

  List<DropdownMenuItem<String>>? items(List<String> data) => data
      .map((el) => DropdownMenuItem(
            value: el,
            child: Text(el),
          ))
      .toList();
}
