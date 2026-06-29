import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/test_case_provider.dart';

class TestingFrameworkDialog extends StatelessWidget {
  const TestingFrameworkDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 800,
        height: 600,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              child: Row(
                children: [
                  const Icon(Icons.bug_report, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Testing Framework',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {},
                    tooltip: 'Add Test',
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    onPressed: () {},
                    tooltip: 'Run All Tests',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final testCases = ref.watch(testCasesProvider);

                  if (testCases.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.science,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text('No test cases yet'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                            label: const Text('Create Test Case'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: testCases.length,
                    itemBuilder: (context, index) {
                      final test = testCases[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            test.passed ? Icons.check_circle : Icons.cancel,
                            color: test.passed ? Colors.green : Colors.red,
                          ),
                          title: Text(test.name),
                          subtitle:
                              test.errorMessage != null
                                  ? Text(
                                    test.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  )
                                  : const Text('Test passed'),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () {},
                            tooltip: 'Run Test',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
