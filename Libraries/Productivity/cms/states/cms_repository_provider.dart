import 'package:flutter_riverpod/legacy.dart';

import '../services/cms_repository.dart';

final cmsRepositoryProvider = Provider<CMSRepository>((ref) => CMSRepository());
