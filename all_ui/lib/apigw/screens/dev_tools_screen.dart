import 'package:flutter/material.dart';

class DeveloperToolsScreen extends StatefulWidget {
  const DeveloperToolsScreen({Key? key}) : super(key: key);

  @override
  State<DeveloperToolsScreen> createState() => _DeveloperToolsScreenState();
}

class _DeveloperToolsScreenState extends State<DeveloperToolsScreen> {
  bool _restApiEnabled = true;
  bool _declarativeConfigEnabled = true;
  String _selectedConfigFormat = 'YAML';
  bool _dashboardEnabled = true;
  String _selectedTheme = 'Light';

  final List<String> _configFormats = ['YAML', 'JSON'];
  final List<String> _themes = ['Light', 'Dark', 'System'];

  // Infrastructure as Code selections
  final Map<String, bool> _infraToolsEnabled = {
    'Terraform': true,
    'Ansible': false,
    'Helm': true,
    'Kubernetes Operator': false,
  };

  // WebAssembly related settings
  bool _wasmEnabled = false;
  int _wasmMemoryLimit = 128;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Developer & DevOps Tools', Icons.code),
            const SizedBox(height: 24),

            // REST Admin API Section
            _buildRestApiSection(),
            const Divider(height: 32),

            // Declarative Configuration Section
            _buildDeclarativeConfigSection(),
            const Divider(height: 32),

            // Dashboard Configuration
            _buildDashboardSection(),
            const Divider(height: 32),

            // Infrastructure as Code Support
            _buildInfrastructureSection(),
            const Divider(height: 32),

            // WebAssembly Support
            _buildWasmSection(),
            const Divider(height: 32),

