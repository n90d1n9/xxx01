import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// MODELS
class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImageUrl;
  final DateTime createdAt;
  final int totalOrders;
  final double totalSpent;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.createdAt,
    required this.totalOrders,
    required this.totalSpent,
  });
}

class Reservation {
  final String id;
  final String customerId;
  final DateTime dateTime;
  final int partySize;
  final String status;
  final String? notes;

  Reservation({
    required this.id,
    required this.customerId,
    required this.dateTime,
    required this.partySize,
    required this.status,
    this.notes,
  });
}

class Order {
  final String id;
  final String customerId;
  final DateTime date;
  final double amount;
  final String status;
  final List<String> items;

  Order({
    required this.id,
    required this.customerId,
    required this.date,
    required this.amount,
    required this.status,
    required this.items,
  });
}

// REPOSITORIES
class CustomerRepository {
  Future<List<Customer>> getCustomers() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return [
      Customer(
        id: "1",
        name: "John Doe",
        email: "john.doe@example.com",
        phone: "+1 (555) 123-4567",
        profileImageUrl: "https://randomuser.me/api/portraits/men/1.jpg",
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        totalOrders: 12,
        totalSpent: 1240.50,
      ),
      Customer(
        id: "2",
        name: "Jane Smith",
        email: "jane.smith@example.com",
        phone: "+1 (555) 987-6543",
        profileImageUrl: "https://randomuser.me/api/portraits/women/2.jpg",
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        totalOrders: 5,
        totalSpent: 520.75,
      ),
      Customer(
        id: "3",
        name: "Robert Johnson",
        email: "robert.j@example.com",
        phone: "+1 (555) 222-3333",
        profileImageUrl: "https://randomuser.me/api/portraits/men/3.jpg",
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        totalOrders: 18,
        totalSpent: 2350.00,
      ),
    ];
  }

  Future<Customer> getCustomerById(String id) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return Customer(
      id: id,
      name: "John Doe",
      email: "john.doe@example.com",
      phone: "+1 (555) 123-4567",
      profileImageUrl: "https://randomuser.me/api/portraits/men/1.jpg",
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      totalOrders: 12,
      totalSpent: 1240.50,
    );
  }
}

class ReservationRepository {
  Future<List<Reservation>> getReservationsByCustomerId(
    String customerId,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return [
      Reservation(
        id: "1",
        customerId: customerId,
        dateTime: DateTime.now().add(const Duration(days: 2)),
        partySize: 4,
        status: "Confirmed",
        notes: "Window seat requested",
      ),
      Reservation(
        id: "2",
        customerId: customerId,
        dateTime: DateTime.now().subtract(const Duration(days: 10)),
        partySize: 2,
        status: "Completed",
      ),
    ];
  }
}

class OrderRepository {
  Future<List<Order>> getOrdersByCustomerId(String customerId) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return [
      Order(
        id: "1",
        customerId: customerId,
        date: DateTime.now().subtract(const Duration(days: 5)),
        amount: 125.50,
        status: "Delivered",
        items: ["Pasta Carbonara", "Caesar Salad", "Tiramisu"],
      ),
      Order(
        id: "2",
        customerId: customerId,
        date: DateTime.now().subtract(const Duration(days: 20)),
        amount: 89.25,
        status: "Delivered",
        items: ["Margherita Pizza", "Bruschetta", "Espresso"],
      ),
      Order(
        id: "3",
        customerId: customerId,
        date: DateTime.now().subtract(const Duration(days: 32)),
        amount: 155.75,
        status: "Delivered",
        items: ["Risotto", "Grilled Salmon", "Cheesecake", "Wine"],
      ),
    ];
  }
}

// PROVIDERS
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepository();
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomers();
});

final selectedCustomerIdProvider = StateProvider<String?>((ref) => null);

final selectedCustomerProvider = FutureProvider<Customer?>((ref) async {
  final id = ref.watch(selectedCustomerIdProvider);
  if (id == null) return null;

  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerById(id);
});

final customerReservationsProvider =
    FutureProvider.family<List<Reservation>, String>((ref, customerId) async {
      final repository = ref.watch(reservationRepositoryProvider);
      return repository.getReservationsByCustomerId(customerId);
    });

