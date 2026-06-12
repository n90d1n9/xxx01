import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/boq_category.dart';
import '../models/project.dart';

class FormatHelper {
  static final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  static String getStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.perencanaan:
        return 'Perencanaan';
      case ProjectStatus.pelaksanaan:
        return 'Pelaksanaan';
      case ProjectStatus.selesai:
        return 'Selesai';
      case ProjectStatus.ditunda:
        return 'Ditunda';
    }
  }

  static Color getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.perencanaan:
        return Colors.blue;
      case ProjectStatus.pelaksanaan:
        return Colors.orange;
      case ProjectStatus.selesai:
        return Colors.green;
      case ProjectStatus.ditunda:
        return Colors.red;
    }
  }

  static String getCategoryText(BoQCategory category) {
    switch (category) {
      case BoQCategory.pekerjaanPersiapan:
        return 'Pekerjaan Persiapan';
      case BoQCategory.pekerjaanTanah:
        return 'Pekerjaan Tanah';
      case BoQCategory.pekerjaanStruktur:
        return 'Pekerjaan Struktur';
      case BoQCategory.pekerjaanArsitektur:
        return 'Pekerjaan Arsitektur';
      case BoQCategory.pekerjaanMekanikal:
        return 'Pekerjaan Mekanikal';
      case BoQCategory.pekerjaanElektrikal:
        return 'Pekerjaan Elektrikal';
      case BoQCategory.pekerjaanPlumbing:
        return 'Pekerjaan Plumbing';
      case BoQCategory.pekerjaanLandscaping:
        return 'Pekerjaan Landscaping';
    }
  }
}