            // Save & Apply Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Developer tools configuration saved'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Configuration'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRestApiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REST Admin API',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable REST Admin API'),
          subtitle: const Text('Allow configuration via REST API calls'),
          value: _restApiEnabled,
          onChanged: (value) {
            setState(() {
              _restApiEnabled = value;
            });
          },
        ),
        if (_restApiEnabled) ...[
          Card(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFormField(
                    label: 'API Endpoint',
                    initialValue: '/admin/api/v1',
                    icon: Icons.link,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    label: 'API Key',
                    initialValue: '••••••••••••••••',
                    obscureText: true,
                    icon: Icons.key,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('New API key generated'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'API Authentication Method',
                    value: 'API Key',
                    items: ['API Key', 'Bearer Token', 'Basic Auth', 'OAuth2'],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    label: 'Access Control CIDR',
                    initialValue: '10.0.0.0/8, 192.168.0.0/16',
                    icon: Icons.security,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDeclarativeConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Declarative Configuration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable Declarative Configuration'),
          subtitle: const Text('Configure gateway using config files'),
          value: _declarativeConfigEnabled,
          onChanged: (value) {
            setState(() {
              _declarativeConfigEnabled = value;
            });
          },
        ),
        if (_declarativeConfigEnabled) ...[
          Card(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdownField(
                    label: 'Configuration Format',
                    value: _selectedConfigFormat,
                    items: _configFormats,
                    onChanged: (value) {
                      setState(() {
                        _selectedConfigFormat = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    label: 'Config Directory Path',
                    initialValue: '/etc/api-gateway/config',
                    icon: Icons.folder,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Config Reload Strategy',
                          value: 'Watch for Changes',
                          items: ['Manual', 'Periodic', 'Watch for Changes'],
                          onChanged: (value) {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextFormField(
                          label: 'Reload Interval (seconds)',
                          initialValue: '30',
                          keyboardType: TextInputType.number,
                          icon: Icons.timer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    label: const Text('Export Current Configuration'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDashboardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Management Dashboard',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable Built-in Dashboard'),
          subtitle: const Text('Web-based management interface'),
          value: _dashboardEnabled,
          onChanged: (value) {
            setState(() {
              _dashboardEnabled = value;
            });
          },
        ),
        if (_dashboardEnabled) ...[
          Card(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextFormField(
                          label: 'Dashboard URL Path',
                          initialValue: '/dashboard',
                          icon: Icons.web,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Dashboard Theme',
                          value: _selectedTheme,
                          items: _themes,
                          onChanged: (value) {
                            setState(() {
                              _selectedTheme = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    label: 'Dashboard Admin Username',
                    initialValue: 'admin',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    label: 'Dashboard Admin Password',
                    initialValue: '••••••••••••••••',
                    obscureText: true,
                    icon: Icons.password,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Enable Read-Only Mode'),
                          value: false,
                          onChanged: (value) {},
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Enable Audit Logging'),
                          value: true,
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfrastructureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Infrastructure as Code Support',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              _infraToolsEnabled.entries.map((entry) {
                return FilterChip(
                  selected: entry.value,
                  label: Text(entry.key),
                  avatar: Icon(
                    _getInfraToolIcon(entry.key),
                    size: 18,
                    color: entry.value ? Colors.white : Colors.grey,
                  ),
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.8),
                  showCheckmark: false,
                  onSelected: (value) {
                    setState(() {
                      _infraToolsEnabled[entry.key] = value;
                    });
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
        if (_infraToolsEnabled.containsValue(true)) ...[
          Card(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_infraToolsEnabled['Terraform'] == true) ...[
                    _buildTextFormField(
                      label: 'Terraform Provider Version',
                      initialValue: 'v1.2.0',
                      icon: Icons.extension,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_infraToolsEnabled['Helm'] == true) ...[
                    _buildTextFormField(
                      label: 'Helm Chart Repository',
                      initialValue: 'https://charts.example.com/api-gateway',
                      icon: Icons.public,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.description),
                          label: const Text('View Documentation'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.cloud_download),
                          label: const Text('Download Templates'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWasmSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WebAssembly (Wasm) Support',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable WebAssembly Support'),
          subtitle: const Text('Run custom logic with WebAssembly modules'),
          value: _wasmEnabled,
          onChanged: (value) {
            setState(() {
              _wasmEnabled = value;
            });
          },
        ),
        if (_wasmEnabled) ...[
          Card(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFormField(
                    label: 'Wasm Modules Directory',
                    initialValue: '/etc/api-gateway/wasm-modules',
                    icon: Icons.folder_special,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Runtime',
                          value: 'wasmtime',
                          items: ['wasmtime', 'wasmer', 'wasm3', 'wasmedge'],
                          onChanged: (value) {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextFormField(
                          label: 'Memory Limit (MB)',
                          initialValue: _wasmMemoryLimit.toString(),
                          keyboardType: TextInputType.number,
                          icon: Icons.memory,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                _wasmMemoryLimit =
                                    int.tryParse(value) ?? _wasmMemoryLimit;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbColor: Theme.of(context).primaryColor,
                      activeTrackColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.5),
                      inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Memory Limit (MB)'),
                            Text('$_wasmMemoryLimit MB'),
                          ],
                        ),
                        Slider(
                          min: 32,
                          max: 512,
                          divisions: 15,
                          value: _wasmMemoryLimit.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              _wasmMemoryLimit = value.toInt();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Uploaded Wasm Modules',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 2,
                      separatorBuilder:
                          (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final modules = [
                          {
                            'name': 'request-transform.wasm',
                            'size': '237 KB',
                            'active': true,
                          },
                          {
                            'name': 'custom-auth.wasm',
                            'size': '154 KB',
                            'active': false,
                          },
                        ];
                        final module = modules[index];

                        return ListTile(
                          title: Text('${module['name']}'),
                          subtitle: Text('Size: ${module['size']}'),
                          leading: const Icon(Icons.file_present),
                          trailing: Switch(
                            value: module['active'] as bool,
                            onChanged: (value) {},
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload New Wasm Module'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String initialValue,
    bool obscureText = false,
    IconData? icon,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
    );
  }

  IconData _getInfraToolIcon(String tool) {
    switch (tool) {
      case 'Terraform':
        return Icons.settings_applications;
      case 'Ansible':
        return Icons.sync;
      case 'Helm':
        return Icons.sailing;
      case 'Kubernetes Operator':
        return Icons.grain;
      default:
        return Icons.code;
    }
  }
}
