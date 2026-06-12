import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_governance_review_pack_models.dart';
import 'incoming_talent_governance_command_center_provider.dart';

/// Executive review pack derived from current talent governance signals.
final incomingTalentGovernanceReviewPackProvider =
    Provider<IncomingTalentGovernanceReviewPack>((ref) {
      return buildIncomingTalentGovernanceReviewPack(
        ref.watch(incomingTalentGovernanceCommandCenterProvider),
      );
    });
