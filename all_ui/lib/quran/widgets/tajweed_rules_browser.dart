import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/surah.dart';

import '../states/quran_provider.dart';
import 'tajweed_rules_database.dart';
import 'tajweed_text.dart';

class TajweedRulesBrowser extends ConsumerStatefulWidget {
  const TajweedRulesBrowser({super.key});
  @override
  ConsumerState<TajweedRulesBrowser> createState() =>
      _TajweedRulesBrowserState();
}

class _TajweedRulesBrowserState extends ConsumerState<TajweedRulesBrowser> {
  TajweedCategory? _selectedCategory;
  String? _selectedRuleId;
  @override
  Widget build(BuildContext context) {
    final groupedRules = TajweedRulesDatabase.getRulesGroupedByCategory();
    return Row(
      children: [
        Container(
          width: 120,
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          child: ListView(
            children: [
              _buildCategoryItem(context, null, 'All Rules', Icons.list),
              const Divider(),
              ...TajweedCategory.values.map((category) {
                return _buildCategoryItem(
                  context,
                  category,
                  _getCategoryName(category),
                  _getCategoryIcon(category),
                );
              }),
            ],
          ),
        ),
        Expanded(
          child:
              _selectedRuleId != null
                  ? _buildRuleDetail()
                  : _buildRulesList(groupedRules),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    TajweedCategory? category,
    String name,
    IconData icon,
  ) {
    final isSelected = _selectedCategory == category;
    return ListTile(
      dense: true,
      selected: isSelected,
      leading: Icon(icon, size: 20),
      title: Text(name, style: const TextStyle(fontSize: 12)),
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _selectedRuleId = null;
        });
      },
    );
  }

  Widget _buildRulesList(Map<TajweedCategory, List<TajweedRule>> groupedRules) {
    if (_selectedCategory == null) {
      return ListView(
        children:
            TajweedCategory.values.map((category) {
              final rules = groupedRules[category]!;
              if (rules.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(_getCategoryIcon(category), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _getCategoryName(category),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  ...rules.map((rule) => _buildRuleCard(rule)),
                  const Divider(),
                ],
              );
            }).toList(),
      );
    } else {
      final rules = groupedRules[_selectedCategory]!;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _getCategoryName(_selectedCategory!),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...rules.map((rule) => _buildRuleCard(rule)),
        ],
      );
    }
  }

  Widget _buildRuleCard(TajweedRule rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() => _selectedRuleId = rule.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: rule.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rule.arabicName,
                      style: const TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rule.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleDetail() {
    final rule = TajweedRulesDatabase.getRule(_selectedRuleId!);
    if (rule == null) return const Center(child: Text('Rule not found'));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () {
              setState(() => _selectedRuleId = null);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Rules'),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: rule.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: rule.color, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  rule.arabicName,
                  style: const TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(rule.description, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Detailed Explanation',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(rule.detailedExplanation, style: const TextStyle(height: 1.6)),
          const SizedBox(height: 24),
          Text('Examples', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...rule.examples.map(
            (example) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  example,
                  style: const TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              _searchAyahsWithRule(rule);
            },
            icon: const Icon(Icons.search),
            label: const Text('Find Ayahs with this Rule'),
          ),
        ],
      ),
    );
  }

  Future<void> _searchAyahsWithRule(TajweedRule rule) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Searching for ayahs with this rule...'),
                  ],
                ),
              ),
            ),
          ),
    );
    try {
      final quranData = await ref.read(quranServiceProvider).getAllQuranText();
      final surahs = await ref.read(surahListProvider.future);
      final List<SearchResult> results = [];
      for (var entry in quranData.entries) {
        final surahNumber = entry.key;
        final surahAyahs = entry.value;
        final surah = surahs.firstWhere((s) => s.number == surahNumber);
        for (int i = 0; i < surahAyahs.length; i++) {
          final ayahText = surahAyahs[i];
          bool matches = false;
          for (var pattern in rule.patterns) {
            final regex = RegExp(pattern);
            if (regex.hasMatch(ayahText)) {
              matches = true;
              break;
            }
          }
          if (matches) {
            results.add(
              SearchResult(
                ayah: Ayah(
                  number: i + 1,
                  text: ayahText,
                  numberInSurah: i + 1,
                  surahNumber: surahNumber,
                ),
                surahName: surah.englishName,
              ),
            );
          }
        }
      }
      if (mounted) {
        Navigator.pop(context);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder:
              (context) => DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.5,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Found ${results.length} ayahs with ${rule.name}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final result = results[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                title: TajweedText(
                                  text: result.ayah.text,
                                  fontSize: 20,
                                ),
                                subtitle: Text(
                                  '${result.surahName} ${result.ayah.surahNumber}:${result.ayah.numberInSurah}',
                                ),
                                onTap: () {},
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _getCategoryName(TajweedCategory category) {
    switch (category) {
      case TajweedCategory.nun:
        return 'Noon Rules';
      case TajweedCategory.meem:
        return 'Meem Rules';
      case TajweedCategory.madd:
        return 'Madd Rules';
      case TajweedCategory.qalqalah:
        return 'Qalqalah';
      case TajweedCategory.lam:
        return 'Lam Rules';
      case TajweedCategory.ra:
        return 'Ra Rules';
      case TajweedCategory.misc:
        return 'Other Rules';
    }
  }

  IconData _getCategoryIcon(TajweedCategory category) {
    switch (category) {
      case TajweedCategory.nun:
        return Icons.filter_1;
      case TajweedCategory.meem:
        return Icons.filter_2;
      case TajweedCategory.madd:
        return Icons.arrow_forward;
      case TajweedCategory.qalqalah:
        return Icons.vibration;
      case TajweedCategory.lam:
        return Icons.wb_sunny;
      case TajweedCategory.ra:
        return Icons.waves;
      case TajweedCategory.misc:
        return Icons.more_horiz;
    }
  }
}
