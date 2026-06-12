import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/csv/export_csv.dart';

final exportServiceProvider = Provider((ref) => ExportService());
