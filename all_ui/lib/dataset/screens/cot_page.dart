import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChainOfThoughtPage extends ConsumerStatefulWidget {
  const ChainOfThoughtPage({super.key});

  @override
  ConsumerState<ChainOfThoughtPage> createState() => _ChainOfThoughtPageState();
}

class _ChainOfThoughtPageState extends ConsumerState<ChainOfThoughtPage> {
  String selectedStrategy = 'chain_of_thought';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chain of Thought & Reasoning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showCoTHelp(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Train models with advanced reasoning capabilities',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Strategy Selection
            Text(
              'Reasoning Strategy',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StrategyChip(
                  label: 'Chain of Thought',
                  icon: Icons.link,
                  description: 'Step-by-step reasoning',
                  selected: selectedStrategy == 'chain_of_thought',
                  onSelected:
                      () =>
                          setState(() => selectedStrategy = 'chain_of_thought'),
                ),
                _StrategyChip(
                  label: 'Self-Consistency',
                  icon: Icons.check_circle,
                  description: 'Multiple reasoning paths',
                  selected: selectedStrategy == 'self_consistency',
                  onSelected:
                      () =>
                          setState(() => selectedStrategy = 'self_consistency'),
                ),
                _StrategyChip(
                  label: 'Tree of Thoughts',
                  icon: Icons.account_tree,
                  description: 'Explore multiple branches',
                  selected: selectedStrategy == 'tree_of_thoughts',
                  onSelected:
                      () =>
                          setState(() => selectedStrategy = 'tree_of_thoughts'),
                ),
                _StrategyChip(
                  label: 'Reflexion',
                  icon: Icons.refresh,
                  description: 'Self-reflection & correction',
                  selected: selectedStrategy == 'reflexion',
                  onSelected:
                      () => setState(() => selectedStrategy = 'reflexion'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Strategy Configuration
            _buildStrategyConfig(),
            const SizedBox(height: 32),

            // Dataset Format for CoT
            Text(
              'CoT Dataset Format',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your dataset should include reasoning steps:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            '{\n'
                            '  "instruction": "Solve: 23 + 47",\n'
                            '  "reasoning": [\n'
                            '    "Step 1: Add the ones place: 3 + 7 = 10",\n'
                            '    "Step 2: Carry 1 to tens place",\n'
                            '    "Step 3: Add tens: 2 + 4 + 1 = 7",\n'
                            '    "Step 4: Combine: 70"\n'
                            '  ],\n'
                            '  "output": "70"\n'
                            '}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload CoT Dataset'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Generate CoT Data'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // CoT Training Examples
            Text(
              'Training Examples',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _CoTExampleCard(
                      question:
                          'If a train travels 120 miles in 2 hours, what is its average speed?',
                      reasoning: [
                        'Identify given information: distance = 120 miles, time = 2 hours',
                        'Recall formula: speed = distance / time',
                        'Substitute values: speed = 120 / 2',
                        'Calculate: speed = 60 miles per hour',
                      ],
                      answer: '60 miles per hour',
                    ),
                    const Divider(),
                    _CoTExampleCard(
                      question: 'Is 17 a prime number?',
                      reasoning: [
                        'Definition: A prime number is divisible only by 1 and itself',
                        'Check divisibility by 2: 17 ÷ 2 = 8.5 (not divisible)',
                        'Check divisibility by 3: 17 ÷ 3 = 5.67 (not divisible)',
                        'Check up to √17 ≈ 4.12',
                        'No divisors found except 1 and 17',
                      ],
                      answer: 'Yes, 17 is a prime number',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () => _startCoTTraining(context),
              icon: const Icon(Icons.psychology),
              label: const Text('Start CoT Training'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyConfig() {
    switch (selectedStrategy) {
      case 'chain_of_thought':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chain of Thought Configuration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'CoT teaches models to break down problems into logical steps.',
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Zero-shot CoT'),
                  subtitle: const Text(
                    'Add "Let\'s think step by step" prompt',
                  ),
                  value: true,
                  onChanged: (_) {},
                ),
                SwitchListTile(
                  title: const Text('Few-shot CoT'),
                  subtitle: const Text('Include example reasoning paths'),
                  value: true,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Number of reasoning steps',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: '4',
                ),
              ],
            ),
          ),
        );
      case 'self_consistency':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Self-Consistency Configuration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Generate multiple reasoning paths and select the most consistent answer.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Number of reasoning paths',
                    border: OutlineInputBorder(),
                    helperText: 'Generate N different reasoning approaches',
                  ),
                  initialValue: '5',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Voting mechanism',
                    border: OutlineInputBorder(),
                  ),
                  value: 'Majority voting',
                  items:
                      ['Majority voting', 'Weighted voting', 'Confidence-based']
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          )
                          .toList(),
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        );
      case 'tree_of_thoughts':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tree of Thoughts Configuration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Explore multiple branches of reasoning like a search tree.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Branching factor',
                    border: OutlineInputBorder(),
                    helperText: 'Number of alternative thoughts per step',
                  ),
                  initialValue: '3',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tree depth',
                    border: OutlineInputBorder(),
                    helperText: 'Maximum reasoning depth',
                  ),
                  initialValue: '4',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Search strategy',
                    border: OutlineInputBorder(),
                  ),
                  value: 'BFS',
                  items:
                      ['BFS', 'DFS', 'Best-first']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        );
      case 'reflexion':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reflexion Configuration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Model reflects on its mistakes and learns from feedback.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Max reflection iterations',
                    border: OutlineInputBorder(),
                    helperText: 'How many times to retry with reflection',
                  ),
                  initialValue: '3',
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Use external feedback'),
                  subtitle: const Text(
                    'Incorporate test results or evaluator feedback',
                  ),
                  value: true,
                  onChanged: (_) {},
                ),
                SwitchListTile(
                  title: const Text('Store reflection memory'),
                  subtitle: const Text(
                    'Remember past reflections for future tasks',
                  ),
                  value: true,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showCoTHelp(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chain of Thought Training'),
            content: const SingleChildScrollView(
              child: Column(
                //crossAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chain of Thought (CoT):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '• Teaches models to show intermediate reasoning steps\n'
                    '• Improves performance on complex reasoning tasks\n'
                    '• Makes model outputs more interpretable\n',
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Self-Consistency:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '• Samples multiple reasoning paths\n'
                    '• Selects most consistent final answer\n'
                    '• Reduces errors from incorrect reasoning\n',
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Tree of Thoughts:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '• Explores multiple reasoning branches\n'
                    '• Uses search algorithms (BFS/DFS)\n'
                    '• Best for complex multi-step problems\n',
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Reflexion:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '• Model reflects on mistakes\n'
                    '• Iteratively improves responses\n'
                    '• Learns from feedback loops\n',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _startCoTTraining(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CoT training job submitted!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _StrategyChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final bool selected;
  final VoidCallback onSelected;

  const _StrategyChip({
    required this.label,
    required this.icon,
    required this.description,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              selected ? Theme.of(context).colorScheme.primaryContainer : null,
          border: Border.all(
            color:
                selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color:
                      selected ? Theme.of(context).colorScheme.primary : null,
                ),
                const SizedBox(width: 8),
                if (selected)
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoTExampleCard extends StatelessWidget {
  final String question;
  final List<String> reasoning;
  final String answer;

  const _CoTExampleCard({
    required this.question,
    required this.reasoning,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.question_answer, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.purple.shade700),
                    const SizedBox(width: 12),
                    Text(
                      'Reasoning Steps:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...reasoning.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(left: 32, top: 4),
                    child: Text(
                      '${entry.key + 1}. ${entry.value}',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Text('Answer: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(answer)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
