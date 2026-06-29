import 'package:flutter_riverpod/legacy.dart';

import '../model/human_approval_request.dart';

final approvalRequestsProvider = StateProvider<List<HumanApprovalRequest>>(
  (ref) => [],
);
