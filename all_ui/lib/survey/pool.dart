import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/legacy.dart';

// Enums and Constants
enum UserRole { admin, guest }

enum AuthStatus { authenticated, unauthenticated, loading }

// Data Models
class User {
  final String id;
  final String username;
  final UserRole role;
  final DateTime lastLogin;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.lastLogin,
  });
}

class PollOption {
  final String id;
  final String text;
  final int votes;
  final List<String> voterIds; // Track who voted for security

  PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
    this.voterIds = const [],
  });

  PollOption copyWith({
    String? id,
    String? text,
    int? votes,
    List<String>? voterIds,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      votes: votes ?? this.votes,
      voterIds: voterIds ?? this.voterIds,
    );
  }
}

class Poll {
  final String id;
  final String title;
  final String description;
  final List<PollOption> options;
  final DateTime createdAt;
  final String createdBy;
  final bool isActive;

  Poll({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
    required this.createdAt,
    required this.createdBy,
    this.isActive = true,
  });

  Poll copyWith({
    String? id,
    String? title,
    String? description,
    List<PollOption>? options,
    DateTime? createdAt,
    String? createdBy,
    bool? isActive,
  }) {
    return Poll(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
    );
  }

  int get totalVotes => options.fold(0, (sum, option) => sum + option.votes);

  Set<String> get allVoterIds =>
      options.expand((option) => option.voterIds).toSet();
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  AuthState({required this.status, this.user, this.error});

  AuthState copyWith({AuthStatus? status, User? user, String? error}) {
    return AuthState(status: status ?? this.status, user: user, error: error);
  }
}

// Security Service
class SecurityService {
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool validatePassword(String password, String hashedPassword) {
    return hashPassword(password) == hashedPassword;
  }

  static bool hasPermission(User? user, String permission) {
    if (user == null) return false;

    switch (permission) {
      case 'create_poll':
      case 'view_reports':
      case 'delete_poll':
      case 'manage_users':
        return user.role == UserRole.admin;
      case 'vote':
        return true; // Both admin and guest can vote
      default:
        return false;
    }
  }
}

// Mock user database (in real app, this would be a secure backend)
final Map<String, Map<String, dynamic>> _userDatabase = {
  'admin': {
    'password': SecurityService.hashPassword('admin123'),
    'role': UserRole.admin,
  },
  'guest': {
    'password': SecurityService.hashPassword('guest123'),
    'role': UserRole.guest,
  },
};

// State Management
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(status: AuthStatus.unauthenticated));

  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final userData = _userDatabase[username];
    if (userData != null &&
        SecurityService.validatePassword(password, userData['password'])) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        role: userData['role'],
        lastLogin: DateTime.now(),
      );

      state = AuthState(status: AuthStatus.authenticated, user: user);
    } else {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: 'Invalid username or password',
      );
    }
  }

  void logout() {
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class SecurePollNotifier extends StateNotifier<List<Poll>> {
  final Ref ref;

  SecurePollNotifier(this.ref) : super([]);

  bool _hasPermission(String permission) {
    final authState = ref.read(authProvider);
    return SecurityService.hasPermission(authState.user, permission);
  }

  void addPoll(Poll poll) {
    if (!_hasPermission('create_poll')) {
      throw SecurityException('Unauthorized: Only admins can create polls');
    }
    state = [...state, poll];
  }

  void vote(String pollId, String optionId) {
    final authState = ref.read(authProvider);
    if (!_hasPermission('vote') || authState.user == null) {
      throw SecurityException('Unauthorized: Must be logged in to vote');
    }

    final userId = authState.user!.id;

    state = state.map((poll) {
      if (poll.id == pollId && poll.isActive) {
        // Check if user already voted
        if (poll.allVoterIds.contains(userId)) {
          throw SecurityException('You have already voted on this poll');
        }

        final updatedOptions = poll.options.map((option) {
          if (option.id == optionId) {
            return option.copyWith(
              votes: option.votes + 1,
              voterIds: [...option.voterIds, userId],
            );
          }
          return option;
        }).toList();
        return poll.copyWith(options: updatedOptions);
      }
      return poll;
    }).toList();
  }

  void deletePoll(String pollId) {
    if (!_hasPermission('delete_poll')) {
      throw SecurityException('Unauthorized: Only admins can delete polls');
    }
    state = state.where((poll) => poll.id != pollId).toList();
  }

  void togglePollStatus(String pollId) {
    if (!_hasPermission('create_poll')) {
      throw SecurityException('Unauthorized: Only admins can modify polls');
    }

    state = state.map((poll) {
      if (poll.id == pollId) {
        return poll.copyWith(isActive: !poll.isActive);
      }
      return poll;
    }).toList();
  }
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => message;
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final securePollProvider =
    StateNotifierProvider<SecurePollNotifier, List<Poll>>((ref) {
      return SecurePollNotifier(ref);
    });

final activeUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authProvider).user?.role;
});

