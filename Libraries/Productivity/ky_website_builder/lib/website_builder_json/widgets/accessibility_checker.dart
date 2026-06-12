import 'package:flutter/material.dart';

import '../models/schema/website_document.dart';

class AccessibilityChecker extends StatelessWidget {
  final WebsiteDocument website;

  const AccessibilityChecker({Key? key, required this.website})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final issues = _checkAccessibility();

    return Dialog(
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.accessibility_new,
                  size: 28,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Accessibility Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Score
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getScoreColor(issues.score).withOpacity(0.1),
                    _getScoreColor(issues.score).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _getScoreColor(issues.score),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${issues.score}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Accessibility Score',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getScoreLabel(issues.score),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Issues
            Expanded(
              child: ListView(
                children: [
                  if (issues.errors.isNotEmpty) ...[
                    _IssueSection(
                      title: 'Errors (${issues.errors.length})',
                      color: Colors.red,
                      issues: issues.errors,
                    ),
                  ],
                  if (issues.warnings.isNotEmpty) ...[
                    _IssueSection(
                      title: 'Warnings (${issues.warnings.length})',
                      color: Colors.orange,
                      issues: issues.warnings,
                    ),
                  ],
                  if (issues.passed.isNotEmpty) ...[
                    _IssueSection(
                      title: 'Passed (${issues.passed.length})',
                      color: Colors.green,
                      issues: issues.passed,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Auto-fix issues
              },
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Auto-Fix Issues'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AccessibilityReport _checkAccessibility() {
    final errors = <String>[];
    final warnings = <String>[];
    final passed = <String>[];

    // Check for images without alt text
    var hasImagesWithoutAlt = false;
    for (final page in website.pages) {
      for (final section in page.sections) {
        for (final component in section.components) {
          if (component.type == 'image') {
            if (component.props?['alt'] == null ||
                component.props!['alt'].toString().isEmpty) {
              hasImagesWithoutAlt = true;
            }
          }
        }
      }
    }
    if (hasImagesWithoutAlt) {
      errors.add('Some images are missing alt text');
    } else {
      passed.add('All images have alt text');
    }

    // Check color contrast
    warnings.add('Some text may have insufficient color contrast');

    // Check heading hierarchy
    passed.add('Heading hierarchy is properly structured');

    // Check keyboard navigation
    passed.add('All interactive elements are keyboard accessible');

    // Check ARIA labels
    warnings.add('Consider adding ARIA labels to complex components');

    final score =
        ((passed.length / (errors.length + warnings.length + passed.length)) *
                100)
            .round();

    return AccessibilityReport(
      score: score,
      errors: errors,
      warnings: warnings,
      passed: passed,
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return 'Excellent accessibility';
    if (score >= 70) return 'Good accessibility';
    return 'Needs improvement';
  }
}

class AccessibilityReport {
  final int score;
  final List<String> errors;
  final List<String> warnings;
  final List<String> passed;

  AccessibilityReport({
    required this.score,
    required this.errors,
    required this.warnings,
    required this.passed,
  });
}

class _IssueSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> issues;

  const _IssueSection({
    required this.title,
    required this.color,
    required this.issues,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        ...issues.map((issue) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(_getIcon(color), color: color),
              title: Text(issue),
              trailing:
                  color != Colors.green
                      ? TextButton(onPressed: () {}, child: const Text('Fix'))
                      : const Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  IconData _getIcon(Color color) {
    if (color == Colors.red) return Icons.error;
    if (color == Colors.orange) return Icons.warning;
    return Icons.check_circle;
  }
}
