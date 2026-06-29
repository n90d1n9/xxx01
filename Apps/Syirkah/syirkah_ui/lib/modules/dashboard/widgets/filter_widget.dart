import 'package:flutter/material.dart';

import 'package:syirkah/modules/dashboard/widgets/drop_filter.dart';
import 'package:syirkah/shared/widgets/form/date_picker.dart';

class FilterWidget extends StatefulWidget {
  const FilterWidget({super.key});

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  String? _selectedDate;
  String? _selectedOrderChannel;
  String? _selectedOrderType;
  String? _selectedStoreCountry;
  String? _selectedStoreType;
  String? _selectedStore;

  get date => null;

  onChanged(value) {
    print(value);
  }

  onSelect(value) {
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    const dateFilter = [
      'Last Month',
      'Last Quarter',
      'Current Year To Date',
      'Last Year',
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        DropFilter(
            height: 50, onSelect: onSelect, label: 'Tanggal', data: dateFilter),
        const SizedBox(
          width: 5,
        ),
        FormDatePicker(height: 50, label: 'From', onChanged: onChanged),
        const SizedBox(
          width: 5,
        ),
        FormDatePicker(height: 50, label: 'To', onChanged: onChanged),
      ]),
    );
  }
}
