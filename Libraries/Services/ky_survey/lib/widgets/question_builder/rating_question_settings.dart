import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RatingQuestionSettings extends StatelessWidget {
  final TextEditingController minRatingController;
  final TextEditingController maxRatingController;

  const RatingQuestionSettings({
    super.key,
    required this.minRatingController,
    required this.maxRatingController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating Scale',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minRatingController,
                decoration: const InputDecoration(
                  labelText: 'Min Rating',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: maxRatingController,
                decoration: const InputDecoration(
                  labelText: 'Max Rating',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
