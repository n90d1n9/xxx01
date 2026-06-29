import 'package:flutter/material.dart';

import 'gtable.dart';

class GtableSample01 extends StatefulWidget {
  const GtableSample01({super.key});

  @override
  State<GtableSample01> createState() => _GtableSample01State();
}

class _GtableSample01State extends State<GtableSample01> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(' Flutter DataGrid'),
        ),
        body: GTable(
          rawdata: sample,
        ));
  }
}

var sample = {
  "columns": [
    {"id": "id", "value": "ID"},
    {"id": "name", "value": "NAME"},
    {"id": "price", "value": "PRICE"},
    {"id": "desc", "value": "DESCRIPTION"},
  ],
  "rows": [
    [1, "satu", 20000, "fhgg"],
    [2, "dua", 56000, "eaa"],
    [3, "tiga", 755300, "qq"],
    [4, "pat", 555300, "fgh"],
    [5, "ma", 56000, "aa"],
    [6, "nem", 755300, "aadd"],
    [7, "juh", 555300, "fgggh"],
  ],
};
