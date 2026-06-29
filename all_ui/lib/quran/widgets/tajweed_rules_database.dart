import 'package:flutter/material.dart';

import '../models/tajweed_category.dart';
import '../models/tajweed_rule.dart';

class TajweedRulesDatabase {
  static final Map<String, TajweedRule> _rules = {
    'idgham_ghunnah': TajweedRule(
      id: 'idgham_ghunnah',
      name: 'Idgham with Ghunnah',
      arabicName: 'إدغام بغنة',
      description:
          'Merging Noon Sakinah/Tanween with ي ن م و with nasal sound (2 counts)',
      detailedExplanation:
          '''When Noon Sakinah (نْ) or Tanween meets one of the letters ي ن م و, 
the noon is merged into the following letter with ghunnah (nasal sound) held for 2 counts. 
This is called Idgham bi Ghunnah (merging with ghunnah).''',
      color: const Color(0xFF2196F3),
      category: TajweedCategory.nun,
      patterns: [r'نْ[ينمو]', r'ً[ينمو]', r'ٍ[ينمو]', r'ٌ[ينمو]'],
      examples: ['مَنْ يَعْمَلْ', 'صَفًّا مِنْ', 'عَلِيمٌ مَّا'],
      priority: 10,
    ),
    'idgham_no_ghunnah': TajweedRule(
      id: 'idgham_no_ghunnah',
      name: 'Idgham without Ghunnah',
      arabicName: 'إدغام بغير غنة',
      description: 'Merging Noon Sakinah/Tanween with ل ر without ghunnah',
      detailedExplanation:
          '''When Noon Sakinah or Tanween is followed by ل or ر, 
the noon completely merges into the following letter without ghunnah.''',
      color: const Color(0xFF1976D2),
      category: TajweedCategory.nun,
      patterns: [r'نْ[لر]', r'ً[لر]', r'ٍ[لر]', r'ٌ[لر]'],
      examples: ['مِنْ رَبِّهِمْ', 'هُدًى لِّلْمُتَّقِينَ'],
      priority: 10,
    ),
    'iqlab': TajweedRule(
      id: 'iqlab',
      name: 'Iqlab',
      arabicName: 'إقلاب',
      description: 'Converting Noon Sakinah/Tanween to م when followed by ب',
      detailedExplanation: '''When Noon Sakinah or Tanween is followed by ب, 
it is converted to the sound of م (Meem) with ghunnah for 2 counts, while keeping the lips closed.''',
      color: const Color(0xFF9C27B0),
      category: TajweedCategory.nun,
      patterns: [r'نْب', r'ًب', r'ٍب', r'ٌب'],
      examples: ['مِنْ بَعْدِ', 'سَمِيعٌ بَصِيرٌ', 'أَنْبِئْهُمْ'],
      priority: 11,
    ),
    'ikhfa': TajweedRule(
      id: 'ikhfa',
      name: 'Ikhfa',
      arabicName: 'إخفاء',
      description: 'Hiding Noon Sakinah/Tanween before 15 letters',
      detailedExplanation:
          '''When Noon Sakinah or Tanween is followed by one of 15 letters 
(ص ذ ث ك ج ش ق س د ط ز ف ت ض ظ), it is hidden/concealed with ghunnah for 2 counts.''',
      color: const Color(0xFFFF9800),
      category: TajweedCategory.nun,
      patterns: [
        r'نْ[صذثكجشقسدطزفتضظ]',
        r'ً[صذثكجشقسدطزفتضظ]',
        r'ٍ[صذثكجشقسدطزفتضظ]',
        r'ٌ[صذثكجشقسدطزفتضظ]',
      ],
      examples: ['مَنْ شَرِّ', 'عَلِيمٌ ذُو', 'مِنْ صَلْصَالٍ'],
      priority: 9,
    ),
    'izhar': TajweedRule(
      id: 'izhar',
      name: 'Izhar Halqi',
      arabicName: 'إظهار حلقي',
      description:
          'Clear pronunciation of Noon Sakinah/Tanween before throat letters',
      detailedExplanation:
          '''When Noon Sakinah or Tanween is followed by one of the 6 throat letters 
(ء ه ع ح غ خ), it must be pronounced clearly without ghunnah.''',
      color: const Color(0xFF4CAF50),
      category: TajweedCategory.nun,
      patterns: [r'نْ[ءهعحغخ]', r'ً[ءهعحغخ]', r'ٍ[ءهعحغخ]', r'ٌ[ءهعحغخ]'],
      examples: ['مِنْ أَنْفُسِهِمْ', 'قَوْمٌ عَادٍ', 'كُفُوًا أَحَدٌ'],
      priority: 9,
    ),
    'idgham_meem': TajweedRule(
      id: 'idgham_meem',
      name: 'Idgham Meem Sakinah',
      arabicName: 'إدغام متماثلين',
      description: 'Merging Meem Sakinah into another Meem with ghunnah',
      detailedExplanation:
          '''When a Meem Sakinah (مْ) is followed by another Meem (م), 
they merge together with ghunnah for 2 counts.''',
      color: const Color(0xFF66BB6A),
      category: TajweedCategory.meem,
      patterns: [r'مْم'],
      examples: ['لَهُم مَّا', 'أَم مَّنْ'],
      priority: 11,
    ),
    'ikhfa_shafawi': TajweedRule(
      id: 'ikhfa_shafawi',
      name: 'Ikhfa Shafawi',
      arabicName: 'إخفاء شفوي',
      description: 'Hiding Meem Sakinah before ب with ghunnah',
      detailedExplanation: '''When Meem Sakinah (مْ) is followed by ب, 
the meem is hidden with ghunnah for 2 counts while lips remain closed.''',
      color: const Color(0xFFBA68C8),
      category: TajweedCategory.meem,
      patterns: [r'مْب'],
      examples: ['تَرْمِيهِمْ بِحِجَارَةٍ', 'وَهُمْ بِالْآخِرَةِ'],
      priority: 11,
    ),
    'izhar_shafawi': TajweedRule(
      id: 'izhar_shafawi',
      name: 'Izhar Shafawi',
      arabicName: 'إظهار شفوي',
      description:
          'Clear pronunciation of Meem Sakinah before all letters except م and ب',
      detailedExplanation:
          '''When Meem Sakinah is followed by any letter except م or ب, 
it must be pronounced clearly from the lips without ghunnah.''',
      color: const Color(0xFF81C784),
      category: TajweedCategory.meem,
      patterns: [r'مْ[^مب]'],
      examples: ['هُمْ فِيهَا', 'وَأَنتُمْ سَامِدُونَ'],
      priority: 8,
    ),
    'qalqalah_sughra': TajweedRule(
      id: 'qalqalah_sughra',
      name: 'Qalqalah Sughra',
      arabicName: 'قلقلة صغرى',
      description: 'Minor echoing sound with ق ط ب ج د in the middle of words',
      detailedExplanation:
          '''When one of the Qalqalah letters (ق ط ب ج د) has sukoon 
in the middle of a word, produce a slight echoing/bouncing sound.''',
      color: const Color(0xFFE91E63),
      category: TajweedCategory.qalqalah,
      patterns: [r'قْ', r'طْ', r'بْ', r'جْ', r'دْ'],
      examples: ['يَقْطَعُونَ', 'أَبْصَارَهُمْ', 'اجْتَبَاهُ'],
      priority: 7,
    ),
    'qalqalah_kubra': TajweedRule(
      id: 'qalqalah_kubra',
      name: 'Qalqalah Kubra',
      arabicName: 'قلقلة كبرى',
      description: 'Major echoing sound with ق ط ب ج د at word end (stopping)',
      detailedExplanation:
          '''When stopping on a word that ends with one of the Qalqalah letters, 
produce a stronger echoing/bouncing sound.''',
      color: const Color(0xFFC2185B),
      category: TajweedCategory.qalqalah,
      patterns: [r'قطبجد'],
      examples: ['يَقْطَعُونَ', 'أَبْصَارَهُمْ', 'اجْتَبَاهُ'],
      priority: 6,
    ),
    'qaf': TajweedRule(
      id: 'qaf',
      name: 'Qaf',
      arabicName: 'قاف',
      description: 'The letter ق',
      detailedExplanation:
          '''The letter ق is pronounced with the tip of the tongue touching the palate behind the front teeth, 
-producing a guttural sound.''',
      color: const Color(0xFF9C27B0),
      category: TajweedCategory.qaf,
      patterns: [r'ق'],
      examples: ['قَالَ', 'قَالَتْ', 'قَالَتْ'],
      priority: 5,
    ),
    'qaf': TajweedRule(
      id: 'qaf',
      name: 'Qaf',
      arabicName: 'قاف',
      description: 'The letter ق',
      detailedExplanation:
          '''The letter ق is pronounced with the tip of the tongue touching the palate behind the front teeth, 
-producing a guttural sound.''',
      color: const Color(0xFF9C27B0),
      category: TajweedCategory.qaf,
      patterns: [r'ق'],
      examples: ['قَالَ', 'قَالَتْ', 'قَالَتْ'],
      priority: 5,
    ),
  };

  static getAllRules() {}

  static getRule(String s) {}

  static getRulesGroupedByCategory() {}
}
