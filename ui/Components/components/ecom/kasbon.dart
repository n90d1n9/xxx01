import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class KasbonWidget extends StatefulWidget {
  const KasbonWidget({Key? key}) : super(key: key);

  @override
  State<KasbonWidget> createState() => _KasbonWidgetState();
}

class _KasbonWidgetState extends State<KasbonWidget> {
  final List<Kasbon> _kasbons = [
    Kasbon(
        nama: 'Yuni',
        jatuhTempo: DateTime(2020, 10, 15),
        nominal: 85000,
        isLunas: false),
    Kasbon(
        nama: 'nadya',
        jatuhTempo: DateTime(2020, 10, 21),
        nominal: 55000,
        isLunas: false),
    Kasbon(
        nama: 'cust 01',
        jatuhTempo: DateTime(2020, 10, 27),
        nominal: 115000,
        isLunas: false),
  ];

  List<Kasbon> _filteredKasbons = [];
  String _searchQuery = '';
  bool _showBelumLunas = true;
  bool _showLunas = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _filteredKasbons = _kasbons;
  }

  void _filterKasbons() {
    setState(() {
      _filteredKasbons = _kasbons.where((kasbon) {
        final namaMatch = kasbon.nama.toLowerCase().contains(
            _searchQuery.toLowerCase());
        final lunasMatch =
            (_showBelumLunas && !kasbon.isLunas) ||
                (_showLunas && kasbon.isLunas);
        final dateMatch = kasbon.jatuhTempo.compareTo(_selectedDate) == 0;
        return namaMatch && lunasMatch && dateMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasbon'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterKasbons();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Nama',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: SfCalendar(
                    view: CalendarView.month,
                    onSelectionChanged: (selectionDetails) {
                      setState(() {
                        _selectedDate = selectionDetails.date!;
                        _filterKasbons();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Checkbox(
                  value: _showBelumLunas,
                  onChanged: (value) {
                    setState(() {
                      _showBelumLunas = value!;
                      _filterKasbons();
                    });
                  },
                ),
                const Text('Belum Lunas'),
                const SizedBox(width: 16.0),
                Checkbox(
                  value: _showLunas,
                  onChanged: (value) {
                    setState(() {
                      _showLunas = value!;
                      _filterKasbons();
                    });
                  },
                ),
                const Text('Lunas'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredKasbons.length,
              itemBuilder: (context, index) {
                final kasbon = _filteredKasbons[index];
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(kasbon.nama),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JT: ${DateFormat('yyyy/MM/dd').format(kasbon.jatuhTempo)}',
                      ),
                      Text(
                        'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(kasbon.nominal)}',
                      ),
                    ],
                  ),
                  trailing: kasbon.isLunas
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Kasbon {
  final String nama;
  final DateTime jatuhTempo;
  final int nominal;
  final bool isLunas;

  Kasbon({
    required this.nama,
    required this.jatuhTempo,
    required this.nominal,
    required this.isLunas,
  });
}