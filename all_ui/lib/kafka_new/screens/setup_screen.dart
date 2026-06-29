// Setup Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/providers.dart';
import 'dashboard_screen.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _endpointController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _apiSecretController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    await ref.read(endpointConfigProvider.notifier).loadSavedConfig();
    final config = ref.read(endpointConfigProvider);

    _endpointController.text = config.endpoint;
    _apiKeyController.text = config.apiKey ?? '';
    _apiSecretController.text = config.apiSecret ?? '';

    setState(() {
      _isLoading = false;
    });

    if (config.endpoint.isNotEmpty) {
      ref
          .read(kafkaApiServiceProvider)
          .configureEndpoint(config.endpoint, config.apiKey, config.apiSecret);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    }
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await ref
          .read(endpointConfigProvider.notifier)
          .saveConfig(
            _endpointController.text,
            _apiKeyController.text.isNotEmpty ? _apiKeyController.text : null,
            _apiSecretController.text.isNotEmpty
                ? _apiSecretController.text
                : null,
          );

      ref
          .read(kafkaApiServiceProvider)
          .configureEndpoint(
            _endpointController.text,
            _apiKeyController.text.isNotEmpty ? _apiKeyController.text : null,
            _apiSecretController.text.isNotEmpty
                ? _apiSecretController.text
                : null,
          );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kafka Manager Setup')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Configure Kafka REST API Endpoint',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _endpointController,
                      decoration: const InputDecoration(
                        labelText: 'Kafka REST API Endpoint',
                        hintText: 'https://your-kafka-rest-api.com',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an endpoint URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API Key (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiSecretController,
                      decoration: const InputDecoration(
                        labelText: 'API Secret (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveConfig,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Connect to Kafka API'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