// Permission Checking Provider
final permissionProvider = Provider.family<bool, String>((ref, permission) {
  final user = ref.watch(activeUserProvider);
  return SecurityService.hasPermission(user, permission);
});

// Main App
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Polling App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Auth Wrapper
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    switch (authState.status) {
      case AuthStatus.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        return const PollHomePage();
      case AuthStatus.unauthenticated:
        return const LoginPage();
    }
  }
}

// Login Page
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    ref.read(authProvider.notifier).login(username, password);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade800],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.security, size: 64, color: Colors.blue),
                      const SizedBox(height: 16),
                      const Text(
                        'Secure Polling System',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please login to continue',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: authState.status == AuthStatus.loading
                              ? null
                              : _login,
                          child: authState.status == AuthStatus.loading
                              ? const CircularProgressIndicator()
                              : const Text('LOGIN'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'Demo Credentials:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text('Admin: admin / admin123'),
                            Text('Guest: guest / guest123'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Enhanced Home Page with Security
class PollHomePage extends ConsumerWidget {
  const PollHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final polls = ref.watch(securePollProvider);
    final user = ref.watch(activeUserProvider);
    final canCreatePoll = ref.watch(permissionProvider('create_poll'));
    final canViewReports = ref.watch(permissionProvider('view_reports'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Polling App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (canViewReports)
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminReportsPage(),
                  ),
                );
              },
              tooltip: 'View Reports',
            ),
          PopupMenuButton<String>(
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text('${user?.username} (${user?.role.name})'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // User Info Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: user?.role == UserRole.admin
                  ? Colors.orange.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: user?.role == UserRole.admin
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  user?.role == UserRole.admin
                      ? Icons.admin_panel_settings
                      : Icons.person,
                  color: user?.role == UserRole.admin
                      ? Colors.orange
                      : Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${user?.username}!',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        user?.role == UserRole.admin
                            ? 'Admin - You can create polls and view reports'
                            : 'Guest - You can vote on active polls',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Quick Stats (Admin only)
          if (canViewReports)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatCard(
                    title: 'Total Polls',
                    value: polls.length.toString(),
                    icon: Icons.poll,
                  ),
                  _StatCard(
                    title: 'Active Polls',
                    value: polls.where((p) => p.isActive).length.toString(),
                    icon: Icons.play_circle,
                  ),
                  _StatCard(
                    title: 'Total Votes',
                    value: polls
                        .fold(0, (sum, poll) => sum + poll.totalVotes)
                        .toString(),
                    icon: Icons.how_to_vote,
                  ),
                ],
              ),
            ),
          if (canViewReports) const SizedBox(height: 16),
          // Poll List
          Expanded(
            child: polls.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.poll_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No polls available',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: polls.length,
                    itemBuilder: (context, index) {
                      final poll = polls[index];
                      return SecurePollCard(poll: poll);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: canCreatePoll
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePollPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Secure Poll Card Widget
class SecurePollCard extends ConsumerWidget {
  final Poll poll;

  const SecurePollCard({super.key, required this.poll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(activeUserProvider);
    final canDelete = ref.watch(permissionProvider('delete_poll'));
    final hasVoted = user != null && poll.allVoterIds.contains(user.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PollDetailPage(poll: poll)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                poll.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!poll.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'INACTIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            if (hasVoted && poll.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'VOTED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (canDelete)
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                poll.isActive ? Icons.pause : Icons.play_arrow,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(poll.isActive ? 'Deactivate' : 'Activate'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: const Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        try {
                          if (value == 'delete') {
                            ref
                                .read(securePollProvider.notifier)
                                .deletePoll(poll.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Poll deleted successfully'),
                              ),
                            );
                          } else if (value == 'toggle') {
                            ref
                                .read(securePollProvider.notifier)
                                .togglePollStatus(poll.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  poll.isActive
                                      ? 'Poll deactivated'
                                      : 'Poll activated',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                poll.description,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.how_to_vote,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${poll.totalVotes} votes',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.list, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${poll.options.length} options',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  if (canDelete) ...[
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      poll.createdBy,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Create Poll Page (Admin Only)
class CreatePollPage extends ConsumerStatefulWidget {
  const CreatePollPage({super.key});

  @override
  ConsumerState<CreatePollPage> createState() => _CreatePollPageState();
}

class _CreatePollPageState extends ConsumerState<CreatePollPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    // Check permission on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final canCreate = ref.read(permissionProvider('create_poll'));
      if (!canCreate) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied: Admin privileges required'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 6) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  void _createPoll() {
    final user = ref.read(activeUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Authentication required')));
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a poll title')),
      );
      return;
    }

    final validOptions = _optionControllers
        .where((controller) => controller.text.trim().isNotEmpty)
        .toList();

    if (validOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least 2 options')),
      );
      return;
    }

    final poll = Poll(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      options: validOptions
          .map(
            (controller) => PollOption(
              id:
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  validOptions.indexOf(controller).toString(),
              text: controller.text.trim(),
            ),
          )
          .toList(),
      createdAt: DateTime.now(),
      createdBy: user.username,
    );

    try {
      ref.read(securePollProvider.notifier).addPoll(poll);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poll created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Poll'),
        backgroundColor: Colors.orange.shade100,
        actions: [
          TextButton(onPressed: _createPoll, child: const Text('CREATE')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Admin Panel - Create New Poll',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Poll Title *',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 300,
            ),
            const SizedBox(height: 24),
            const Text(
              'Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(_optionControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _optionControllers[index],
                        decoration: InputDecoration(
                          labelText:
                              'Option ${index + 1}${index < 2 ? ' *' : ''}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    if (_optionControllers.length > 2)
                      IconButton(
                        onPressed: () => _removeOption(index),
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            if (_optionControllers.length < 6)
              OutlinedButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
              ),
          ],
        ),
      ),
    );
  }
}

// Poll Detail Page with Security
class PollDetailPage extends ConsumerWidget {
  final Poll poll;

  const PollDetailPage({super.key, required this.poll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPoll = ref
        .watch(securePollProvider)
        .firstWhere((p) => p.id == poll.id, orElse: () => poll);
    final user = ref.watch(activeUserProvider);
    final canVote = ref.watch(permissionProvider('vote'));
    final hasVoted = user != null && currentPoll.allVoterIds.contains(user.id);

    return Scaffold(
      appBar: AppBar(title: Text(currentPoll.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poll Status Banner
            if (!currentPoll.isActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.pause_circle, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'This poll is currently inactive',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            // Voting Status Banner
            if (hasVoted && currentPoll.isActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'You have already voted on this poll',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            // Poll Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPoll.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (currentPoll.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        currentPoll.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Created: ${currentPoll.createdAt.day}/${currentPoll.createdAt.month}/${currentPoll.createdAt.year}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'By: ${currentPoll.createdBy}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.how_to_vote,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Total: ${currentPoll.totalVotes} votes',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.group,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Participants: ${currentPoll.allVoterIds.length}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              canVote && currentPoll.isActive && !hasVoted
                  ? 'Vote for an option:'
                  : 'Poll Results:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Poll Options
            ...currentPoll.options.map((option) {
              final percentage = currentPoll.totalVotes > 0
                  ? (option.votes / currentPoll.totalVotes * 100)
                  : 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: canVote && currentPoll.isActive && !hasVoted
                      ? () => _vote(context, ref, currentPoll.id, option.id)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                option.text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (canVote && currentPoll.isActive && !hasVoted)
                              const Icon(Icons.touch_app, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              '${option.votes} votes',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue.shade400,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            if (!canVote)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'You need to be logged in to vote',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _vote(
    BuildContext context,
    WidgetRef ref,
    String pollId,
    String optionId,
  ) {
    try {
      ref.read(securePollProvider.notifier).vote(pollId, optionId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vote submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }
}

// Admin Reports Page
class AdminReportsPage extends ConsumerWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final polls = ref.watch(securePollProvider);
    final canViewReports = ref.watch(permissionProvider('view_reports'));

    if (!canViewReports) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Admin privileges required to view reports'),
            ],
          ),
        ),
      );
    }

    final totalPolls = polls.length;
    final activePolls = polls.where((p) => p.isActive).length;
    final totalVotes = polls.fold(0, (sum, poll) => sum + poll.totalVotes);
    final totalParticipants = polls
        .expand((poll) => poll.allVoterIds)
        .toSet()
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Reports'),
        backgroundColor: Colors.orange.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.analytics, color: Colors.orange, size: 32),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Comprehensive polling system analytics',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Statistics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _ReportCard(
                  title: 'Total Polls',
                  value: totalPolls.toString(),
                  icon: Icons.poll,
                  color: Colors.blue,
                ),
                _ReportCard(
                  title: 'Active Polls',
                  value: activePolls.toString(),
                  icon: Icons.play_circle,
                  color: Colors.green,
                ),
                _ReportCard(
                  title: 'Total Votes',
                  value: totalVotes.toString(),
                  icon: Icons.how_to_vote,
                  color: Colors.purple,
                ),
                _ReportCard(
                  title: 'Participants',
                  value: totalParticipants.toString(),
                  icon: Icons.group,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Detailed Poll Reports
            const Text(
              'Poll Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (polls.isEmpty)
              const Center(
                child: Text(
                  'No polls to display',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            else
              ...polls.map((poll) => _PollReportCard(poll: poll)),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PollReportCard extends StatelessWidget {
  final Poll poll;

  const _PollReportCard({required this.poll});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    poll.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: poll.isActive
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    poll.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: poll.isActive
                          ? Colors.green
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${poll.createdAt.day}/${poll.createdAt.month}/${poll.createdAt.year} by ${poll.createdBy}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(
                  label: 'Total Votes',
                  value: poll.totalVotes.toString(),
                  icon: Icons.how_to_vote,
                ),
                _MiniStat(
                  label: 'Options',
                  value: poll.options.length.toString(),
                  icon: Icons.list,
                ),
                _MiniStat(
                  label: 'Participants',
                  value: poll.allVoterIds.length.toString(),
                  icon: Icons.group,
                ),
              ],
            ),
            if (poll.totalVotes > 0) ...[
              const SizedBox(height: 12),
              const Text(
                'Top Option:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              () {
                final topOption = poll.options.reduce(
                  (a, b) => a.votes > b.votes ? a : b,
                );
                final percentage = (topOption.votes / poll.totalVotes * 100);
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        topOption.text,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      '${topOption.votes} votes (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }(),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
