import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_mobility_form_fields.dart';

class IncomingTalentMobilityOwnerFields extends StatelessWidget {
  final TextEditingController sponsorController;
  final TextEditingController ownerController;
  final ValueChanged<String> onSponsorChanged;
  final ValueChanged<String> onOwnerChanged;

  const IncomingTalentMobilityOwnerFields({
    super.key,
    required this.sponsorController,
    required this.ownerController,
    required this.onSponsorChanged,
    required this.onOwnerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sponsor = IncomingTalentMobilityTextInput(
          controller: sponsorController,
          label: 'Sponsor',
          icon: Icons.verified_user_outlined,
          onChanged: onSponsorChanged,
          validator:
              (value) =>
                  validateIncomingTalentMobilityRequired(value, 'a sponsor'),
        );
        final owner = IncomingTalentMobilityTextInput(
          controller: ownerController,
          label: 'Mobility owner',
          icon: Icons.badge_outlined,
          onChanged: onOwnerChanged,
          validator:
              (value) => validateIncomingTalentMobilityRequired(
                value,
                'a mobility owner',
              ),
        );

        if (constraints.maxWidth < 620) {
          return Column(children: [sponsor, const SizedBox(height: 12), owner]);
        }

        return Row(
          children: [
            Expanded(child: sponsor),
            const SizedBox(width: 12),
            Expanded(child: owner),
          ],
        );
      },
    );
  }
}
