import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// Providers
final customerViewProvider =
    StateNotifierProvider<CustomerViewNotifier, CustomerViewModel>((ref) {
      return CustomerViewNotifier();
    });

// ViewModel for CustomerViewScreen
class CustomerViewModel {
  final List<Queue> queues;
  final List<Ticket> waitingTickets;
  final List<Ticket> recentlyCalled;
  final Display displaySettings;
  final bool isLoading;
  final String errorMessage;

  CustomerViewModel({
    this.queues = const [],
    this.waitingTickets = const [],
    this.recentlyCalled = const [],
    this.displaySettings = const Display(),
    this.isLoading = false,
    this.errorMessage = '',
  });

  CustomerViewModel copyWith({
    List<Queue>? queues,
    List<Ticket>? waitingTickets,
    List<Ticket>? recentlyCalled,
    Display? displaySettings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CustomerViewModel(
      queues: queues ?? this.queues,
      waitingTickets: waitingTickets ?? this.waitingTickets,
      recentlyCalled: recentlyCalled ?? this.recentlyCalled,
      displaySettings: displaySettings ?? this.displaySettings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// State Notifier for CustomerView
class CustomerViewNotifier extends StateNotifier<CustomerViewModel> {
  Timer? _refreshTimer;

  CustomerViewNotifier() : super(CustomerViewModel(isLoading: true)) {
    _initializeDisplay();
  }

  Future<void> _initializeDisplay() async {
    try {
      // Fetch display settings, queues, and tickets
      final display = await _fetchDisplaySettings();
      final queues = await _fetchQueues();
      final waitingTickets = await _fetchWaitingTickets();
      final recentlyCalled = await _fetchRecentlyCalled();

      state = state.copyWith(
        displaySettings: display,
        queues: queues,
        waitingTickets: waitingTickets,
        recentlyCalled: recentlyCalled,
        isLoading: false,
      );

      // Set up refresh timer based on display settings
      _setupRefreshTimer();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load display data: ${e.toString()}',
      );
    }
  }

  void _setupRefreshTimer() {
    // Cancel existing timer if any
    _refreshTimer?.cancel();

    // Set up new timer based on display refresh interval
    _refreshTimer = Timer.periodic(
      Duration(seconds: state.displaySettings.refreshInterval),
      (_) => refreshData(),
    );
  }

  Future<void> refreshData() async {
    try {
      final waitingTickets = await _fetchWaitingTickets();
      final recentlyCalled = await _fetchRecentlyCalled();

      state = state.copyWith(
        waitingTickets: waitingTickets,
        recentlyCalled: recentlyCalled,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to refresh data: ${e.toString()}',
      );
    }
  }

  // Mock implementation of data fetching functions
  // In a real app, these would make API calls or use a repository
  Future<Display> _fetchDisplaySettings() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock display settings
    return Display(
      id: 1,
      name: 'Main Lobby Display',
      isActive: true,
      refreshInterval: 30,
      showDateTime: true,
      showQueueStatus: true,
      showWaitTimes: true,
      showLastCalled: true,
      maxTicketsDisplayed: 10,
      headerText: 'Welcome to Our Service',
      footerText: 'Thank you for your patience',
      backgroundColor: '#FFFFFF',
      textColor: '#000000',
      highlightColor: '#0066CC',
    );
  }

  Future<List<Queue>> _fetchQueues() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

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
    ];
  }

  Future<List<Ticket>> _fetchWaitingTickets() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock waiting tickets
    return [
      Ticket(
        id: 1,
        ticketNumber: 'A-101',
        customerName: 'John Doe',
        checkInTime: DateTime.now().subtract(const Duration(minutes: 20)),
        status: TicketStatus.WAITING,
        queueId: 1,
      ),
      Ticket(
        id: 2,
        ticketNumber: 'A-102',
        customerName: 'Jane Smith',
        checkInTime: DateTime.now().subtract(const Duration(minutes: 15)),
        status: TicketStatus.WAITING,
        queueId: 1,
      ),
      Ticket(
        id: 3,
        ticketNumber: 'B-40',
        customerName: 'Bob Johnson',
        checkInTime: DateTime.now().subtract(const Duration(minutes: 10)),
        status: TicketStatus.WAITING,
        queueId: 2,
      ),
    ];
  }

  Future<List<Ticket>> _fetchRecentlyCalled() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock recently called tickets
    return [
      Ticket(
        id: 4,
        ticketNumber: 'A-100',
        customerName: 'Alice Williams',
        checkInTime: DateTime.now().subtract(const Duration(minutes: 25)),
        startServiceTime: DateTime.now().subtract(const Duration(minutes: 5)),
        status: TicketStatus.SERVING,
        queueId: 1,
      ),
      Ticket(
        id: 5,
        ticketNumber: 'B-39',
        customerName: 'Charlie Brown',
        checkInTime: DateTime.now().subtract(const Duration(minutes: 30)),
        startServiceTime: DateTime.now().subtract(const Duration(minutes: 8)),
        status: TicketStatus.SERVING,
        queueId: 2,
      ),
    ];
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

