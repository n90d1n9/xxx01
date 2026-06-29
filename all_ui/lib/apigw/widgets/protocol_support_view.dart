import 'package:flutter/material.dart';

import 'database_proxy_tab.dart';
import 'graphql_tab.dart';
import 'grpc_tab.dart';
import 'http_rest_tab.dart';
import 'websocket_tab.dart';

class ProtocolSupportView extends StatefulWidget {
  const ProtocolSupportView({super.key});

  @override
  State<ProtocolSupportView> createState() => _ProtocolSupportViewState();
}

class _ProtocolSupportViewState extends State<ProtocolSupportView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
          'Protocol Support',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure multi-protocol support for your Iket ',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),

        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'HTTP/REST'),
            Tab(text: 'GraphQL'),
            Tab(text: 'gRPC'),
            Tab(text: 'WebSocket'),
            Tab(text: 'Database Proxy'),
          ],
        ),

        const SizedBox(height: 16),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              HttpRestTab(),
              GraphQLTab(),
              GrpcTab(),
              WebSocketTab(),
              DatabaseProxyTab(),
            ],
          ),
        ),
      ],
    );
  }
}
