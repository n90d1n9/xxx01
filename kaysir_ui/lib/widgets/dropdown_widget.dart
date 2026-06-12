import 'package:flutter/material.dart';

import '../utils/helper.dart';

class DropdownItem {
  const DropdownItem({this.title = '', this.icon = 'home', this.onTap});
  final String title;
  final String icon;
  final void Function()? onTap;
}

class Dropdown extends StatefulWidget {
  const Dropdown({
    super.key, //required this.account,
    required this.items,
  });
  // final String account;
  final List<DropdownItem> items;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  String? dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = _firstItemTitle;
  }

  @override
  void didUpdateWidget(covariant Dropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.items.any((item) => item.title == dropdownValue)) {
      dropdownValue = _firstItemTitle;
    }
  }

  String? get _firstItemTitle =>
      widget.items.isEmpty ? null : widget.items.first.title;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.keyboard_arrow_down),
      elevation: 10,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      /*  underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ), */
      onChanged: (String? value) {
        DropdownItem? selectedItem;
        for (final item in widget.items) {
          if (item.title == value) {
            selectedItem = item;
            break;
          }
        }

        setState(() {
          dropdownValue = value;
        });
        selectedItem?.onTap?.call();
      },
      items:
          widget.items
              .map<DropdownMenuItem<String>>(
                (DropdownItem m) => DropdownMenuItem<String>(
                  value: m.title,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      getIcon(m.icon),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(m.title, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
