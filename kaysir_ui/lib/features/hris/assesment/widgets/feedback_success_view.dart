import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

class FeedbackSuccessView extends StatelessWidget {
  const FeedbackSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: hrisPanelDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF059669),
              size: 72,
            ),
            const SizedBox(height: 18),
            Text(
              'Feedback Submitted',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you for your valuable input',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
