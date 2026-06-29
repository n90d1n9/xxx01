import 'package:flutter_riverpod/legacy.dart';

import '../models/deployment_config.dart';

final deploymentConfigProvider = StateProvider<DeploymentConfig?>(
  (ref) => null,
);
