import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../states/proposal_provider.dart';
import '../../widgets/proposal_template.dart';

class CreateProposalScreen extends ConsumerStatefulWidget {
  const CreateProposalScreen({super.key});

  @override
  ConsumerState<CreateProposalScreen> createState() =>
      _CreateProposalScreenState();
}

class _CreateProposalScreenState extends ConsumerState<CreateProposalScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fundingGoalController = TextEditingController();
  final _expectedReturnController = TextEditingController();
  final _timeframeController = TextEditingController();
  final _initialCostsController = TextEditingController();
  final _operationalCostsController = TextEditingController();
  final _profitSharingRatioController = TextEditingController(text: '50:50');
  final _contractTypeController = TextEditingController(text: 'Musharakah');
  final _termLengthController = TextEditingController(text: '2 years');
  final _exitTermsController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load template values
    final template = ref.read(proposalTemplateProvider);
    _categoryController.text = template['category'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _fundingGoalController.dispose();
    _expectedReturnController.dispose();
    _timeframeController.dispose();
    _initialCostsController.dispose();
    _operationalCostsController.dispose();
    _profitSharingRatioController.dispose();
    _contractTypeController.dispose();
    _termLengthController.dispose();
    _exitTermsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Proposal'),
        actions: [
          TextButton(
            onPressed: () {
              // Save as draft
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Proposal saved as draft')),
              );
            },
            child: const Text('Save Draft'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              _submitProposal();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
          steps: [
            // Step 1: Basic Information
            Step(
              title: const Text('Basic Information'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Project Title',
                      hintText: 'Enter a descriptive title',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _categoryController.text,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items:
                        [
                          'Technology',
                          'Food & Beverage',
                          'Education',
                          'Healthcare',
                          'E-commerce',
                          'Manufacturing',
                          'Other',
                        ].map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                    onChanged: (value) {
                      _categoryController.text = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Explain your project in detail',
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fundingGoalController,
                    decoration: InputDecoration(
                      labelText:
                          'Funding Goal (${_fundingGoalController.text})',
                      hintText: 'Enter amount needed',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter funding goal';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Add image functionality
                    },
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Project Images'),
                  ),
                ],
              ),
              isActive: _currentStep >= 0,
            ),

            // Step 2: Financial Details
            Step(
              title: const Text('Financial Details'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _expectedReturnController,
                    decoration: const InputDecoration(
                      labelText: 'Expected Return (%)',
                      hintText: 'e.g., 20%',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter expected return';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _timeframeController,
                    decoration: const InputDecoration(
                      labelText: 'Timeframe',
                      hintText: 'e.g., 24 months',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter timeframe';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _initialCostsController,
                    decoration: InputDecoration(
                      labelText:
                          'Initial Costs (${_initialCostsController.value})',
                      hintText: 'Startup costs',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter initial costs';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _operationalCostsController,
                    decoration: InputDecoration(
                      labelText:
                          'Monthly Operational Costs (${_operationalCostsController.value})',
                      hintText: 'Recurring costs',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter operational costs';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              isActive: _currentStep >= 1,
            ),

            // Step 3: Syirkah Terms
            Step(
              title: const Text('Syirkah Terms'),
              content: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _contractTypeController.text,
                    decoration: const InputDecoration(
                      labelText: 'Contract Type',
                    ),
                    items:
                        ['Musharakah', 'Mudarabah', 'Inan', 'Abdan'].map((
                          type,
                        ) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) {
                      _contractTypeController.text = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _profitSharingRatioController,
                    decoration: const InputDecoration(
                      labelText: 'Profit Sharing Ratio',
                      hintText: 'e.g., 60:40 (Partner:Investor)',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter profit sharing ratio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _termLengthController,
                    decoration: const InputDecoration(
                      labelText: 'Term Length',
                      hintText: 'e.g., 2 years',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter term length';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Continuing the previous code in the Syirkah Terms step
                  TextFormField(
                    controller: _exitTermsController,
                    decoration: const InputDecoration(
                      labelText: 'Exit Terms',
                      hintText: 'Explain partnership exit conditions',
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please explain exit terms';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }

  void _submitProposal() {
    if (_formKey.currentState!.validate()) {
      // Collect all proposal data
      final proposalData = {
        'title': _titleController.text,
        'category': _categoryController.text,
        'description': _descriptionController.text,
        'fundingGoal': double.parse(_fundingGoalController.text),
        'expectedReturn': _expectedReturnController.text,
        'timeframe': _timeframeController.text,
        'initialCosts': double.parse(_initialCostsController.text),
        'operationalCosts': double.parse(_operationalCostsController.text),
        'contractType': _contractTypeController.text,
        'profitSharingRatio': _profitSharingRatioController.text,
        'termLength': _termLengthController.text,
        'exitTerms': _exitTermsController.text,
        'status': 'draft', // Initial status
        'createdAt': DateTime.now(),
      };

      try {
        // Use Riverpod provider to submit the proposal
        ref.read(proposalProvider.notifier).createProposal(proposalData);

        // Show success dialog
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Proposal Submitted'),
                content: const Text(
                  'Your proposal has been saved successfully.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Return to previous screen
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } catch (e) {
        // Show error dialog
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Submission Error'),
                content: Text('An error occurred: ${e.toString()}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  // Optional: Add a method to handle draft saving
  void _saveDraft() {
    if (_formKey.currentState!.validate()) {
      final draftData = {
        'title': _titleController.text,
        'category': _categoryController.text,
        'description': _descriptionController.text,
        // Include other relevant fields
        'status': 'draft',
        'lastSaved': DateTime.now(),
      };

      try {
        ref.read(proposalProvider.notifier).saveDraftProposal(draftData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proposal draft saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save draft: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add an optional method for image picking
  Future<void> _pickProjectImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile?> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      // TODO: Implement image upload logic
      // This might involve converting XFile to File
      // and then uploading to a storage service
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${images.length} image(s) selected')),
      );
    }
  }
}
