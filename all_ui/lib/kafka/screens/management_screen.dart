import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KafkaManagementScreen extends StatefulWidget {
  const KafkaManagementScreen({Key? key}) : super(key: key);

  @override
  _KafkaManagementScreenState createState() => _KafkaManagementScreenState();
}

class _KafkaManagementScreenState extends State<KafkaManagementScreen> {
  // Mock data for Kafka clusters
  final List<KafkaCluster> _clusters = [
    KafkaCluster(
      name: 'Production Cluster',
      brokers: 5,
      topics: 12,
      status: ClusterStatus.healthy,
    ),
    KafkaCluster(
      name: 'Staging Cluster',
      brokers: 3,
      topics: 8,
      status: ClusterStatus.warning,
    ),
    KafkaCluster(
      name: 'Development Cluster',
      brokers: 2,
      topics: 5,
      status: ClusterStatus.critical,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kafka Management',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings navigation
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshClusters,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildClusterCard(_clusters[index]),
                    childCount: _clusters.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewCluster,
        icon: Icon(Icons.add),
        label: Text('Add Cluster'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search clusters...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildClusterCard(KafkaCluster cluster) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cluster.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                _buildClusterStatusIndicator(cluster.status),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildClusterInfoChip(
                  icon: Icons.computer,
                  label: '${cluster.brokers} Brokers',
                ),
                _buildClusterInfoChip(
                  icon: Icons.topic,
                  label: '${cluster.topics} Topics',
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewClusterDetails(cluster),
                    child: Text('View Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade50,
                      foregroundColor: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClusterStatusIndicator(ClusterStatus status) {
    Color color;
    String text;

    switch (status) {
      case ClusterStatus.healthy:
        color = Colors.green;
        text = 'Healthy';
        break;
      case ClusterStatus.warning:
        color = Colors.orange;
        text = 'Warning';
        break;
      case ClusterStatus.critical:
        color = Colors.red;
        text = 'Critical';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildClusterInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.deepPurple),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshClusters() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // TODO: Implement actual cluster refresh logic
    });
  }

  void _addNewCluster() {
    // TODO: Implement add new cluster functionality
  }

  void _viewClusterDetails(KafkaCluster cluster) {
    // TODO: Implement cluster details navigation
  }
}

class KafkaManagementScreen extends StatefulWidget {
  const KafkaManagementScreen({Key? key}) : super(key: key);

  @override
  _KafkaManagementScreenState createState() => _KafkaManagementScreenState();
}

class _KafkaManagementScreenState extends State<KafkaManagementScreen> {
  final TextEditingController _bootstrapServersController =
      TextEditingController();
  final TextEditingController _topicNameController = TextEditingController();

  @override
  void dispose() {
    _bootstrapServersController.dispose();
    _topicNameController.dispose();
    super.dispose();
  }

  void _showAddClusterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add Kafka Cluster'),
            content: TextField(
              controller: _bootstrapServersController,
              decoration: InputDecoration(
                hintText: 'Enter bootstrap servers (e.g., localhost:9092)',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final kafkaService = context.read<KafkaService>();
                  kafkaService.connectToCluster(
                    _bootstrapServersController.text,
                  );
                  Navigator.of(context).pop();
                },
                child: Text('Connect'),
              ),
            ],
          ),
    );
  }

  void _showCreateTopicDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Create Kafka Topic'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _topicNameController,
                  decoration: InputDecoration(hintText: 'Enter topic name'),
                ),
                // Additional configuration for partitions, replication factor, etc.
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final kafkaService = context.read<KafkaService>();
                  kafkaService.createTopic(_topicNameController.text);
                  Navigator.of(context).pop();
                },
                child: Text('Create'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kafka Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Implement cluster refresh
              context.read<KafkaService>().fetchTopics('current');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<KafkaCluster>>(
        stream: context.read<KafkaService>().clustersStream,
        builder: (context, clustersSnapshot) {
          if (!clustersSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<KafkaTopic>>(
            stream: context.read<KafkaService>().topicsStream,
            builder: (context, topicsSnapshot) {
              if (!topicsSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              return ListView(
                children: [
                  // Clusters Section
                  _buildSectionHeader('Clusters'),
                  ...clustersSnapshot.data!
                      .map((cluster) => _buildClusterCard(cluster))
                      .toList(),

                  // Topics Section
                  _buildSectionHeader('Topics'),
                  ...topicsSnapshot.data!
                      .map((topic) => _buildTopicTile(topic))
                      .toList(),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addCluster',
            onPressed: _showAddClusterDialog,
            icon: Icon(Icons.add),
            label: Text('Add Cluster'),
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'createTopic',
            onPressed: _showCreateTopicDialog,
            icon: Icon(Icons.create),
            label: Text('Create Topic'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }

  Widget _buildClusterCard(KafkaCluster cluster) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(cluster.name),
        subtitle: Text('${cluster.brokers} Brokers, ${cluster.topics} Topics'),
        trailing: _buildClusterStatusIndicator(cluster.status),
      ),
    );
  }

  Widget _buildTopicTile(KafkaTopic topic) {
    return ListTile(
      title: Text(topic.name),
      subtitle: Text(
        'Partitions: ${topic.partitions}, '
        'Replication Factor: ${topic.replicationFactor}',
      ),
    );
  }

  Widget _buildClusterStatusIndicator(ClusterStatus status) {
    Color color;
    String text;

    switch (status) {
      case ClusterStatus.healthy:
        color = Colors.green;
        text = 'Healthy';
        break;
      case ClusterStatus.warning:
        color = Colors.orange;
        text = 'Warning';
        break;
      case ClusterStatus.critical:
        color = Colors.red;
        text = 'Critical';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Advanced Kafka Management Screen
class AdvancedKafkaManagementScreen extends StatefulWidget {
  @override
  _AdvancedKafkaManagementScreenState createState() =>
      _AdvancedKafkaManagementScreenState();
}

class _AdvancedKafkaManagementScreenState
    extends State<AdvancedKafkaManagementScreen> {
  final _bootstrapServersController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Kafka Management'),
        actions: [
          StreamBuilder<bool>(
            stream: context.read<KafkaAuthService>().authStatusStream,
            builder: (context, authSnapshot) {
              return IconButton(
                icon: Icon(
                  authSnapshot.data == true ? Icons.logout : Icons.login,
                ),
                onPressed:
                    authSnapshot.data == true
                        ? _logout
                        : _showAuthenticationDialog,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<bool>(
        stream: context.read<KafkaAuthService>().authStatusStream,
        builder: (context, authSnapshot) {
          if (authSnapshot.data != true) {
            return _buildLoginView();
          }

          return _buildKafkaDashboard();
        },
      ),
    );
  }

  Widget _buildLoginView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _bootstrapServersController,
              decoration: InputDecoration(
                labelText: 'Bootstrap Servers',
                hintText: 'e.g., localhost:9092',
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: _authenticateAndConnect,
              child: Text('Connect to Kafka'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKafkaDashboard() {
    return StreamBuilder<List<KafkaClusterDetailed>>(
      stream: context.read<KafkaManagementService>().clustersStream,
      builder: (context, clustersSnapshot) {
        if (!clustersSnapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: clustersSnapshot.data!.length,
          itemBuilder: (context, index) {
            final cluster = clustersSnapshot.data![index];
            return ExpansionTile(
              title: Text(cluster.name),
              subtitle: Text('Brokers: ${cluster.brokers.length}'),
              trailing: _buildClusterStatusIndicator(cluster.status),
              children: [
                // Detailed cluster information
                ..._buildClusterDetails(cluster),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildClusterDetails(KafkaClusterDetailed cluster) {
    return [
      // Brokers Section
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Brokers', style: Theme.of(context).textTheme.titleMedium),
      ),
      ...cluster.brokers.map(
        (broker) => ListTile(
          title: Text('Broker ${broker.id}'),
          subtitle: Text('${broker.host}:${broker.port}'),
        ),
      ),

      // Topics Section
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Topics', style: Theme.of(context).textTheme.titleMedium),
      ),
      ...cluster.topics.map(
        (topic) => ListTile(
          title: Text(topic.name),
          subtitle: Text(
            'Partitions: ${topic.partitions}, '
            'Replication Factor: ${topic.replicationFactor}',
          ),
          onTap: () => _showTopicDetailsDialog(topic),
        ),
      ),
    ];
  }

  void _showTopicDetailsDialog(KafkaTopicDetailed topic) async {
    final metrics = await context
        .read<KafkaManagementService>()
        .analyzeTopicConsumption(topic.name);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(topic.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Messages: ${metrics.totalMessages}'),
                Text('Consumed Messages: ${metrics.consumedMessages}'),
                Text('Consumer Lag: ${metrics.consumerLag}'),
                Text('Consumer Groups: ${metrics.consumerGroups.length}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _authenticateAndConnect() async {
    try {
      final authService = context.read<KafkaAuthService>();
      final managementService = context.read<KafkaManagementService>();

      // Authenticate with SASL
      await authService.authenticateWithSASL(
        username: _usernameController.text,
        password: _passwordController.text,
        mechanism: 'PLAIN', // Can be configured dynamically
      );

      // Connect to Kafka cluster
      await managementService.connectToCluster(
        bootstrapServers: _bootstrapServersController.text,
        saslConfig: SaslConfig(
          mechanism: 'PLAIN',
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Connection Error'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  void _logout() {
    context.read<KafkaAuthService>().logout();
  }

  Widget _buildClusterStatusIndicator(ClusterStatus status) {
    // Similar to previous implementation
    Color color;
    String text;

    switch (status) {
      case ClusterStatus.healthy:
        color = Colors.green;
        text = 'Healthy';
        break;
      case ClusterStatus.warning:
        color = Colors.orange;
        text = 'Warning';
        break;
      case ClusterStatus.critical:
        color = Colors.red;
        text = 'Critical';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
