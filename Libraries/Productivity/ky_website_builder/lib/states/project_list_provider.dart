// List available projects from cloud
import 'package:flutter_riverpod/legacy.dart';

import '../models/project.dart';
import 'provider.dart';

final projectListProvider = FutureProvider<List<Project>>((ref) async {
  final cloudService = ref.watch(cloudStorageServiceProvider);
  return await cloudService.listProjects();
});
