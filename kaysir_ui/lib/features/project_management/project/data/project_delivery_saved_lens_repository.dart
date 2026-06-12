import '../services/project_delivery_saved_lens_service.dart';

abstract class ProjectDeliverySavedLensRepository {
  const ProjectDeliverySavedLensRepository();

  List<ProjectDeliverySavedCommandLens> fetchSavedLenses({
    required ProjectDeliverySavedLensProfile profile,
  });
}

class DemoProjectDeliverySavedLensRepository
    extends ProjectDeliverySavedLensRepository {
  const DemoProjectDeliverySavedLensRepository();

  @override
  List<ProjectDeliverySavedCommandLens> fetchSavedLenses({
    required ProjectDeliverySavedLensProfile profile,
  }) {
    return projectDeliverySavedLensesForProfile(profile);
  }
}
