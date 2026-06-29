import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/cms_repository.dart';

final cmsRepositoryProvider = Provider<CMSRepository>((ref) => CMSRepository());
