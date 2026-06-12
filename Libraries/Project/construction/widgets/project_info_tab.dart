import 'package:flutter/material.dart';

import '../models/project.dart';
import '../utils/format_helper.dart';

class ProjectInfoTab extends StatelessWidget {
  final Project project;

  const ProjectInfoTab({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Proyek',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24),
                _buildInfoRow('Nama Proyek', project.nama),
                _buildInfoRow('Klien', project.klien),
                _buildInfoRow('Lokasi', project.lokasi),
                _buildInfoRow(
                  'Status',
                  FormatHelper.getStatusText(project.status),
                  color: FormatHelper.getStatusColor(project.status),
                ),
                _buildInfoRow(
                  'Total Budget',
                  FormatHelper.currencyFormat.format(project.totalBudget),
                ),
                _buildInfoRow(
                  'Tanggal Mulai',
                  FormatHelper.dateFormat.format(project.tanggalMulai),
                ),
                _buildInfoRow(
                  'Tanggal Selesai',
                  FormatHelper.dateFormat.format(project.tanggalSelesai),
                ),
                if (project.deskripsi != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(project.deskripsi!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
