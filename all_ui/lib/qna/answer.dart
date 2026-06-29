import 'package:flutter/material.dart';

import 'tanya.dart';

class UstadhAnswerScreen extends StatefulWidget {
  final QAItem question;

  const UstadhAnswerScreen({super.key, required this.question});

  @override
  State<UstadhAnswerScreen> createState() => _UstadhAnswerScreenState();
}

class _UstadhAnswerScreenState extends State<UstadhAnswerScreen> {
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _referencesController = TextEditingController();
  bool _isAddingReferences = false;
  bool _isDraft = true;

  @override
  void dispose() {
    _answerController.dispose();
    _referencesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Answer Question'),
        actions: [
          TextButton(
            onPressed: () {
              _saveAsDraft();
            },
            child: Text(
              'Save Draft',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question card
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                ),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.question_mark,
                            color: Color(0xFF1E6F5C),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.question.question,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Asked by ${widget.question.askedBy} • ${widget.question.date}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Your credentials
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'You will answer as:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Text(
                          'Ustadh Ibrahim Khan',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Professor of Islamic Jurisprudence',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Your Answer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Answer TextField
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'Write your answer here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 10,
            ),

            const SizedBox(height: 16),
            // Formatting toolbar
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.format_bold),
                    onPressed: () {},
                    tooltip: 'Bold',
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_italic),
                    onPressed: () {},
                    tooltip: 'Italic',
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_list_bulleted),
                    onPressed: () {},
                    tooltip: 'Bullet List',
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_quote),
                    onPressed: () {},
                    tooltip: 'Quote',
                  ),
                  IconButton(
                    icon: const Icon(Icons.insert_link),
                    onPressed: () {},
                    tooltip: 'Insert Link',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // References section toggle
            InkWell(
              onTap: () {
                setState(() {
                  _isAddingReferences = !_isAddingReferences;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.library_books, color: Color(0xFF1E6F5C)),
                    const SizedBox(width: 12),
                    const Text(
                      'Add References',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Icon(
                      _isAddingReferences
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),

            // References input field
            if (_isAddingReferences) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _referencesController,
                decoration: InputDecoration(
                  hintText:
                      'Add Quran verses, hadiths, or scholarly references...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 4,
              ),
            ],

            const SizedBox(height: 24),

            // Publication options
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Publication Options',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Save as draft'),
                    subtitle: const Text(
                      'Answer will not be visible to the public',
                    ),
                    value: _isDraft,
                    onChanged: (value) {
                      setState(() {
                        _isDraft = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _submitAnswer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isDraft ? 'Save as Draft' : 'Publish Answer',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAsDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Answer saved as draft'),
        backgroundColor: Color(0xFF29BB89),
      ),
    );
    Navigator.pop(context);
  }

  void _submitAnswer() {
    // Validation
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide an answer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isDraft ? 'Answer saved as draft' : 'Answer published successfully',
        ),
        backgroundColor: const Color(0xFF29BB89),
      ),
    );
    Navigator.pop(context);
  }
}

// Add this method to your _QAScreenState class to launch the answer screen


// Also add this floating action button in your QAScreen build method if you want to demonstrate it
// Note: You might want to modify the QAItem class to include an ID field as shown below
// and add a conditional to only show this FAB for authenticated ustadhs

// Inside the Scaffold of QAScreen:
// Add this floating action button if user is an ustadh