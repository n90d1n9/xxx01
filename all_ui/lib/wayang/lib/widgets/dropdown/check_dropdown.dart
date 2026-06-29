import 'package:flutter/material.dart';

class CheckItem {
  final String label;
  final bool isEnable;
  final bool isActive;

  CheckItem({
    required this.label,
    this.isEnable = true,
    this.isActive = false,
  });
}

class CheckboxDropdown extends StatefulWidget {
  final List<CheckItem> items;
  final bool alignRight;

  const CheckboxDropdown({
    super.key,
    required this.items,
    this.alignRight = false, // default: left align
  });

  @override
  State<CheckboxDropdown> createState() => _CheckboxDropdownState();
}

class _CheckboxDropdownState extends State<CheckboxDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final Set<String> _selectedItems = {};

  final GlobalKey _buttonKey = GlobalKey();

  final double dropdownWidth = 250;

  @override
  void initState() {
    super.initState();

    for (var item in widget.items) {
      if (item.isActive) {
        _selectedItems.add(item.label);
      }
    }
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _showDropdown();
    } else {
      _removeDropdown();
    }
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showDropdown() {
    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final horizontalOffset = widget.alignRight
        ? size.width - dropdownWidth // right-align
        : 0.0; // left-align

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeDropdown,
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(horizontalOffset, size.height + 8),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: dropdownWidth,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: widget.items.map((item) {
                      return CheckboxListTile(
                        value: _selectedItems.contains(item.label),
                        title: Text(
                          item.label[0].toUpperCase() + item.label.substring(1),
                          style: TextStyle(
                            color: item.isEnable ? Colors.black87 : Colors.grey,
                          ),
                        ),
                        onChanged: item.isEnable
                            ? (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedItems.add(item.label);
                                  } else {
                                    _selectedItems.remove(item.label);
                                  }
                                });
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _removeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton(
        key: _buttonKey,
        icon: Icon(Icons.filter_list, color: Colors.deepPurple, size: 28),
        tooltip: _selectedItems.isEmpty
            ? "Pilih Opsi"
            : "Dipilih: ${_selectedItems.join(', ')}",
        onPressed: _toggleDropdown,
      ),
    );
  }
}
