import 'package:flutter/material.dart';

class ExpressionBuilderDialog extends StatelessWidget {
  const ExpressionBuilderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              child: const Row(
                children: [
                  Icon(Icons.functions, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Expression Builder',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Build expressions visually',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    // Variables
                    const Text(
                      'Variables:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('\${body}'),
                          onPressed: () {},
                        ),
                        ActionChip(
                          label: const Text('\${header.id}'),
                          onPressed: () {},
                        ),
                        ActionChip(
                          label: const Text('\${property.name}'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Functions
                    const Text(
                      'Functions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('toUpperCase()'),
                          onPressed: () {},
                        ),
                        ActionChip(
                          label: const Text('toLowerCase()'),
                          onPressed: () {},
                        ),
                        ActionChip(
                          label: const Text('trim()'),
                          onPressed: () {},
                        ),
                        ActionChip(
                          label: const Text('contains()'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Operators
                    const Text(
                      'Operators:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(label: const Text('=='), onPressed: () {}),
                        ActionChip(label: const Text('!='), onPressed: () {}),
                        ActionChip(label: const Text('>'), onPressed: () {}),
                        ActionChip(label: const Text('<'), onPressed: () {}),
                        ActionChip(label: const Text('&&'), onPressed: () {}),
                        ActionChip(label: const Text('||'), onPressed: () {}),
                      ],
                    ),
                    const Spacer(),
                    // Result
                    const Text(
                      'Expression:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '\${body.toUpperCase()} == "HELLO"',
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
