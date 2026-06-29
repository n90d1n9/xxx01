// Templates Provider
import 'package:flutter_riverpod/legacy.dart';

import '../dummy.dart';
import '../model/event_template.dart';

final templatesProvider = StateProvider<List<EventTemplate>>(
  (ref) => eventTemplates,
);
