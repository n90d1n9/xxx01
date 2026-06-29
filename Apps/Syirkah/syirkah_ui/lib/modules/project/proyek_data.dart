/*

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProjectDataWidget extends StatefulWidget {
  const ProjectDataWidget({super.key});

  @override
  State<ProjectDataWidget> createState() => _ProjectDataWidgetState();
}

class _ProjectDataWidgetState extends State<ProjectDataWidget> {
  final List<ProjectData> _projectData = [
    ProjectData(
        'Pemrosesan Kegiatan 1',
        'P-001',
        'Pemrosesan Kegiatan 1',
        'PT Persada',
        'Ali',
        'Job Order',
        '123',
        '07/01/2014',
        '14/01/2014',
        'In Progress',
        'Ridwan',
        true,
        56,
        'Pemrosesan Kegiatan 1',
        'No Phase',
        'No Cost Code',
        0.00,
        0.00),
    ProjectData(
        'Pemrosesan Kegiatan 1',
        'P-001',
        'Pemrosesan Kegiatan 1',
        'PT Persada',
        'Ali',
        'Job Order',
        '123',
        '07/01/2014',
        '14/01/2014',
        'In Progress',
        'Ridwan',
        true,
        56,
        'Pemrosesan Kegiatan 1',
        '03-Preparation',
        '01-Labor',
        3500000.00,
        4480000.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Proyek'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Internal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text('N/A'),
                          SizedBox(height: 8.0),
                          Text('Pending'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overseas Project',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text('Overseas Corp'),
                          SizedBox(height: 8.0),
                          Text('In Progress67'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pemrosesan Kegiatan 1',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text('PT Persada'),
                          SizedBox(height: 8.0),
                          Text('In Progress36'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pemrosesan Kegiatan 2',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text('Pertiwi Agung'),
                          SizedBox(height: 8.0),
                          Text('In Progress'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pemrosesan Kegiatan 1',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProjectDetail('Id Proyek', 'P-001'),
                            _buildProjectDetail('Nama Proyek',
                                'Pemrosesan Kegiatan 1'),
                            _buildProjectDetail('Pelanggan', 'PT Persada'),
                            _buildProjectDetail('Manajer Proyek', 'Ali'),
                            _buildProjectDetail('Jenis Pekerjaan', 'Job Order'),
                            _buildProjectDetail('Nomor Job Order', '123'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProjectDetail('Tanggal Pesan',
                                '07/01/2014'),
                            _buildProjectDetail('Tanggal Pengiriman',
                                '14/01/2014'),
                            _buildProjectDetail('Status', 'In Progress'),
                            _buildProjectDetail('Kontak', 'Ridwan'),
                            _buildProjectDetail('Menggunakan Fase', 'True'),
                            _buildProjectDetail('Kemajuan', '56 %'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                 */
/*  SizedBox(
                    height: 20,
                    child: SfLinearGauge(
                      minimum: 0,
                      maximum: 100,
                      orientation: LinearGaugeOrientation.horizontal,
                      ranges: <LinearGaugeRange>[
                        LinearGaugeRange(
                          startValue: 0,
                          endValue: 56,
                          color: Colors.lightBlue,
                        ),
                        LinearGaugeRange(
                          startValue: 56,
                          endValue: 100,
                          color: Colors.grey,
                        ),
                      ],
                      labelFormatter: (value) {
                        return '${value.toInt()}%';
                      },
                    ),
                  ), *//*

                  const SizedBox(height: 16.0),
                  const Text(
                    'Anggaran Proyek Dan Realisasi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'January 01, 2014 - December 31, 2014',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SfDataGrid(
                    source: ProjectDataSource(_projectData),
                    columnWidthMode: ColumnWidthMode.fill,
                    columns:  [
                      GridColumn(
                        columnName: 'No. Proyek',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'No. Proyek',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'Fase Pekerjaan',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'Fase Pekerjaan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'Kode Biaya',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'Kode Biaya',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'Anggaran Belanja',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'Anggaran Belanja',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'Realisasi',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'Realisasi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}

class ProjectData {
  ProjectData(
      this.projectName,
      this.projectId,
      this.projectTitle,
      this.clientName,
      this.projectManager,
      this.jobType,
      this.jobOrderNumber,
      this.orderDate,
      this.deliveryDate,
      this.status,
      this.contactPerson,
      this.usePhase,
      this.progress,
      this.projectNo,
      this.phase,
      this.costCode,
      this.budget,
      this.realization);

  final String projectName;
  final String projectId;
  final String projectTitle;
  final String clientName;
  final String projectManager;
  final String jobType;
  final String jobOrderNumber;
  final String orderDate;
  final String deliveryDate;
  final String status;
  final String contactPerson;
  final bool usePhase;
  final int progress;
  final String projectNo;
  final String phase;
  final String costCode;
  final double budget;
  final double realization;
}

class ProjectDataSource extends DataGridSource {
  ProjectDataSource(this._projectData) {
    _dataGridRows = _projectData
        .map<DataGridRow>((dataGridRow) => DataGridRow(
              cells: [
                DataGridCell<String>(columnName: 'No. Proyek', value: dataGridRow.projectNo),
                DataGridCell<String>(columnName: 'Fase Pekerjaan', value: dataGridRow.phase),
                DataGridCell<String>(columnName: 'Kode Biaya', value: dataGridRow.costCode),
                DataGridCell<double>(columnName: 'Anggaran Belanja', value: dataGridRow.budget),
                DataGridCell<double>(columnName: 'Realisasi', value: dataGridRow.realization),
              ],
            ))
        .toList();
  }

  List<DataGridRow> _dataGridRows = [];
  final List<ProjectData> _projectData;

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(dataGridCell.value.toString()),
        );
      }).toList(),
    );
  }

  @override
  int get rowCount => _dataGridRows.length;

  @override
  int get columnCount => 5;
}
*/
