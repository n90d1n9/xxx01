// Cloud Storage Service (Mock)
import '../models/project.dart';

class CloudStorageService {
  Future<void> saveProject(Project project) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    // In real implementation: await http.post(...);
    print('Project saved to cloud: ${project.id}');
  }

  Future<Project> loadProject(String projectId) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    // In real implementation: await http.get(...);
    throw UnimplementedError('Load from cloud not implemented');
  }

  Future<List<Project>> listProjects() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }
}