// CustomerViewScreen implementation
class CustomerViewScreen extends ConsumerWidget {
  const CustomerViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerViewProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(state.errorMessage, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    () => ref.read(customerViewProvider.notifier).refreshData(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final display = state.displaySettings;

    return Scaffold(
      body: Container(
        color: HexColor(display.backgroundColor),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: HexColor(display.highlightColor),
              child: Column(
                children: [
                  Text(
                    display.headerText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (display.showDateTime)
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, _) {
                        final now = DateTime.now();
                        return Text(
                          '${_formatDate(now)} ${_formatTime(now)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Row(
                children: [
                  // Left panel - Queue Status
                  if (display.showQueueStatus)
                    Expanded(
                      flex: 2,
                      child: QueueStatusPanel(
                        queues: state.queues,
                        display: display,
                      ),
                    ),

                  // Right panel - Recently Called & Waiting List
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        // Recently Called
                        if (display.showLastCalled)
                          Expanded(
                            flex: 1,
                            child: RecentlyCalledPanel(
                              tickets: state.recentlyCalled,
                              display: display,
                            ),
                          ),

                        // Waiting List
                        Expanded(
                          flex: 2,
                          child: WaitingListPanel(
                            tickets: state.waitingTickets,
                            display: display,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(12),
              color: HexColor(display.highlightColor).withValues(alpha: 0.8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    display.footerText,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  // QR code or additional info could go here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Panel Components
class QueueStatusPanel extends StatelessWidget {
  final List<Queue> queues;
  final Display display;

  const QueueStatusPanel({
    Key? key,
    required this.queues,
    required this.display,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HexColor(display.highlightColor),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.queue, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Queue Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: queues.length,
              itemBuilder: (context, index) {
                final queue = queues[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        queue.name,
                        style: TextStyle(
                          color: HexColor(display.textColor),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        queue.description,
                        style: TextStyle(
                          color: HexColor(
                            display.textColor,
                          ).withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildInfoItem(
                            icon: Icons.confirmation_number,
                            label: 'Current #',
                            value: queue.currentTicketNumber.toString(),
                            color: display.textColor,
                          ),
                          const SizedBox(width: 24),
                          if (display.showWaitTimes)
                            _buildInfoItem(
                              icon: Icons.timer,
                              label: 'Wait Time',
                              value: '~${queue.currentWaitTime} min',
                              color: display.textColor,
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required String color,
  }) {
    return Row(
      children: [
        Icon(icon, color: HexColor(color).withValues(alpha: 0.7), size: 18),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: HexColor(color).withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: HexColor(color),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RecentlyCalledPanel extends StatelessWidget {
  final List<Ticket> tickets;
  final Display display;

  const RecentlyCalledPanel({
    Key? key,
    required this.tickets,
    required this.display,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HexColor(display.highlightColor),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.announcement, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Now Serving',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                tickets.isEmpty
                    ? Center(
                      child: Text(
                        'No tickets currently being served',
                        style: TextStyle(
                          color: HexColor(
                            display.textColor,
                          ).withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: HexColor(display.highlightColor),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ticket.ticketNumber,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getCustomerDisplayName(ticket),
                                      style: TextStyle(
                                        color: HexColor(display.textColor),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Counter: ${_getCounterForTicket(ticket)}',
                                      style: TextStyle(
                                        color: HexColor(
                                          display.textColor,
                                        ).withValues(alpha: 0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'NOW SERVING',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  String _getCustomerDisplayName(Ticket ticket) {
    // In a real app, there might be privacy settings
    // to determine how much customer info to show
    if (ticket.customerName.isNotEmpty) {
      return ticket.customerName;
    }
    return 'Customer';
  }

  String _getCounterForTicket(Ticket ticket) {
    // In a real app, this would come from the ticket data
    // or be determined by the associated servicePoint
    return 'Counter ${ticket.id % 5 + 1}';
  }
}

class WaitingListPanel extends StatelessWidget {
  final List<Ticket> tickets;
  final Display display;

  const WaitingListPanel({
    Key? key,
    required this.tickets,
    required this.display,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HexColor(display.highlightColor),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.people, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Waiting List',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.withValues(alpha: 0.1),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Ticket #',
                    style: TextStyle(
                      color: HexColor(display.textColor).withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Service',
                    style: TextStyle(
                      color: HexColor(display.textColor).withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Check-in Time',
                    style: TextStyle(
                      color: HexColor(display.textColor).withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (display.showWaitTimes)
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Est. Wait',
                      style: TextStyle(
                        color: HexColor(
                          display.textColor,
                        ).withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child:
                tickets.isEmpty
                    ? Center(
                      child: Text(
                        'No customers waiting',
                        style: TextStyle(
                          color: HexColor(
                            display.textColor,
                          ).withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: min(
                        tickets.length,
                        display.maxTicketsDisplayed,
                      ),
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        final isEven = index % 2 == 0;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          color:
                              isEven
                                  ? Colors.grey.withValues(alpha: 0.05)
                                  : Colors.white,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  ticket.ticketNumber,
                                  style: TextStyle(
                                    color: HexColor(display.textColor),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  _getQueueNameForTicket(ticket),
                                  style: TextStyle(
                                    color: HexColor(display.textColor),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formatTime(ticket.checkInTime),
                                  style: TextStyle(
                                    color: HexColor(display.textColor),
                                  ),
                                ),
                              ),
                              if (display.showWaitTimes)
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _getEstimatedWaitTime(ticket),
                                    style: TextStyle(
                                      color: HexColor(display.textColor),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  String _getQueueNameForTicket(Ticket ticket) {
    // In a real app, this would lookup the queue by ID
    // Here we're just using a simple mapping for demo
    switch (ticket.queueId) {
      case 1:
        return 'Customer Service';
      case 2:
        return 'Technical Support';
      default:
        return 'General Queue';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getEstimatedWaitTime(Ticket ticket) {
    // In a real app, this would be calculated based on
    // position in queue, average service time, etc.
    final waitingMinutes =
        DateTime.now().difference(ticket.checkInTime).inMinutes;
    final estimatedTotal = 15; // Mock value, should be from queue data

    if (waitingMinutes >= estimatedTotal) {
      return 'Soon';
    }

    return '~${estimatedTotal - waitingMinutes} min';
  }
}

// Utility class for hex color conversion
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

// Helper function
int min(int a, int b) => a < b ? a : b;

// Assume these enums and models are defined elsewhere
// Adding minimal implementations here for completeness

enum TicketStatus { WAITING, SERVING, COMPLETED, CANCELLED, NO_SHOW }

enum QueueStatus { OPEN, CLOSED, BUSY, MAINTENANCE }

class Display {
  final int id;
  final String name;
  final String description;
  final bool isActive;
  final int refreshInterval;
  final String headerText;
  final String footerText;
  final String backgroundColor;
  final String textColor;
  final String highlightColor;
  final bool showDateTime;
  final bool showQueueStatus;
  final bool showWaitTimes;
  final bool showLastCalled;
  final int maxTicketsDisplayed;

  const Display({
    this.id = 0,
    this.name = '',
    this.description = '',
    this.isActive = true,
    this.refreshInterval = 30,
    this.headerText = '',
    this.footerText = '',
    this.backgroundColor = '#FFFFFF',
    this.textColor = '#000000',
    this.highlightColor = '#0066CC',
    this.showDateTime = true,
    this.showQueueStatus = true,
    this.showWaitTimes = true,
    this.showLastCalled = true,
    this.maxTicketsDisplayed = 10,
  });
}

class Queue {
  final int id;
  final String name;
  final String description;
  final int maxCapacity;
  final bool isActive;
  final int estimatedWaitTimePerCustomer;
  final int currentWaitTime;
  final int currentTicketNumber;
  final QueueStatus status;

  Queue({
    required this.id,
    required this.name,
    this.description = '',
    this.maxCapacity = 50,
    this.isActive = true,
    this.estimatedWaitTimePerCustomer = 5,
    this.currentWaitTime = 0,
    this.currentTicketNumber = 0,
    this.status = QueueStatus.OPEN,
  });
}

class Ticket {
  final int id;
  final String ticketNumber;
  final String customerName;
  final DateTime checkInTime;
  final DateTime? startServiceTime;
  final DateTime? endServiceTime;
  final TicketStatus status;
  final int queueId;

  Ticket({
    required this.id,
    required this.ticketNumber,
    this.customerName = '',
    required this.checkInTime,
    this.startServiceTime,
    this.endServiceTime,
    this.status = TicketStatus.WAITING,
    required this.queueId,
  });
}

void main(List<String> args) {
  runApp(const ProviderScope(child: MaterialApp(home: CustomerViewScreen())));
}
