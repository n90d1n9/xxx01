import 'package:flutter/material.dart';

class FilterWidget extends StatefulWidget {
  const FilterWidget({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: _selectedDate,
            hint: const Text('Select Date'),
            items: const [
              DropdownMenuItem(
                value: 'Last Month',
                child: Text('Last Month'),
              ),
              DropdownMenuItem(
                value: 'Last Quarter',
                child: Text('Last Quarter'),
              ),
              DropdownMenuItem(
                value: 'Current Year To Date',
                child: Text('Current Year To Date'),
              ),
              DropdownMenuItem(
                value: 'Last Year',
                child: Text('Last Year'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedDate = value;
              });
            },
          ),
          const SizedBox(height: 16.0),
          const Text(
            'From',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            initialValue: '01/01/2024',
          ),
          const SizedBox(height: 16.0),
          const Text(
            'To',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            initialValue: '05/23/2024',
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Order channel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: _selectedOrderChannel,
            hint: const Text('Select Order Channel'),
            items: const [
              DropdownMenuItem(
                value: 'None selected',
                child: Text('None selected'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedOrderChannel = value;
              });
            },
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Order type',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: _selectedOrderType,
            hint: const Text('Select Order Type'),
            items: const [
              DropdownMenuItem(
                value: 'None selected',
                child: Text('None selected'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedOrderType = value;
              });
            },
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Store country',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: _selectedStoreCountry,
            hint: const Text('Select Store Country'),
            items: const [
              DropdownMenuItem(
                value: 'None selected',
                child: Text('None selected'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStoreCountry = value;
              });
            },
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Store type',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: _selectedStoreType,
            hint: const Text('Select Store Type'),
            items: const [
              DropdownMenuItem(
                value: 'None selected',
                child: Text('None selected'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStoreType = value;
              });
            },
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Store',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: _selectedStore,
            hint: const Text('Select Store'),
            items: const [
              DropdownMenuItem(
                value: 'None selected',
                child: Text('None selected'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStore = value;
              });
            },
          ),
        ],
      ),
    );
  }
}