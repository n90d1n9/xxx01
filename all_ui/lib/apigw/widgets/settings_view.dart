import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _formKey = GlobalKey<FormState>();

  // Settings state
  bool _enableLogging = true;
  bool _enableMetrics = true;
  bool _enableRateLimiting = true;
  bool _enableCircuitBreaker = true;
  bool _enableCors = true;

  String _logLevel = 'INFO';
  final List<String> _logLevels = ['DEBUG', 'INFO', 'WARN', 'ERROR'];

  String _rateLimit = '1000/minute';
  final List<String> _rateLimits = [
    '100/minute',
    '500/minute',
    '1000/minute',
    '5000/minute',
    '10000/minute',
  ];

  // Timeout settings
  int _readTimeout = 30;
  int _writeTimeout = 30;
  int _connectTimeout = 10;

  // Circuit breaker settings
  int _errorThreshold = 50;
  int _resetTimeout = 30;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Gateway Settings',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure the global settings for your Iket ',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          // Settings Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // General Settings Card
                _buildSettingsCard(
                  context,
                  'General Settings',
                  'Basic gateway configuration',
                  [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Log Level',
                        border: OutlineInputBorder(),
                      ),
                      value: _logLevel,
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _logLevel = value;
                          });
                        }
                      },
                      items:
                          _logLevels.map((String level) {
                            return DropdownMenuItem<String>(
                              value: level,
                              child: Text(level),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enable Logging'),
                      subtitle: const Text('Record detailed gateway activity'),
                      value: _enableLogging,
                      onChanged: (bool value) {
                        setState(() {
                          _enableLogging = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Enable Metrics'),
                      subtitle: const Text(
                        'Collect performance and usage statistics',
                      ),
                      value: _enableMetrics,
                      onChanged: (bool value) {
                        setState(() {
                          _enableMetrics = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Connection Settings Card
                _buildSettingsCard(
                  context,
                  'Connection Settings',
                  'Configure timeout and connection parameters',
                  [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Read Timeout (seconds)',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: _readTimeout.toString(),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value.isNotEmpty &&
                                  int.tryParse(value) != null) {
                                setState(() {
                                  _readTimeout = int.parse(value);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Write Timeout (seconds)',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: _writeTimeout.toString(),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value.isNotEmpty &&
                                  int.tryParse(value) != null) {
                                setState(() {
                                  _writeTimeout = int.parse(value);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Connect Timeout (seconds)',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _connectTimeout.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.isNotEmpty && int.tryParse(value) != null) {
                          setState(() {
                            _connectTimeout = int.parse(value);
                          });
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Security Settings Card
                _buildSettingsCard(
                  context,
                  'Security Settings',
                  'Configure rate limiting and security features',
                  [
                    SwitchListTile(
                      title: const Text('Enable Rate Limiting'),
                      subtitle: const Text(
                        'Protect services from excessive traffic',
                      ),
                      value: _enableRateLimiting,
                      onChanged: (bool value) {
                        setState(() {
                          _enableRateLimiting = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Default Rate Limit',
                        border: OutlineInputBorder(),
                        enabled: true,
                      ),
                      value: _rateLimit,
                      onChanged:
                          _enableRateLimiting
                              ? (String? value) {
                                if (value != null) {
                                  setState(() {
                                    _rateLimit = value;
                                  });
                                }
                              }
                              : null,
                      items:
                          _rateLimits.map((String limit) {
                            return DropdownMenuItem<String>(
                              value: limit,
                              child: Text(limit),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enable CORS'),
                      subtitle: const Text('Cross-Origin Resource Sharing'),
                      value: _enableCors,
                      onChanged: (bool value) {
                        setState(() {
                          _enableCors = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Circuit Breaker Settings Card
                _buildSettingsCard(
                  context,
                  'Circuit Breaker Settings',
                  'Configure protection against cascading failures',
                  [
                    SwitchListTile(
                      title: const Text('Enable Circuit Breaker'),
                      subtitle: const Text('Prevent cascading failures'),
                      value: _enableCircuitBreaker,
                      onChanged: (bool value) {
                        setState(() {
                          _enableCircuitBreaker = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Error Threshold (%)',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: _errorThreshold.toString(),
                            keyboardType: TextInputType.number,
                            enabled: _enableCircuitBreaker,
                            validator: (value) {
                              if (!_enableCircuitBreaker) return null;
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              final parsed = int.tryParse(value);
                              if (parsed == null) {
                                return 'Please enter a valid number';
                              }
                              if (parsed < 0 || parsed > 100) {
                                return 'Value must be between 0 and 100';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value.isNotEmpty &&
                                  int.tryParse(value) != null) {
                                setState(() {
                                  _errorThreshold = int.parse(value);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Reset Timeout (seconds)',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: _resetTimeout.toString(),
                            keyboardType: TextInputType.number,
                            enabled: _enableCircuitBreaker,
                            validator: (value) {
                              if (!_enableCircuitBreaker) return null;
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value.isNotEmpty &&
                                  int.tryParse(value) != null) {
                                setState(() {
                                  _resetTimeout = int.parse(value);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Save Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // Reset form logic
                      },
                      child: const Text('Reset'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Save settings logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings saved')),
                          );
                        }
                      },
                      child: const Text('Save Settings'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    String title,
    String subtitle,
    List<Widget> children,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
