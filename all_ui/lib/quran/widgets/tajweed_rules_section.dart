import 'package:flutter/material.dart';

import '../models/tajweed_rule_info.dart';
import 'tajweed_rule_card.dart';

class TajweedRulesSection extends StatelessWidget {
  final String text;
  const TajweedRulesSection({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    final rules = _detectTajweedRules(text);
    if (rules.isEmpty) {
      return const Text('No specific tajweed rules detected in this ayah.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tajweed Rules Found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...rules.map((rule) => TajweedRuleCard(rule: rule)).toList(),
      ],
    );
  }

  List<TajweedRuleInfo> _detectTajweedRules(String text) {
    final List<TajweedRuleInfo> foundRules = [];
    if (text.contains('نْ') || text.contains('مْ')) {
      foundRules.add(
        TajweedRuleInfo(
          name: 'Ghunnah (غنة)',
          description:
              'Nasal sound produced from the nose when pronouncing ن or م with sukoon, held for 2 counts.',
          color: const Color(0xFF4CAF50),
          example: 'منْ - من',
        ),
      );
    }
    if (text.contains(RegExp(r'[قطبجد]ْ'))) {
      foundRules.add(
        TajweedRuleInfo(
          name: 'Qalqalah (قلقلة)',
          description:
              'Echoing/bouncing sound when pronouncing ق ط ب ج د with sukoon.',
          color: const Color(0xFFE91E63),
          example: 'قَدْ - قد',
        ),
      );
    }
    if (text.contains(RegExp(r'[اوىي]'))) {
      foundRules.add(
        TajweedRuleInfo(
          name: 'Madd (مد)',
          description:
              'Prolongation of certain vowels. Natural madd is held for 2 counts.',
          color: const Color(0xFF00BCD4),
          example: 'قَالَ - قال',
        ),
      );
    }
    if (text.contains(RegExp(r'نْ[يرملون]'))) {
      foundRules.add(
        TajweedRuleInfo(
          name: 'Idgham (إدغام)',
          description:
              'Merging of noon sakinah or tanween into one of the six letters: ي ر م ل و ن',
          color: const Color(0xFF2196F3),
          example: 'منْ يَعْمَلْ',
        ),
      );
    }
    if (text.contains(RegExp(r'نْب')) || text.contains(RegExp(r'مْب'))) {
      foundRules.add(
        TajweedRuleInfo(
          name: 'Iqlab (إقلاب)',
          description:
              'Converting noon sakinah or tanween to م sound when followed by ب',
          color: const Color(0xFF9C27B0),
          example: 'منْ بَعْدِ',
        ),
      );
    }
    if (text.contains(RegExp(r'نْ[صذثكجشقسدطزفتضظ]'))) {
      foundRules.add(
        TajweedRuleInfo(
          name: 'Ikhfa (إخفاء)',
          description:
              'Hiding/concealing noon sakinah or tanween when followed by 15 specific letters.',
          color: const Color(0xFFFF9800),
          example: 'منْ شَرِّ',
        ),
      );
    }
    return foundRules;
  }
}
