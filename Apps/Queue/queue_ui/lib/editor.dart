import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'queue.dart';

void main() {
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: QueueEditorScreen());
  }
}

// Providers
final queueEditorProvider =
    StateNotifierProvider<QueueEditorNotifier, QueueEditorState>((ref) {
      return QueueEditorNotifier();
    });

// State class for QueueEditorScreen
class QueueEditorState {
  final Queue? selectedQueue;
  final List<Queue> allQueues;
  final List<DisplayPreview> displayPreviews;
  final bool isLoading;
  final bool isSaving;
  final String errorMessage;
  final String successMessage;

  QueueEditorState({
    this.selectedQueue,
    this.allQueues = const [],
    this.displayPreviews = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage = '',
    this.successMessage = '',
  });

  QueueEditorState copyWith({
    Queue? selectedQueue,
    List<Queue>? allQueues,
    List<DisplayPreview>? displayPreviews,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
  }) {
    return QueueEditorState(
      selectedQueue: selectedQueue ?? this.selectedQueue,
      allQueues: allQueues ?? this.allQueues,
      displayPreviews: displayPreviews ?? this.displayPreviews,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  // Helper to create a clean state with just updated messages
  QueueEditorState withMessage({String? error, String? success}) {
    return QueueEditorState(
      selectedQueue: selectedQueue,
      allQueues: allQueues,
      displayPreviews: displayPreviews,
      isLoading: isLoading,
      isSaving: isSaving,
      errorMessage: error ?? '',
      successMessage: success ?? '',
    );
  }
}

// Preview model for display configuration
class DisplayPreview {
  final int id;
  final String name;
  final String location;
  final bool isActive;
  final List<int> queueIds;
  final DateTime lastHeartbeat;

  DisplayPreview({
    required this.id,
    required this.name,
    required this.location,
    required this.isActive,
    required this.queueIds,
    required this.lastHeartbeat,
  });
}

// State Notifier for QueueEditor
class QueueEditorNotifier extends StateNotifier<QueueEditorState> {
  QueueEditorNotifier() : super(QueueEditorState(isLoading: true)) {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load queues and displays
      final queues = await _fetchQueues();
      final displays = await _fetchDisplayPreviews();

      state = state.copyWith(
        allQueues: queues,
        displayPreviews: displays,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load data: ${e.toString()}',
      );
    }
  }

  void selectQueue(Queue queue) {
    state = state.copyWith(selectedQueue: queue);
  }

  Future<void> createNewQueue() async {
    // Create a new queue with default values
    final newQueue = Queue(
      id: -1, // Temporary ID until saved
      name: 'New Queue',
      description: 'Description',
      maxCapacity: 50,
      isActive: true,
      estimatedWaitTimePerCustomer: 5,
      currentWaitTime: 0,
      currentTicketNumber: 0,
      status: QueueStatus.OPEN,
    );

    state = state.copyWith(selectedQueue: newQueue);
  }

  Future<void> saveQueue(Queue updatedQueue) async {
    try {
      state = state.copyWith(isSaving: true);

      // Check if we're updating or creating
      final isNew = updatedQueue.id < 0;

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Create a saved version with a real ID if it's new
      final savedQueue =
          isNew
              ? Queue(
                id:
                    DateTime.now().millisecondsSinceEpoch %
                    10000, // Generate a fake ID
                name: updatedQueue.name,
                description: updatedQueue.description,
                maxCapacity: updatedQueue.maxCapacity,
                isActive: updatedQueue.isActive,
                estimatedWaitTimePerCustomer:
                    updatedQueue.estimatedWaitTimePerCustomer,
                currentWaitTime: updatedQueue.currentWaitTime,
                currentTicketNumber: updatedQueue.currentTicketNumber,
                status: updatedQueue.status,
              )
              : updatedQueue;

      // Update the list of queues
      List<Queue> updatedQueues;
      if (isNew) {
        updatedQueues = [...state.allQueues, savedQueue];
      } else {
        updatedQueues =
            state.allQueues
                .map((q) => q.id == savedQueue.id ? savedQueue : q)
                .toList();
      }

      state = state.copyWith(
        isSaving: false,
        allQueues: updatedQueues,
        selectedQueue: savedQueue,
        successMessage:
            isNew
                ? 'Queue created successfully!'
                : 'Queue updated successfully!',
      );

      // Clear success message after 3 seconds
      _clearSuccessMessageAfterDelay();
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save queue: ${e.toString()}',
      );

      // Clear error message after 3 seconds
      _clearErrorMessageAfterDelay();
    }
  }

