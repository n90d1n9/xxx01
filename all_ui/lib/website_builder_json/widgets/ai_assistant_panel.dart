import 'package:flutter/material.dart';

import '../services/ai_assistant.dart';

class AIAssistantPanel extends StatefulWidget {
  const AIAssistantPanel({Key? key}) : super(key: key);

  @override
  State<AIAssistantPanel> createState() => _AIAssistantPanelState();
}

class _AIAssistantPanelState extends State<AIAssistantPanel> {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  String _generatedContent = '';

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Assistant',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _promptController,
            decoration: InputDecoration(
              hintText: 'Describe what you want to create...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon:
                    _isGenerating
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.send),
                onPressed: _isGenerating ? null : _generateContent,
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Quick prompts
          const Text(
            'Quick Actions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickActionChip(
                label: 'Generate Hero Section',
                icon: Icons.panorama,
                onTap:
                    () => _generateWithPrompt('Create a modern hero section'),
              ),
              _QuickActionChip(
                label: 'Write Copy',
                icon: Icons.edit,
                onTap: () => _generateWithPrompt('Write engaging copy'),
              ),
              _QuickActionChip(
                label: 'Improve SEO',
                icon: Icons.search,
                onTap: () => _analyzeSEO(),
              ),
              _QuickActionChip(
                label: 'Suggest Layout',
                icon: Icons.view_quilt,
                onTap: () => _suggestLayout(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Generated content
          if (_generatedContent.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Generated Content',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          // Copy to clipboard
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_generatedContent),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _generatedContent = '');
                        },
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Dismiss'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Insert into editor
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Insert'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _generateContent() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedContent = '';
    });

    try {
      final content = await AIAssistant.generateContent(
        _promptController.text,
        'paragraph',
      );
      setState(() {
        _generatedContent = content;
      });
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateWithPrompt(String prompt) async {
    _promptController.text = prompt;
    await _generateContent();
  }

  Future<void> _analyzeSEO() async {
    setState(() => _isGenerating = true);
    try {
      // Simulate SEO analysis
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _generatedContent =
            'SEO Analysis:\n'
            '✓ Score: 85/100\n'
            '• Add meta descriptions\n'
            '• Optimize images\n'
            '• Improve heading structure';
      });
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _suggestLayout() async {
    setState(() => _isGenerating = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _generatedContent =
            'Suggested Layout:\n'
            '1. Hero Section with image\n'
            '2. Features Grid (3 columns)\n'
            '3. Testimonials Carousel\n'
            '4. CTA Section';
      });
    } finally {
      setState(() => _isGenerating = false);
    }
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
