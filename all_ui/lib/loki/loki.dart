import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(LokiDashboardApp());
}

class LokiDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loki Dashboard Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        cardTheme: CardThemeData(color: Colors.grey[850], elevation: 4),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          elevation: 0,
        ),
      ),
      home: DashboardHome(),
    );
  }
}

class DashboardHome extends StatefulWidget {
  @override
  _DashboardHomeState createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  int _selectedIndex = 0;
  List<DataSource> _dataSources = [];
  DataSource? _selectedDataSource;
  List<Alert> _alerts = [];
  List<SavedQuery> _savedQueries = [];
  Timer? _refreshTimer;
  bool _autoRefresh = false;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadSampleData() {
    // Load sample data sources
    _dataSources = [
      DataSource(
        id: '1',
        name: 'Production Loki',
        url: 'http://localhost:3100',
        type: 'Loki',
        headers: {'Authorization': 'Bearer token123'},
        isHealthy: true,
      ),
      DataSource(
        id: '2',
        name: 'Staging Loki',
        url: 'http://staging:3100',
        type: 'Loki',
        isHealthy: false,
      ),
    ];

    // Load sample alerts
    _alerts = [
      Alert(
        id: '1',
        name: 'High Error Rate',
        query: 'rate({job="app"} |= "error" [5m])',
        condition: '> 0.1',
        severity: AlertSeverity.critical,
        isActive: true,
        lastTriggered: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      Alert(
        id: '2',
        name: 'Low Disk Space',
        query: 'disk_usage_percent',
        condition: '> 80',
        severity: AlertSeverity.warning,
        isActive: false,
        lastTriggered: DateTime.now().subtract(Duration(hours: 2)),
      ),
    ];

    // Load sample saved queries
    _savedQueries = [
      SavedQuery(
        id: '1',
        name: 'Error Logs',
        query: '{job="app"} |= "error"',
        description: 'Show all error logs from the application',
        tags: ['error', 'troubleshooting'],
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      SavedQuery(
        id: '2',
        name: 'API Requests',
        query:
            '{job="api"} | json | line_format "{{.method}} {{.path}} {{.status}}"',
        description: 'Formatted API request logs',
        tags: ['api', 'requests'],
        createdAt: DateTime.now().subtract(Duration(days: 3)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loki Dashboard Pro'),
        actions: [
          IconButton(
            icon: Icon(_autoRefresh ? Icons.pause : Icons.refresh),
            onPressed: _toggleAutoRefresh,
            tooltip: _autoRefresh ? 'Stop Auto Refresh' : 'Start Auto Refresh',
          ),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications),
                if (_alerts.where((a) => a.isActive).isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text(
                        '${_alerts.where((a) => a.isActive).length}',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showAlertsDialog(),
          ),
          IconButton(
            icon: Icon(Icons.fullscreen),
            onPressed: () => _toggleFullscreen(),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            extended: MediaQuery.of(context).size.width > 800,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.storage),
                label: Text('Data Sources'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search),
                label: Text('Explore'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboards'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bookmark),
                label: Text('Saved Queries'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.warning),
                label: Text('Alerts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return DataSourcesTab(
          dataSources: _dataSources,
          onDataSourcesChanged: (sources) {
            setState(() {
              _dataSources = sources;
            });
          },
          onDataSourceSelected: (source) {
            setState(() {
              _selectedDataSource = source;
            });
          },
        );
      case 1:
        return ExploreTab(
          dataSources: _dataSources,
          selectedDataSource: _selectedDataSource,
          savedQueries: _savedQueries,
          onQuerySaved: (query) {
            setState(() {
              _savedQueries.add(query);
            });
          },
        );
      case 2:
        return DashboardsTab(dataSources: _dataSources);
      case 3:
        return SavedQueriesTab(
          savedQueries: _savedQueries,
          onQueriesChanged: (queries) {
            setState(() {
              _savedQueries = queries;
            });
          },
        );
      case 4:
        return AlertsTab(
          alerts: _alerts,
          dataSources: _dataSources,
          onAlertsChanged: (alerts) {
            setState(() {
              _alerts = alerts;
            });
          },
        );
      case 5:
        return AnalyticsTab(dataSources: _dataSources);
      case 6:
        return SettingsTab();
      default:
        return Container();
    }
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefresh = !_autoRefresh;
    });

    if (_autoRefresh) {
      _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
        _refreshData();
      });
    } else {
      _refreshTimer?.cancel();
    }
  }

  void _refreshData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Refreshing data...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showAlertsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Active Alerts'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _alerts.where((a) => a.isActive).length,
                itemBuilder: (context, index) {
                  final alert = _alerts
                      .where((a) => a.isActive)
                      .elementAt(index);
                  return ListTile(
                    leading: Icon(
                      Icons.warning,
                      color:
                          alert.severity == AlertSeverity.critical
                              ? Colors.red
                              : Colors.orange,
                    ),
                    title: Text(alert.name),
                    subtitle: Text(
                      'Last triggered: ${alert.lastTriggered?.toString().substring(0, 16)}',
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _toggleFullscreen() {
    // Implement fullscreen logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Fullscreen mode toggled')));
  }
}

class DataSource {
  final String id;
  final String name;
  final String url;
  final String type;
  final Map<String, String> headers;
  final bool isHealthy;
  final DateTime? lastCheck;

  DataSource({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.headers = const {},
    this.isHealthy = true,
    this.lastCheck,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'headers': headers,
      'isHealthy': isHealthy,
      'lastCheck': lastCheck?.toIso8601String(),
    };
  }

  factory DataSource.fromJson(Map<String, dynamic> json) {
    return DataSource(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      type: json['type'],
      headers: Map<String, String>.from(json['headers'] ?? {}),
      isHealthy: json['isHealthy'] ?? true,
      lastCheck:
          json['lastCheck'] != null ? DateTime.parse(json['lastCheck']) : null,
    );
  }
}

class Alert {
  final String id;
  final String name;
  final String query;
  final String condition;
  final AlertSeverity severity;
  final bool isActive;
  final DateTime? lastTriggered;

  Alert({
    required this.id,
    required this.name,
    required this.query,
    required this.condition,
    required this.severity,
    required this.isActive,
    this.lastTriggered,
  });
}

enum AlertSeverity { info, warning, critical }

class SavedQuery {
  final String id;
  final String name;
  final String query;
  final String description;
  final List<String> tags;
  final DateTime createdAt;

  SavedQuery({
    required this.id,
    required this.name,
    required this.query,
    required this.description,
    required this.tags,
    required this.createdAt,
  });
}

class LogEntry {
  final String timestamp;
  final String message;
  final String level;
  final Map<String, dynamic> labels;

  LogEntry({
    required this.timestamp,
    required this.message,
    required this.level,
    required this.labels,
  });
}

class DataSourcesTab extends StatefulWidget {
  final List<DataSource> dataSources;
  final Function(List<DataSource>) onDataSourcesChanged;
  final Function(DataSource) onDataSourceSelected;

  DataSourcesTab({
    required this.dataSources,
    required this.onDataSourcesChanged,
    required this.onDataSourceSelected,
  });

  @override
  _DataSourcesTabState createState() => _DataSourcesTabState();
}

class _DataSourcesTabState extends State<DataSourcesTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredSources =
        widget.dataSources
            .where(
              (ds) =>
                  ds.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  ds.url.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search data sources...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddDataSourceDialog,
                icon: Icon(Icons.add),
                label: Text('Add Data Source'),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildDataSourceStats(),
          SizedBox(height: 16),
          Expanded(
            child:
                filteredSources.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storage,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No data sources configured'
                                : 'No data sources match your search',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 1200 ? 3 : 2,
                        childAspectRatio: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredSources.length,
                      itemBuilder: (context, index) {
                        final dataSource = filteredSources[index];
                        return _buildDataSourceCard(dataSource);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceStats() {
    final healthyCount = widget.dataSources.where((ds) => ds.isHealthy).length;
    final unhealthyCount = widget.dataSources.length - healthyCount;

    return Row(
      children: [
        _buildStatCard(
          'Total',
          widget.dataSources.length.toString(),
          Colors.blue,
        ),
        SizedBox(width: 16),
        _buildStatCard('Healthy', healthyCount.toString(), Colors.green),
        SizedBox(width: 16),
        _buildStatCard('Unhealthy', unhealthyCount.toString(), Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataSourceCard(DataSource dataSource) {
    return Card(
      child: InkWell(
        onTap: () => widget.onDataSourceSelected(dataSource),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: dataSource.isHealthy ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dataSource.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editDataSource(dataSource);
                          break;
                        case 'test':
                          _testDataSource(dataSource);
                          break;
                        case 'delete':
                          _deleteDataSource(dataSource);
                          break;
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(
                            value: 'test',
                            child: Text('Test Connection'),
                          ),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                dataSource.type,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                dataSource.url,
                style: TextStyle(color: Colors.grey[300], fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              if (dataSource.lastCheck != null) ...[
                SizedBox(height: 8),
                Text(
                  'Last checked: ${dataSource.lastCheck!.toString().substring(0, 16)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDataSourceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddDataSourceDialog(
            onDataSourceAdded: (dataSource) {
              setState(() {
                widget.dataSources.add(dataSource);
                widget.onDataSourcesChanged(widget.dataSources);
              });
            },
          ),
    );
  }

  void _editDataSource(DataSource dataSource) {
    showDialog(
      context: context,
      builder:
          (context) => AddDataSourceDialog(
            dataSource: dataSource,
            onDataSourceAdded: (updatedDataSource) {
              setState(() {
                final index = widget.dataSources.indexWhere(
                  (ds) => ds.id == dataSource.id,
                );
                if (index != -1) {
                  widget.dataSources[index] = updatedDataSource;
                  widget.onDataSourcesChanged(widget.dataSources);
                }
              });
            },
          ),
    );
  }

  void _deleteDataSource(DataSource dataSource) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Data Source'),
            content: Text(
              'Are you sure you want to delete "${dataSource.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    widget.dataSources.removeWhere(
                      (ds) => ds.id == dataSource.id,
                    );
                    widget.onDataSourcesChanged(widget.dataSources);
                  });
                  Navigator.pop(context);
                },
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _testDataSource(DataSource dataSource) async {
    try {
      final response = await http
          .get(
            Uri.parse('${dataSource.url}/loki/api/v1/labels'),
            headers: dataSource.headers,
          )
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class AddDataSourceDialog extends StatefulWidget {
  final DataSource? dataSource;
  final Function(DataSource) onDataSourceAdded;

  AddDataSourceDialog({this.dataSource, required this.onDataSourceAdded});

  @override
  _AddDataSourceDialogState createState() => _AddDataSourceDialogState();
}

class _AddDataSourceDialogState extends State<AddDataSourceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _headerKeyController = TextEditingController();
  final _headerValueController = TextEditingController();
  String _selectedType = 'Loki';
  Map<String, String> _headers = {};

  @override
  void initState() {
    super.initState();
    if (widget.dataSource != null) {
      _nameController.text = widget.dataSource!.name;
      _urlController.text = widget.dataSource!.url;
      _selectedType = widget.dataSource!.type;
      _headers = Map.from(widget.dataSource!.headers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.dataSource == null ? 'Add Data Source' : 'Edit Data Source',
      ),
      content: SingleChildScrollView(
        child: Container(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      ['Loki', 'Prometheus', 'Elasticsearch', 'Jaeger']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'URL',
                    hintText: 'http://localhost:3100',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a URL';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text('Headers', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 8),
                Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _headers.length,
                    itemBuilder: (context, index) {
                      final entry = _headers.entries.elementAt(index);
                      return Card(
                        child: ListTile(
                          title: Text('${entry.key}: ${entry.value}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _headers.remove(entry.key);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _headerKeyController,
                        decoration: InputDecoration(
                          labelText: 'Header Key',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _headerValueController,
                        decoration: InputDecoration(
                          labelText: 'Header Value',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (_headerKeyController.text.isNotEmpty &&
                            _headerValueController.text.isNotEmpty) {
                          setState(() {
                            _headers[_headerKeyController.text] =
                                _headerValueController.text;
                            _headerKeyController.clear();
                            _headerValueController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveDataSource, child: Text('Save')),
      ],
    );
  }

  void _saveDataSource() {
    if (_formKey.currentState!.validate()) {
      final dataSource = DataSource(
        id:
            widget.dataSource?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        url: _urlController.text,
        type: _selectedType,
        headers: _headers,
      );
      widget.onDataSourceAdded(dataSource);
      Navigator.pop(context);
    }
  }
}

class ExploreTab extends StatefulWidget {
  final List<DataSource> dataSources;
  final DataSource? selectedDataSource;
  final List<SavedQuery> savedQueries;
  final Function(SavedQuery) onQuerySaved;

  ExploreTab({
    required this.dataSources,
    this.selectedDataSource,
    required this.savedQueries,
    required this.onQuerySaved,
  });

  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final _queryController = TextEditingController();
  DataSource? _selectedDataSource;
  List<LogEntry> _logs = [];
  bool _isLoading = false;
  DateTime _startTime = DateTime.now().subtract(Duration(hours: 1));
  DateTime _endTime = DateTime.now();
  String _searchFilter = '';
  String _selectedLogLevel = 'All';
  int _limit = 1000;
  List<String> _availableLabels = [];

  @override
  void initState() {
    super.initState();
    _selectedDataSource = widget.selectedDataSource;
    _queryController.text = '{job="default"}';
    _loadAvailableLabels();
  }

  void _loadAvailableLabels() {
    // Mock labels
    _availableLabels = [
      'job',
      'instance',
      'level',
      'service',
      'environment',
      'namespace',
      'pod',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Explore', style: Theme.of(context).textTheme.headlineSmall),
              Spacer(),
              PopupMenuButton<SavedQuery>(
                child: TextButton.icon(
                  icon: Icon(Icons.bookmark),
                  label: Text('Saved Queries'),
                  onPressed: null,
                ),
                itemBuilder:
                    (context) =>
                        widget.savedQueries
                            .map(
                              (query) => PopupMenuItem(
                                value: query,
                                child: ListTile(
                                  title: Text(query.name),
                                  subtitle: Text(query.query),
                                ),
                              ),
                            )
                            .toList(),
                onSelected: (query) {
                  setState(() {
                    _queryController.text = query.query;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildQueryInterface(),
          SizedBox(height: 16),
          _buildFiltersAndOptions(),
          SizedBox(height: 16),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildQueryInterface() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DataSource>(
                    value: _selectedDataSource,
                    decoration: InputDecoration(
                      labelText: 'Data Source',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        widget.dataSources
                            .map(
                              (ds) => DropdownMenuItem(
                                value: ds,
                                child: Text(ds.name),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDataSource = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _selectedDataSource != null ? _executeQuery : null,
                  icon:
                      _isLoading
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Icon(Icons.play_arrow),
                  label: Text('Run Query'),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _showSaveQueryDialog,
                  tooltip: 'Save Query',
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: 'LogQL Query',
                hintText: 'Enter your LogQL query here...',
                border: OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.help_outline),
                      onPressed: _showQueryHelp,
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _queryController.clear();
                      },
                    ),
                  ],
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._availableLabels.map(
                  (label) => ActionChip(
                    label: Text(label),
                    onPressed: () {
                      _insertLabel(label);
                    },
                  ),
                ),
                ActionChip(
                  label: Text('Clear'),
                  onPressed: () {
                    setState(() {
                      _queryController.clear();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersAndOptions() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters & Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search in results',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchFilter = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    value: _selectedLogLevel,
                    decoration: InputDecoration(
                      labelText: 'Log Level',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ['All', 'ERROR', 'WARN', 'INFO', 'DEBUG']
                            .map(
                              (level) => DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLogLevel = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Limit',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: _limit.toString()),
                    onChanged: (value) {
                      setState(() {
                        _limit = int.tryParse(value) ?? 1000;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDateTime(true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _startTime.toString().substring(0, 16),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDateTime(false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _endTime.toString().substring(0, 16),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _endTime = DateTime.now();
                      _startTime = _endTime.subtract(Duration(hours: 1));
                    });
                  },
                  child: Text('Last Hour'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _endTime = DateTime.now();
                      _startTime = _endTime.subtract(Duration(hours: 24));
                    });
                  },
                  child: Text('Last 24h'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final filteredLogs =
        _logs.where((log) {
          final matchesSearch =
              _searchFilter.isEmpty ||
              log.message.toLowerCase().contains(_searchFilter.toLowerCase());
          final matchesLevel =
              _selectedLogLevel == 'All' || log.level == _selectedLogLevel;
          return matchesSearch && matchesLevel;
        }).toList();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Results (${filteredLogs.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.download),
                  onPressed: _exportLogs,
                  tooltip: 'Export logs',
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _executeQuery,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          Expanded(
            child:
                filteredLogs.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _isLoading ? 'Loading...' : 'No logs found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          if (!_isLoading && _selectedDataSource == null)
                            Text(
                              'Please select a data source and run a query',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        return _buildLogEntry(log);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(LogEntry log) {
    Color levelColor = Colors.white;
    switch (log.level) {
      case 'ERROR':
        levelColor = Colors.red;
        break;
      case 'WARN':
        levelColor = Colors.orange;
        break;
      case 'INFO':
        levelColor = Colors.blue;
        break;
      case 'DEBUG':
        levelColor = Colors.grey;
        break;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: levelColor, shape: BoxShape.circle),
        ),
        title: Text(
          log.message,
          style: TextStyle(fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          log.timestamp,
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(log.level),
                      backgroundColor: levelColor.withOpacity(0.2),
                      labelStyle: TextStyle(color: levelColor),
                    ),
                    SizedBox(width: 8),
                    Text(
                      log.timestamp,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    log.message,
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                if (log.labels.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    'Labels:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children:
                        log.labels.entries
                            .map(
                              (entry) => Chip(
                                label: Text('${entry.key}=${entry.value}'),
                                backgroundColor: Colors.grey[700],
                              ),
                            )
                            .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _insertLabel(String label) {
    final text = _queryController.text;
    final selection = _queryController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$label=""',
    );
    _queryController.text = newText;
    _queryController.selection = TextSelection.collapsed(
      offset: selection.start + label.length + 2,
    );
  }

  void _executeQuery() async {
    if (_selectedDataSource == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a data source')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // Generate mock log data
      final mockLogs = _generateMockLogs();

      setState(() {
        _logs = mockLogs;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Query executed successfully - ${mockLogs.length} logs found',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Query failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<LogEntry> _generateMockLogs() {
    final random = math.Random();
    final levels = ['ERROR', 'WARN', 'INFO', 'DEBUG'];
    final services = [
      'auth-service',
      'api-gateway',
      'user-service',
      'payment-service',
    ];
    final environments = ['production', 'staging', 'development'];

    return List.generate(50, (index) {
      final level = levels[random.nextInt(levels.length)];
      final service = services[random.nextInt(services.length)];
      final environment = environments[random.nextInt(environments.length)];

      return LogEntry(
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: random.nextInt(60)))
                .toIso8601String(),
        level: level,
        message: _generateMockMessage(level, service),
        labels: {
          'service': service,
          'environment': environment,
          'level': level,
          'instance': 'instance-${random.nextInt(10)}',
        },
      );
    });
  }

  String _generateMockMessage(String level, String service) {
    final random = math.Random();
    final messages = {
      'ERROR': [
        'Database connection failed',
        'Authentication failed for user',
        'Payment processing error',
        'Service unavailable',
        'Internal server error occurred',
      ],
      'WARN': [
        'High memory usage detected',
        'Slow query execution',
        'Rate limit approaching',
        'Cache miss ratio high',
        'Connection pool exhausted',
      ],
      'INFO': [
        'User successfully authenticated',
        'Request processed successfully',
        'Service started successfully',
        'Configuration loaded',
        'Health check passed',
      ],
      'DEBUG': [
        'Processing request with ID',
        'Cache hit for key',
        'Database query executed',
        'Validation passed',
        'Method entry point',
      ],
    };

    final levelMessages = messages[level] ?? ['Log message'];
    return '[$service] ${levelMessages[random.nextInt(levelMessages.length)]}';
  }

  void _selectDateTime(bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartTime ? _startTime : _endTime,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartTime ? _startTime : _endTime,
        ),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStartTime) {
            _startTime = selectedDateTime;
          } else {
            _endTime = selectedDateTime;
          }
        });
      }
    }
  }

  void _showSaveQueryDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final tagsController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Save Query'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Query Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  decoration: InputDecoration(
                    labelText: 'Tags (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final savedQuery = SavedQuery(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    query: _queryController.text,
                    description: descriptionController.text,
                    tags:
                        tagsController.text
                            .split(',')
                            .map((e) => e.trim())
                            .toList(),
                    createdAt: DateTime.now(),
                  );
                  widget.onQuerySaved(savedQuery);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Query saved successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showQueryHelp() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('LogQL Query Help'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Basic Examples:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildQueryExample(
                    '{job="app"}',
                    'Show all logs from job "app"',
                  ),
                  _buildQueryExample(
                    '{job="app"} |= "error"',
                    'Show logs containing "error"',
                  ),
                  _buildQueryExample(
                    '{job="app"} |~ "error|warn"',
                    'Show logs matching regex',
                  ),
                  _buildQueryExample(
                    'rate({job="app"}[5m])',
                    'Rate of logs per second',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Operators:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildQueryExample('|=', 'Contains string'),
                  _buildQueryExample('!=', 'Does not contain string'),
                  _buildQueryExample('|~', 'Regex match'),
                  _buildQueryExample('!~', 'Regex does not match'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildQueryExample(String query, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              query,
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  void _exportLogs() {
    // In a real app, this would export the logs to a file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export functionality would be implemented here')),
    );
  }
}

// Placeholder widgets for other tabs
class DashboardsTab extends StatelessWidget {
  final List<DataSource> dataSources;

  DashboardsTab({required this.dataSources});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 64, color: Colors.grey[600]),
          SizedBox(height: 16),
          Text(
            'Dashboards',
            style: TextStyle(fontSize: 24, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Create and manage custom dashboards',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class SavedQueriesTab extends StatelessWidget {
  final List<SavedQuery> savedQueries;
  final Function(List<SavedQuery>) onQueriesChanged;

  SavedQueriesTab({required this.savedQueries, required this.onQueriesChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saved Queries',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          Expanded(
            child:
                savedQueries.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No saved queries',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: savedQueries.length,
                      itemBuilder: (context, index) {
                        final query = savedQueries[index];
                        return Card(
                          child: ListTile(
                            title: Text(query.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(query.description),
                                SizedBox(height: 4),
                                Text(
                                  query.query,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  children:
                                      query.tags
                                          .map(
                                            (tag) => Chip(
                                              label: Text(tag),
                                              backgroundColor: Colors.grey[700],
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem(
                                      child: Text('Edit'),
                                      value: 'edit',
                                    ),
                                    PopupMenuItem(
                                      child: Text('Delete'),
                                      value: 'delete',
                                    ),
                                  ],
                              onSelected: (value) {
                                if (value == 'delete') {
                                  final updatedQueries = List<SavedQuery>.from(
                                    savedQueries,
                                  );
                                  updatedQueries.removeAt(index);
                                  onQueriesChanged(updatedQueries);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class AlertsTab extends StatelessWidget {
  final List<Alert> alerts;
  final List<DataSource> dataSources;
  final Function(List<Alert>) onAlertsChanged;

  AlertsTab({
    required this.alerts,
    required this.dataSources,
    required this.onAlertsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Alerts', style: Theme.of(context).textTheme.headlineSmall),
              Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCreateAlertDialog(context),
                icon: Icon(Icons.add),
                label: Text('Create Alert'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child:
                alerts.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No alerts configured',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              alert.isActive
                                  ? Icons.warning
                                  : Icons.warning_outlined,
                              color:
                                  alert.isActive
                                      ? (alert.severity ==
                                              AlertSeverity.critical
                                          ? Colors.red
                                          : Colors.orange)
                                      : Colors.grey,
                            ),
                            title: Text(alert.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alert.query),
                                SizedBox(height: 4),
                                Text(
                                  'Condition: ${alert.condition}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                if (alert.lastTriggered != null)
                                  Text(
                                    'Last triggered: ${alert.lastTriggered.toString().substring(0, 16)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Switch(
                              value: alert.isActive,
                              onChanged: (value) {
                                // Toggle alert active state
                              },
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  void _showCreateAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Create Alert'),
            content: Text('Alert creation dialog would be implemented here'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Create'),
              ),
            ],
          ),
    );
  }
}

class AnalyticsTab extends StatelessWidget {
  final List<DataSource> dataSources;

  AnalyticsTab({required this.dataSources});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey[600]),
          SizedBox(height: 16),
          Text(
            'Analytics',
            style: TextStyle(fontSize: 24, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'View logs analytics and statistics',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.grey[600]),
          SizedBox(height: 16),
          Text(
            'Settings',
            style: TextStyle(fontSize: 24, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Configure dashboard preferences',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
