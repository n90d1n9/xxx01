import 'package:flutter/material.dart';

import 'advanced_rules_tab.dart';
import 'http_routing_tab.dart';
import 'tcp_tab.dart';

class TrafficControlView extends StatefulWidget {
  const TrafficControlView({super.key});

  @override
  State<TrafficControlView> createState() => _TrafficControlViewState();
}

class _TrafficControlViewState extends State<TrafficControlView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _protocols = [
    'HTTP/1.x',
    'HTTP/2',
    'gRPC',
    'WebSocket',
    'MQTT',
    'TCP/UDP',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Traffic Control',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Protocol Support
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protocol Support',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Protocol chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _protocols.map((protocol) {
                        return Chip(
                          label: Text(protocol),
                          avatar: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: Icon(
                              _getProtocolIcon(protocol),
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Tabs for different routing configurations
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'HTTP Routing'),
            Tab(text: 'TCP/UDP Proxy'),
            Tab(text: 'Advanced Rules'),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              HttpRoutingTab(),
              TcpUdpProxyTab(),
              AdvancedRulesTab(),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getProtocolIcon(String protocol) {
    switch (protocol) {
      case 'HTTP/1.x':
      case 'HTTP/2':
        return Icons.http;
      case 'gRPC':
        return Icons.grain;
      case 'WebSocket':
        return Icons.sync_alt;
      case 'MQTT':
        return Icons.message;
      case 'TCP/UDP':
        return Icons.lan;
      default:
        return Icons.settings_ethernet;
    }
  }
}