  Future<void> deleteQueue(int queueId) async {
    try {
      state = state.copyWith(isSaving: true);

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Filter out the deleted queue
      final updatedQueues =
          state.allQueues.where((q) => q.id != queueId).toList();

      state = state.copyWith(
        isSaving: false,
        allQueues: updatedQueues,
        selectedQueue: null,
        successMessage: 'Queue deleted successfully!',
      );

      // Clear success message after 3 seconds
      _clearSuccessMessageAfterDelay();
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete queue: ${e.toString()}',
      );

      // Clear error message after 3 seconds
      _clearErrorMessageAfterDelay();
    }
  }

  Future<void> toggleQueueStatus(int queueId, bool isActive) async {
    try {
      // Find the queue to update
      final queueToUpdate = state.allQueues.firstWhere((q) => q.id == queueId);

      // Create updated version
      final updatedQueue = Queue(
        id: queueToUpdate.id,
        name: queueToUpdate.name,
        description: queueToUpdate.description,
        maxCapacity: queueToUpdate.maxCapacity,
        isActive: isActive,
        estimatedWaitTimePerCustomer:
            queueToUpdate.estimatedWaitTimePerCustomer,
        currentWaitTime: queueToUpdate.currentWaitTime,
        currentTicketNumber: queueToUpdate.currentTicketNumber,
        status: isActive ? QueueStatus.OPEN : QueueStatus.CLOSED,
      );

      // Update the list of queues
      final updatedQueues =
          state.allQueues
              .map((q) => q.id == queueId ? updatedQueue : q)
              .toList();

      // Update the state
      state = state.copyWith(
        allQueues: updatedQueues,
        // If the updated queue is the selected one, update it too
        selectedQueue:
            state.selectedQueue?.id == queueId
                ? updatedQueue
                : state.selectedQueue,
      );
    } catch (e) {
      state = state.withMessage(
        error: 'Failed to update queue status: ${e.toString()}',
      );

      // Clear error message after 3 seconds
      _clearErrorMessageAfterDelay();
    }
  }

  void _clearSuccessMessageAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        state = state.withMessage(success: '');
      }
    });
  }

  void _clearErrorMessageAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        state = state.withMessage(error: '');
      }
    });
  }

  // Mock implementations of data fetching functions
  Future<List<Queue>> _fetchQueues() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return mock queues
    return [
      Queue(
        id: 1,
        name: 'Customer Service',
        description: 'General inquiries and support',
        currentWaitTime: 15,
        estimatedWaitTimePerCustomer: 5,
        currentTicketNumber: 105,
      ),
      Queue(
        id: 2,
        name: 'Technical Support',
        description: 'Technical issues and troubleshooting',
        currentWaitTime: 25,
        estimatedWaitTimePerCustomer: 8,
        currentTicketNumber: 42,
      ),
      Queue(
        id: 3,
        name: 'Returns & Exchanges',
        description: 'Process returns and exchanges',
        currentWaitTime: 10,
        estimatedWaitTimePerCustomer: 4,
        currentTicketNumber: 78,
        isActive: false,
        status: QueueStatus.CLOSED,
      ),
    ];
  }

  Future<List<DisplayPreview>> _fetchDisplayPreviews() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Return mock display previews
    return [
      DisplayPreview(
        id: 1,
        name: 'Main Lobby Display',
        location: 'Front Entrance',
        isActive: true,
        queueIds: [1, 2, 3],
        lastHeartbeat: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      DisplayPreview(
        id: 2,
        name: 'Waiting Area Display',
        location: 'Customer Waiting Area',
        isActive: true,
        queueIds: [1, 2],
        lastHeartbeat: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      DisplayPreview(
        id: 3,
        name: 'Service Desk Display',
        location: 'Service Desk Area',
        isActive: false,
        queueIds: [3],
        lastHeartbeat: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}

class QueueEditorScreen extends ConsumerStatefulWidget {
  const QueueEditorScreen({Key? key}) : super(key: key);

  @override
  _QueueEditorScreenState createState() => _QueueEditorScreenState();
}

class _QueueEditorScreenState extends ConsumerState<QueueEditorScreen> {
  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _waitTimeController = TextEditingController();
  final _maxCapacityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _waitTimeController.dispose();
    _maxCapacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(queueEditorProvider);

    // Show loading indicator if loading
    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Management'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create New Queue',
            onPressed: () {
              ref.read(queueEditorProvider.notifier).createNewQueue();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              ref.refresh(queueEditorProvider);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left panel - Queue list
          Container(
            width: 280,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Queues',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.allQueues.length,
                    itemBuilder: (context, index) {
                      final queue = state.allQueues[index];
                      final isSelected = state.selectedQueue?.id == queue.id;

                      return ListTile(
                        leading: Icon(
                          Icons.queue,
                          color: queue.isActive ? Colors.green : Colors.grey,
                        ),
                        title: Text(
                          queue.name,
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          queue.isActive
                              ? 'Active - ${queue.currentTicketNumber} tickets'
                              : 'Inactive',
                          style: TextStyle(
                            color:
                                queue.isActive
                                    ? Colors.green[700]
                                    : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: Colors.blue.withOpacity(0.1),
                        onTap: () {
                          ref
                              .read(queueEditorProvider.notifier)
                              .selectQueue(queue);

                          // Update form controllers with selected queue data
                          _updateFormControllers(queue);
                        },
                        trailing: Switch(
                          value: queue.isActive,
                          onChanged: (value) {
                            ref
                                .read(queueEditorProvider.notifier)
                                .toggleQueueStatus(queue.id, value);
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Display monitor section
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Display Monitors',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.displayPreviews.length,
                    itemBuilder: (context, index) {
                      final display = state.displayPreviews[index];

                      return ListTile(
                        leading: Icon(
                          Icons.monitor,
                          color: display.isActive ? Colors.blue : Colors.grey,
                        ),
                        title: Text(display.name),
                        subtitle: Text(
                          display.location,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getConnectionStatusColor(
                              display.lastHeartbeat,
                            ),
                          ),
                        ),
                        onTap: () {
                          // Navigate to display editor (not implemented in this example)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Display editor for "${display.name}" not implemented',
                              ),
                              duration: const Duration(seconds: 2),
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

          // Right panel - Queue editor form
          Expanded(
            child:
                state.selectedQueue == null
                    ? const Center(
                      child: Text(
                        'Select a queue to edit or create a new one',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                    : _buildQueueEditorForm(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueEditorForm(BuildContext context, QueueEditorState state) {
    final queue = state.selectedQueue!;
    final isNewQueue = queue.id < 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isNewQueue ? 'Create New Queue' : 'Edit Queue',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isNewQueue)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed:
                        state.isSaving
                            ? null
                            : () => _confirmDelete(context, queue.id),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Status and messages
            if (state.errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            if (state.successMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.successMessage,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),

            // Basic Info
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Queue Name',
                hintText: 'Enter a name for this queue',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Queue name is required';
                }
                if (value.length < 3) {
                  return 'Queue name must be at least 3 characters';
                }
                if (value.length > 50) {
                  return 'Queue name must be less than 50 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the purpose of this queue',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value != null && value.length > 200) {
                  return 'Description must be less than 200 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Queue Settings
            const Text(
              'Queue Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxCapacityController,
                    decoration: const InputDecoration(
                      labelText: 'Maximum Capacity',
                      hintText: 'Maximum number of customers',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Capacity is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Must be a valid number';
                      }
                      if (int.parse(value) <= 0) {
                        return 'Must be greater than 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _waitTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Wait Time (mins)',
                      hintText: 'Average time per customer',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wait time is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Must be a valid number';
                      }
                      if (int.parse(value) <= 0) {
                        return 'Must be greater than 0';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<QueueStatus>(
                    decoration: const InputDecoration(
                      labelText: 'Queue Status',
                      border: OutlineInputBorder(),
                    ),
                    value: queue.status,
                    items:
                        QueueStatus.values.map((status) {
                          return DropdownMenuItem<QueueStatus>(
                            value: status,
                            child: Text(_getQueueStatusText(status)),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      // Handle status change
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Active'),
                    subtitle: const Text('Queue is operational'),
                    value: queue.isActive,
                    onChanged: (value) {
                      ref
                          .read(queueEditorProvider.notifier)
                          .toggleQueueStatus(queue.id, value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Current status
            if (!isNewQueue) ...[
              const Text(
                'Current Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 0,
                color: Colors.grey.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildInfoCard(
                        title: 'Current Ticket',
                        value: queue.currentTicketNumber.toString(),
                        icon: Icons.confirmation_number,
                      ),
                      _buildInfoCard(
                        title: 'Current Wait',
                        value: '${queue.currentWaitTime} mins',
                        icon: Icons.timer,
                      ),
                      _buildInfoCard(
                        title: 'Status',
                        value: _getQueueStatusText(queue.status),
                        icon: Icons.info_outline,
                        valueColor: _getStatusColor(queue.status),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],

            // Actions
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      state.isSaving
                          ? null
                          : () {
                            // Reset form or go back
                            if (isNewQueue) {
                              ref
                                  .read(queueEditorProvider.notifier)
                                  .selectQueue(state.allQueues.first);
                            } else {
                              // Reset form to original values
                              _updateFormControllers(queue);
                            }
                          },
                  child: Text(isNewQueue ? 'Cancel' : 'Reset'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed:
                      state.isSaving ? null : () => _saveQueue(context, queue),
                  child:
                      state.isSaving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(isNewQueue ? 'Create Queue' : 'Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateFormControllers(Queue queue) {
    _nameController.text = queue.name;
    _descriptionController.text = queue.description;
    _waitTimeController.text = queue.estimatedWaitTimePerCustomer.toString();
    _maxCapacityController.text = queue.maxCapacity.toString();
  }

  void _saveQueue(BuildContext context, Queue currentQueue) {
    if (_formKey.currentState?.validate() ?? false) {
      // Create updated queue with form values
      final updatedQueue = Queue(
        id: currentQueue.id,
        name: _nameController.text,
        description: _descriptionController.text,
        maxCapacity: int.parse(_maxCapacityController.text),
        isActive: currentQueue.isActive,
        estimatedWaitTimePerCustomer: int.parse(_waitTimeController.text),
        currentWaitTime: currentQueue.currentWaitTime,
        currentTicketNumber: currentQueue.currentTicketNumber,
        status: currentQueue.status,
      );

      // Save the queue
      ref.read(queueEditorProvider.notifier).saveQueue(updatedQueue);
    }
  }

  void _confirmDelete(BuildContext context, int queueId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Queue'),
            content: const Text(
              'Are you sure you want to delete this queue? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(queueEditorProvider.notifier).deleteQueue(queueId);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  String _getQueueStatusText(QueueStatus status) {
    switch (status) {
      case QueueStatus.OPEN:
        return 'Open';
      case QueueStatus.CLOSED:
        return 'Closed';
      case QueueStatus.BUSY:
        return 'Busy';
      case QueueStatus.MAINTENANCE:
        return 'Maintenance';
      default:
        return 'Unknown';
    }
  }

  /*   Color? _getStatusColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.OPEN:
        return Colors.green;
      case QueueStatus.CLOSED:
        return Colors.red;
      case QueueStatus.BUSY:
        return Colors.orange;
      case QueueStatus.MAINTENANCE:
        return Colors.blue; */

  Color _getConnectionStatusColor(DateTime lastHeartbeat) {
    final difference = DateTime.now().difference(lastHeartbeat);

    if (difference.inMinutes < 5) {
      return Colors.green; // Online - recent heartbeat
    } else if (difference.inMinutes < 30) {
      return Colors.orange; // Warning - heartbeat getting old
    } else {
      return Colors.red; // Offline - no recent heartbeat
    }
  }

  /* String _getQueueStatusText(QueueStatus status) {
    switch (status) {
      case QueueStatus.OPEN:
        return 'Open';
      case QueueStatus.CLOSED:
        return 'Closed';
      case QueueStatus.BUSY:
        return 'Busy';
      case QueueStatus.MAINTENANCE:
        return 'Maintenance';
      default:
        return 'Unknown';
    }
  } */

  Color _getStatusColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.OPEN:
        return Colors.green;
      case QueueStatus.CLOSED:
        return Colors.red;
      case QueueStatus.BUSY:
        return Colors.orange;
      case QueueStatus.MAINTENANCE:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// Add a new screen for Display Monitor configuration
class DisplayConfigScreen extends ConsumerStatefulWidget {
  final DisplayPreview display;

  const DisplayConfigScreen({super.key, required this.display});

  @override
  _DisplayConfigScreenState createState() => _DisplayConfigScreenState();
}

class _DisplayConfigScreenState extends ConsumerState<DisplayConfigScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<int> _selectedQueueIds = [];

  Color _getConnectionStatusColor(DateTime lastHeartbeat) {
    final difference = DateTime.now().difference(lastHeartbeat);

    if (difference.inMinutes < 5) {
      return Colors.green; // Online - recent heartbeat
    } else if (difference.inMinutes < 30) {
      return Colors.orange; // Warning - heartbeat getting old
    } else {
      return Colors.red; // Offline - no recent heartbeat
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.display.name;
    _locationController.text = widget.display.location;
    _selectedQueueIds = List.from(widget.display.queueIds);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(queueEditorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Configure Display: ${widget.display.name}'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Display Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Enter a name for this display',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Display name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Where is this display located?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Display Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Display is operational'),
                value: widget.display.isActive,
                onChanged: (value) {
                  // Would update display status here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Status update functionality not implemented in this example',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Queues to Display',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // List of checkboxes for all available queues
              Expanded(
                child: ListView.builder(
                  itemCount: state.allQueues.length,
                  itemBuilder: (context, index) {
                    final queue = state.allQueues[index];
                    final isSelected = _selectedQueueIds.contains(queue.id);

                    return CheckboxListTile(
                      title: Text(queue.name),
                      subtitle: Text(queue.description),
                      value: isSelected,
                      secondary: Icon(
                        Icons.queue,
                        color: queue.isActive ? Colors.green : Colors.grey,
                      ),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedQueueIds.add(queue.id);
                          } else {
                            _selectedQueueIds.remove(queue.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Connection status
              Card(
                elevation: 0,
                color: Colors.grey.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Connection Status',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getConnectionStatusColor(
                                      widget.display.lastHeartbeat,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getConnectionStatusText(
                                    widget.display.lastHeartbeat,
                                  ),
                                  style: TextStyle(
                                    color: _getConnectionStatusColor(
                                      widget.display.lastHeartbeat,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Last seen: ${_formatHeartbeatTime(widget.display.lastHeartbeat)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Would trigger a ping to the display
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Ping functionality not implemented in this example',
                              ),
                            ),
                          );
                        },
                        child: const Text('Ping Device'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Would save display configuration here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Save functionality not implemented in this example',
                            ),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save Configuration'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getConnectionStatusText(DateTime lastHeartbeat) {
    final difference = DateTime.now().difference(lastHeartbeat);

    if (difference.inMinutes < 5) {
      return 'Online';
    } else if (difference.inMinutes < 30) {
      return 'Intermittent';
    } else {
      return 'Offline';
    }
  }

  String _formatHeartbeatTime(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

// Add Preview Dialog to show how the queue display looks to customers
class QueuePreviewDialog extends StatelessWidget {
  final Queue queue;

  const QueuePreviewDialog({Key? key, required this.queue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Display Preview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      queue.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      queue.description,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDisplayStat(
                          'Current Ticket',
                          queue.currentTicketNumber.toString(),
                          Colors.blue,
                        ),
                        _buildDisplayStat(
                          'Estimated Wait',
                          '${queue.currentWaitTime} mins',
                          Colors.orange,
                        ),
                        _buildDisplayStat(
                          'Status',
                          _getQueueStatusText(queue.status),
                          _getStatusColor(queue.status),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'This is how your queue will appear on customer-facing displays',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getQueueStatusText(QueueStatus status) {
    switch (status) {
      case QueueStatus.OPEN:
        return 'OPEN';
      case QueueStatus.CLOSED:
        return 'CLOSED';
      case QueueStatus.BUSY:
        return 'BUSY';
      case QueueStatus.MAINTENANCE:
        return 'MAINTENANCE';
      default:
        return 'UNKNOWN';
    }
  }

  Color _getStatusColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.OPEN:
        return Colors.green;
      case QueueStatus.CLOSED:
        return Colors.red;
      case QueueStatus.BUSY:
        return Colors.orange;
      case QueueStatus.MAINTENANCE:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// Add navigation method to the main screen
extension QueueEditorScreenNavigation on _QueueEditorScreenState {
  void _navigateToDisplayConfig(DisplayPreview display) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DisplayConfigScreen(display: display),
      ),
    );
  }

  void _showQueuePreview(Queue queue) {
    showDialog(
      context: context,
      builder: (context) => QueuePreviewDialog(queue: queue),
    );
  }

  // Update the onTap handler in the display list items
  // Replace the existing onTap with this in the display ListView.builder:
  // onTap: () => _navigateToDisplayConfig(display),

  // Add a preview button to the queue editor form
  Widget _buildPreviewButton(Queue queue) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.visibility),
      label: const Text('Preview Display'),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: () => _showQueuePreview(queue),
    );
  }

  // Add this button to the queue editor form actions row
}

// New analytics data class for reporting
class QueueAnalytics {
  final int totalServed;
  final double averageWaitTime;
  final int peakHour;
  final double satisfactionRating;
  final Map<String, int> customersByHour;

  QueueAnalytics({
    required this.totalServed,
    required this.averageWaitTime,
    required this.peakHour,
    required this.satisfactionRating,
    required this.customersByHour,
  });

  factory QueueAnalytics.mock() {
    return QueueAnalytics(
      totalServed: 187,
      averageWaitTime: 12.3,
      peakHour: 14, // 2 PM
      satisfactionRating: 4.2,
      customersByHour: {
        '9': 12,
        '10': 18,
        '11': 24,
        '12': 32,
        '13': 27,
        '14': 38,
        '15': 22,
        '16': 14,
      },
    );
  }
}

// Analytics Tab for the Queue Editor
class QueueAnalyticsTab extends StatelessWidget {
  final Queue queue;

  const QueueAnalyticsTab({Key? key, required this.queue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock analytics data
    final analytics = QueueAnalytics.mock();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${queue.name} Analytics',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              _buildAnalyticCard(
                title: 'Customers Served',
                value: analytics.totalServed.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
              _buildAnalyticCard(
                title: 'Avg. Wait Time',
                value: '${analytics.averageWaitTime.toStringAsFixed(1)} mins',
                icon: Icons.timer,
                color: Colors.orange,
              ),
              _buildAnalyticCard(
                title: 'Peak Hour',
                value: '${analytics.peakHour}:00',
                icon: Icons.trending_up,
                color: Colors.purple,
              ),
              _buildAnalyticCard(
                title: 'Satisfaction',
                value: analytics.satisfactionRating.toStringAsFixed(1),
                icon: Icons.star,
                color: Colors.amber,
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Hourly Customer Flow',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              // This would be a chart in a real implementation
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Volume by Hour',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:
                          analytics.customersByHour.entries.map((entry) {
                            final hour = int.parse(entry.key);
                            final count = entry.value;
                            final maxCount = analytics.customersByHour.values
                                .reduce((a, b) => a > b ? a : b);
                            final percentage = count / maxCount;

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      count.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 150 * percentage,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$hour:00',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Export Report'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Export functionality not implemented in this example',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