final customerOrdersProvider = FutureProvider.family<List<Order>, String>((
  ref,
  customerId,
) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrdersByCustomerId(customerId);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredCustomersProvider = Provider<AsyncValue<List<Customer>>>((ref) {
  final customersAsync = ref.watch(customersProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return customersAsync.whenData((customers) {
    if (searchQuery.isEmpty) {
      return customers;
    }
    return customers
        .where(
          (customer) =>
              customer.name.toLowerCase().contains(searchQuery) ||
              customer.email.toLowerCase().contains(searchQuery) ||
              customer.phone.toLowerCase().contains(searchQuery),
        )
        .toList();
  });
});

// UI COMPONENTS
class CustomerManagementScreen extends ConsumerWidget {
  const CustomerManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCustomerId = ref.watch(selectedCustomerIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add customer screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add customer functionality would go here'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
              ref.refresh(customersProvider);
              if (selectedCustomerId != null) {
                ref.refresh(selectedCustomerProvider);
                ref.refresh(customerReservationsProvider(selectedCustomerId));
                ref.refresh(customerOrdersProvider(selectedCustomerId));
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Customer List Panel
          Expanded(flex: 3, child: CustomerListPanel()),
          // Vertical Divider
          const VerticalDivider(width: 1),
          // Customer Detail Panel
          Expanded(
            flex: 7,
            child: selectedCustomerId != null
                ? CustomerDetailPanel(customerId: selectedCustomerId)
                : const Center(
                    child: Text('Select a customer to view details'),
                  ),
          ),
        ],
      ),
    );
  }
}

class CustomerListPanel extends ConsumerWidget {
  const CustomerListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredCustomers = ref.watch(filteredCustomersProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search customers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade200,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
            controller: TextEditingController(text: searchQuery),
          ),
        ),

        // Customer List
        Expanded(
          child: filteredCustomers.when(
            data: (customers) {
              if (customers.isEmpty) {
                return const Center(child: Text('No customers found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return CustomerListTile(customer: customer);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) =>
                Center(child: Text('Error loading customers: $error')),
          ),
        ),
      ],
    );
  }
}

class CustomerListTile extends ConsumerWidget {
  final Customer customer;

  const CustomerListTile({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCustomerId = ref.watch(selectedCustomerIdProvider);
    final isSelected = selectedCustomerId == customer.id;

    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: isSelected
          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          ref.read(selectedCustomerIdProvider.notifier).state = customer.id;
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(customer.profileImageUrl),
              ),
              const SizedBox(width: 16),
              // Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.email,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Orders: ${customer.totalOrders}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // More Options
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Show more options
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) =>
                        CustomerOptionsSheet(customer: customer),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerOptionsSheet extends StatelessWidget {
  final Customer customer;

  const CustomerOptionsSheet({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(bottom: 20),
          ),
          // Options
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Customer'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to edit screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Add Reservation'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to add reservation screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Add Order'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to add order screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Send Email'),
            onTap: () {
              Navigator.pop(context);
              // Show email dialog
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red.shade400),
            title: Text(
              'Delete Customer',
              style: TextStyle(color: Colors.red.shade400),
            ),
            onTap: () {
              Navigator.pop(context);
              // Show delete confirmation
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Customer'),
                  content: Text(
                    'Are you sure you want to delete ${customer.name}?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Delete customer logic would go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${customer.name} deleted')),
                        );
                      },

                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomerDetailPanel extends ConsumerWidget {
  final String customerId;

  const CustomerDetailPanel({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(selectedCustomerProvider);

    return customerAsync.when(
      data: (customer) {
        if (customer == null) {
          return const Center(child: Text('Customer not found'));
        }

        return DefaultTabController(
          length: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Header
              Container(
                padding: const EdgeInsets.all(24),
                color: Theme.of(context).primaryColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Image
                    Hero(
                      tag: 'customer-${customer.id}',
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(customer.profileImageUrl),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Customer Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.email,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(customer.email),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(customer.phone),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Customer since: ${DateFormat('MMM dd, yyyy').format(customer.createdAt)}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Customer Stats
                    Container(
                      width: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildStat(
                            'Total Orders',
                            customer.totalOrders.toString(),
                          ),
                          const Divider(),
                          _buildStat(
                            'Total Spent',
                            '\$${customer.totalSpent.toStringAsFixed(2)}',
                            color: Colors.green.shade700,
                          ),
                          const Divider(),
                          _buildStat(
                            'Avg. Order Value',
                            '\$${(customer.totalSpent / customer.totalOrders).toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              const TabBar(
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Reservations'),
                  Tab(text: 'Orders'),
                ],
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.label,
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  children: [
                    CustomerOverviewTab(customer: customer),
                    CustomerReservationsTab(customerId: customer.id),
                    CustomerOrdersTab(customerId: customer.id),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Error loading customer: $error')),
    );
  }

  Widget _buildStat(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }
}

class CustomerOverviewTab extends StatelessWidget {
  final Customer customer;

  const CustomerOverviewTab({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Activity Summary
        _buildSectionCard(
          context,
          title: 'Activity Summary',
          content: Column(
            children: [
              _buildActivityItem(
                icon: Icons.shopping_bag,
                title: 'Last Order',
                subtitle: '3 days ago',
                value: '\$45.90',
              ),
              const Divider(),
              _buildActivityItem(
                icon: Icons.calendar_today,
                title: 'Next Reservation',
                subtitle: DateFormat(
                  'MMM dd, yyyy - h:mm a',
                ).format(DateTime.now().add(const Duration(days: 2))),
                value: '4 People',
              ),
              const Divider(),
              _buildActivityItem(
                icon: Icons.watch_later,
                title: 'Average Response Time',
                subtitle: 'Customer typically responds within',
                value: '2 hours',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Notes
        _buildSectionCard(
          context,
          title: 'Customer Notes',
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Add note logic
              },
              tooltip: 'Add Note',
            ),
          ],
          content: Column(
            children: [
              _buildNoteItem(
                date: DateTime.now().subtract(const Duration(days: 2)),
                author: 'Sarah Miller',
                content:
                    'Customer mentioned they prefer window seating for their reservations.',
              ),
              const Divider(),
              _buildNoteItem(
                date: DateTime.now().subtract(const Duration(days: 14)),
                author: 'John Davis',
                content:
                    'Celebrated anniversary, offered complimentary dessert.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Preferences
        _buildSectionCard(
          context,
          title: 'Preferences',
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Edit preferences logic
              },
              tooltip: 'Edit Preferences',
            ),
          ],
          content: Column(
            children: [
              _buildPreferenceItem(
                'Favorite Dishes',
                'Pasta Carbonara, Tiramisu',
              ),
              const Divider(),
              _buildPreferenceItem('Dietary Restrictions', 'None'),
              const Divider(),
              _buildPreferenceItem('Seating Preference', 'Window seat'),
              const Divider(),
              _buildPreferenceItem('Special Occasions', 'Birthday: March 15'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (actions != null) ...actions,
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Padding(padding: const EdgeInsets.all(16), child: content),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem({
    required DateTime date,
    required String author,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                author,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(date),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}

class CustomerReservationsTab extends ConsumerWidget {
  final String customerId;

  const CustomerReservationsTab({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(
      customerReservationsProvider(customerId),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Reservations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New Reservation'),
                onPressed: () {
                  // Add reservation logic
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reservations List
          Expanded(
            child: reservationsAsync.when(
              data: (reservations) {
                if (reservations.isEmpty) {
                  return const Center(child: Text('No reservations found'));
                }

                return ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat(
                                    'EEEE, MMM dd, yyyy',
                                  ).format(reservation.dateTime),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                _buildStatusBadge(reservation.status),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat(
                                    'h:mm a',
                                  ).format(reservation.dateTime),
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.people,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${reservation.partySize} people',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                            if (reservation.notes != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.notes,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        reservation.notes!,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                  onPressed: () {
                                    // Edit reservation logic
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.cancel, size: 18),
                                  label: const Text('Cancel'),
                                  onPressed: () {
                                    // Cancel reservation logic
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Error loading reservations: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class CustomerOrdersTab extends ConsumerWidget {
  final String customerId;

  const CustomerOrdersTab({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersProvider(customerId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New Order'),
                onPressed: () {
                  // Add order logic
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Orders List
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #${order.id}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(order.date),
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${order.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _buildOrderStatusBadge(order.status),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Items',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: order.items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.restaurant,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(item),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.receipt, size: 18),
                                  label: const Text('View Receipt'),
                                  onPressed: () {
                                    // View receipt logic
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.replay, size: 18),
                                  label: const Text('Reorder'),
                                  onPressed: () {
                                    // Reorder logic
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Error loading orders: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
        color = Colors.green;
        break;
      case 'in progress':
        color = Colors.blue;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// Main Application
class CustomerManagementApp extends StatelessWidget {
  const CustomerManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Customer Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey.shade50,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.grey.shade800),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          tabBarTheme: TabBarTheme(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey.shade600,
            indicator: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.blue, width: 2)),
            ),
          ),
        ),
        home: const CustomerManagementScreen(),
      ),
    );
  }
}

// Entry point
void main() {
  runApp(const CustomerManagementApp());
}

// Additional Features

// 1. Customer Analytics Widget
class CustomerAnalyticsWidget extends StatelessWidget {
  final Customer customer;

  const CustomerAnalyticsWidget({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticItem(
                    context,
                    title: 'Lifetime Value',
                    value: '\$${customer.totalSpent.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnalyticItem(
                    context,
                    title: 'Visit Frequency',
                    value:
                        '${(customer.totalOrders / 12).toStringAsFixed(1)}/month',
                    icon: Icons.repeat,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnalyticItem(
                    context,
                    title: 'Avg. Order Value',
                    value:
                        '\$${(customer.totalSpent / customer.totalOrders).toStringAsFixed(2)}',
                    icon: Icons.shopping_cart,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Purchase History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Purchase History Chart would go here',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// 2. Add Customer Form
class AddCustomerForm extends StatefulWidget {
  const AddCustomerForm({super.key});

  @override
  _AddCustomerFormState createState() => _AddCustomerFormState();
}

class _AddCustomerFormState extends State<AddCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Customer'),
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.photo_camera, size: 16),
                      label: const Text('Add Photo'),
                      onPressed: () {
                        // Add photo logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Photo upload functionality would go here',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Additional Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Birthday',
                  prefixIcon: const Icon(Icons.cake),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      // Show date picker
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Add Customer'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with saving
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer added successfully')),
      );
      Navigator.of(context).pop();
    }
  }
}

// 3. Add Reservation Form
class AddReservationForm extends ConsumerStatefulWidget {
  final String customerId;
  final String customerName;

  const AddReservationForm({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  _AddReservationFormState createState() => _AddReservationFormState();
}

class _AddReservationFormState extends ConsumerState<AddReservationForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);
  int _partySize = 2;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Reservation'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reservation for ${widget.customerName}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date & Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'EEEE, MMM dd, yyyy',
                                    ).format(_selectedDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectTime(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.blue),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Time',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _selectedTime.format(context),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Party Size',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: _partySize > 1
                                ? () => setState(() => _partySize--)
                                : null,
                            color: Colors.blue,
                            iconSize: 32,
                          ),
                          Container(
                            width: 100,
                            alignment: Alignment.center,
                            child: Text(
                              '$_partySize people',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: _partySize < 20
                                ? () => setState(() => _partySize++)
                                : null,
                            color: Colors.blue,
                            iconSize: 32,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Special Requests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          hintText:
                              'E.g., Window seat, dietary restrictions, etc.',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitReservation,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Confirm Reservation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitReservation() {
    if (_formKey.currentState!.validate()) {
      // Combine date and time
      final reservationDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Form is valid, proceed with saving
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reservation confirmed for ${DateFormat('MMM dd, yyyy - h:mm a').format(reservationDateTime)}',
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }
}

// 4. Customer Profile Settings
class CustomerProfileSettings extends ConsumerWidget {
  final Customer customer;

  const CustomerProfileSettings({super.key, required this.customer});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Profile Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Header
            Center(
              child: Column(
                children: [
                  Hero(
                    tag: 'customer-${customer.id}-settings',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(customer.profileImageUrl),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    customer.email,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        onPressed: () {
                          // Navigate to edit profile
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Change Photo'),
                        onPressed: () {
                          // Show photo options
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Communication Settings
            _buildSettingsSection(
              title: 'Communication Settings',
              children: [
                _buildSwitchTile(
                  title: 'Email Notifications',
                  subtitle: 'Receive updates about reservations and promotions',
                  value: true,
                  onChanged: (value) {},
                ),
                _buildSwitchTile(
                  title: 'SMS Notifications',
                  subtitle: 'Receive text message updates and reminders',
                  value: false,
                  onChanged: (value) {},
                ),
                _buildSwitchTile(
                  title: 'Marketing Communications',
                  subtitle: 'Receive special offers and promotions',
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Privacy Settings
            _buildSettingsSection(
              title: 'Privacy Settings',
              children: [
                _buildSwitchTile(
                  title: 'Share Order History',
                  subtitle: 'Allow staff to view your past orders',
                  value: true,
                  onChanged: (value) {},
                ),
                _buildSwitchTile(
                  title: 'Store Payment Info',
                  subtitle: 'Securely store payment methods for future orders',
                  value: false,
                  onChanged: (value) {},
                ),
                _buildTile(
                  title: 'Download Personal Data',
                  subtitle: 'Get a copy of all your personal data',
                  trailing: const Icon(Icons.download),
                  onTap: () {
                    // Download data logic
                  },
                ),
                _buildTile(
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account and all data',
                  trailing: Icon(Icons.delete, color: Colors.red.shade400),
                  onTap: () {
                    // Show delete confirmation
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Preferences
            _buildSettingsSection(
              title: 'Preferences',
              children: [
                _buildTile(
                  title: 'Dietary Restrictions',
                  subtitle: 'None specified',
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    // Edit dietary restrictions
                  },
                ),
                _buildTile(
                  title: 'Seating Preferences',
                  subtitle: 'Window seat preferred',
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    // Edit seating preferences
                  },
                ),
                _buildTile(
                  title: 'Special Occasions',
                  subtitle: 'Birthday: March 15',
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    // Edit special occasions
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

// 5. Customer Loyalty Program
class CustomerLoyaltyCard extends StatelessWidget {
  final Customer customer;
  final int points;
  final String tier;

  const CustomerLoyaltyCard({
    super.key,
    required this.customer,
    required this.points,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: tier == 'Gold'
                ? [Colors.amber.shade300, Colors.amber.shade700]
                : tier == 'Silver'
                ? [Colors.grey.shade300, Colors.grey.shade700]
                : [Colors.blueGrey.shade300, Colors.blueGrey.shade700],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LOYALTY REWARDS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$tier MEMBER',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(customer.profileImageUrl),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Member since ${DateFormat('MMMM yyyy').format(customer.createdAt)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Current Points',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  points.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Show redeem options
                  },
                  child: const Text('REDEEM'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueGrey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: points / 1000,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${1000 - points} points until next tier',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 6. Customer Import/Export
class CustomerImportExport extends StatelessWidget {
  const CustomerImportExport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import/Export'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import & Export Customer Data',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Import customer data from external sources or export your customer database.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Import Options
            _buildFeatureCard(
              context: context,
              title: 'Import Customers',
              description:
                  'Import customer data from CSV, Excel, or other CRM systems',
              icon: Icons.upload_file,
              color: Colors.green,
              onTap: () {
                // Show import options
              },
            ),

            const SizedBox(height: 16),

            // Export Options
            _buildFeatureCard(
              context: context,
              title: 'Export Customers',
              description: 'Export your customer database as CSV or Excel file',
              icon: Icons.download,
              color: Colors.blue,
              onTap: () {
                // Show export options
              },
            ),

            const SizedBox(height: 16),

            // Data Sync
            _buildFeatureCard(
              context: context,
              title: 'Connect External Services',
              description:
                  'Sync customer data with email marketing or accounting systems',
              icon: Icons.sync,
              color: Colors.purple,
              onTap: () {
                // Show sync options
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// 7. Dashboard Analytics
// 7. Dashboard Analytics (continued)
class DashboardAnalytics extends ConsumerWidget {
  const DashboardAnalytics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Analytics'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: customersAsync.when(
          data: (customers) => ListView(
            children: [
              const Text(
                'Customer Analytics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Insights from ${customers.length} customers',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Key Metrics
              _buildMetricsRow(customers),
              const SizedBox(height: 24),

              // Customer Growth
              _buildGrowthChartCard(context),
              const SizedBox(height: 24),

              // Top Spenders
              _buildTopSpendersCard(context, customers),
              const SizedBox(height: 24),

              // Activity Summary
              _buildActivitySummaryCard(context, customers),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Error loading analytics: $error')),
        ),
      ),
    );
  }

  Widget _buildMetricsRow(List<Customer> customers) {
    final totalSpent = customers.fold<double>(
      0,
      (sum, customer) => sum + customer.totalSpent,
    );
    final totalOrders = customers.fold<int>(
      0,
      (sum, customer) => sum + customer.totalOrders,
    );
    final avgOrderValue = totalOrders > 0 ? totalSpent / totalOrders : 0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Total Customers',
            value: customers.length.toString(),
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            title: 'Total Revenue',
            value: '\$${totalSpent.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            title: 'Avg. Order Value',
            value: '\$${avgOrderValue.toStringAsFixed(2)}',
            icon: Icons.shopping_cart,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthChartCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Growth',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Customer growth chart would be implemented here',
                  style: TextStyle(color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // View detailed growth report
                  },
                  child: const Text('View Full Report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSpendersCard(BuildContext context, List<Customer> customers) {
    final sortedCustomers = [...customers]
      ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
    final topSpenders = sortedCustomers.take(5).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Spenders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...topSpenders.map(
              (customer) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(customer.profileImageUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            customer.email,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${customer.totalSpent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySummaryCard(
    BuildContext context,
    List<Customer> customers,
  ) {
    final totalOrders = customers.fold<int>(
      0,
      (sum, customer) => sum + customer.totalOrders,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              icon: Icons.people,
              title: 'Active Customers',
              value: '${customers.length}',
            ),
            const Divider(),
            _buildActivityItem(
              icon: Icons.shopping_bag,
              title: 'Total Orders',
              value: '$totalOrders',
            ),
            const Divider(),
            _buildActivityItem(
              icon: Icons.calendar_today,
              title: 'Avg. Orders per Customer',
              value: '${(totalOrders / customers.length).toStringAsFixed(1)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
