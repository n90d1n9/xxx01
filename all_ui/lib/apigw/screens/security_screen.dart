import 'package:flutter/material.dart';

class SecurityFeaturesScreen extends StatefulWidget {
  const SecurityFeaturesScreen({super.key});

  @override
  State<SecurityFeaturesScreen> createState() => _SecurityFeaturesScreenState();
}

class _SecurityFeaturesScreenState extends State<SecurityFeaturesScreen>
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Security Features',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure authentication, authorization, and protection settings',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              ),
            ],
          ),
        ),

        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'mTLS'),
            Tab(text: 'OAuth/OIDC'),
            Tab(text: 'JWT'),
            Tab(text: 'DDoS'),
            Tab(text: 'WAF'),
          ],
          dividerColor: Colors.transparent,
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMtlsTab(context),
              _buildOAuthTab(context),
              _buildJwtTab(context),
              _buildDdosTab(context),
              _buildWafTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMtlsTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Mutual TLS Authentication',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Switch(value: true, onChanged: (value) {}),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Configure mutual TLS to ensure both client and server authenticate each other with certificates',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Certificate Configuration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Server Certificate',
                    hint: 'Select or upload server certificate',
                    icon: Icons.upload_file,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Server Private Key',
                    hint: 'Select or upload server private key',
                    icon: Icons.key,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Client CA Certificate',
                    hint: 'Select or upload client CA certificate',
                    icon: Icons.verified_user,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Verify Client Certificate',
                    subtitle: 'Enforce client certificate verification',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Verify Server Certificate',
                    subtitle: 'Enforce server certificate verification',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Pass Client Certificate',
                    subtitle: 'Forward client certificate to upstream services',
                    value: false,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Certificate Revocation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Revocation Method',
                    items: ['CRL', 'OCSP', 'Both', 'None'],
                    value: 'OCSP',
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'CRL URL',
                    hint: 'https://example.com/crl',
                    icon: Icons.link,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              const SizedBox(width: 16),
              FilledButton(onPressed: () {}, child: const Text('Save Changes')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOAuthTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.login, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'OAuth2/OpenID Connect',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Switch(value: true, onChanged: (value) {}),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Configure OAuth2 and OpenID Connect for secure API authentication',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Provider Configuration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Provider Type',
                    items: ['Keycloak', 'Okta', 'Auth0', 'Custom'],
                    value: 'Keycloak',
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Authorization URL',
                    hint: 'https://auth.example.com/oauth2/authorize',
                    icon: Icons.link,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Token URL',
                    hint: 'https://auth.example.com/oauth2/token',
                    icon: Icons.vpn_key,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Client ID',
                    hint: 'Enter client ID',
                    icon: Icons.perm_identity,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Client Secret',
                    hint: 'Enter client secret',
                    isPassword: true,
                    icon: Icons.password,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Scopes & Claims',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildChipField(
                    context,
                    label: 'Required Scopes',
                    chips: ['api', 'read', 'write'],
                  ),
                  const SizedBox(height: 16),

                  _buildChipField(
                    context,
                    label: 'Required Claims',
                    chips: ['sub', 'role', 'email'],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advanced Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Introspect Tokens',
                    subtitle: 'Validate tokens with authorization server',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Cache Tokens',
                    subtitle: 'Cache validated tokens to improve performance',
                    value: true,
                  ),

                  _buildFormField(
                    context,
                    label: 'Cache TTL (seconds)',
                    hint: '300',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              const SizedBox(width: 16),
              FilledButton(onPressed: () {}, child: const Text('Save Changes')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJwtTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'JWT Validation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Switch(value: true, onChanged: (value) {}),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Configure JWT validation parameters and token blacklisting',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Signature Verification',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Verification Method',
                    items: ['JWKS URL', 'Public Key', 'Secret Key'],
                    value: 'JWKS URL',
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'JWKS URL',
                    hint: 'https://auth.example.com/.well-known/jwks.json',
                    icon: Icons.link,
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Signing Algorithm',
                    items: [
                      'RS256',
                      'RS384',
                      'RS512',
                      'HS256',
                      'HS384',
                      'HS512',
                      'ES256',
                      'ES384',
                      'ES512',
                    ],
                    value: 'RS256',
                  ),
                  // ],
                  const SizedBox(height: 24),

                  Text(
                    'Claim Validation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Issuer (iss)',
                    hint: 'https://auth.example.com/',
                    icon: Icons.domain_verification,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Audience (aud)',
                    hint: 'api-gateway',
                    icon: Icons.groups,
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Validate Expiration',
                    subtitle: 'Check token expiry (exp claim)',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Validate Not Before',
                    subtitle: 'Check token not-before time (nbf claim)',
                    value: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Token Blacklisting',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Blacklist Storage',
                    items: ['Redis', 'etcd', 'In-memory', 'Database'],
                    value: 'Redis',
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Storage Connection String',
                    hint: 'redis://localhost:6379/0',
                    icon: Icons.storage,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Blacklist TTL (seconds)',
                    hint: '86400',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Check Revoked Tokens',
                    subtitle:
                        'Validate tokens against blacklist on each request',
                    value: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              const SizedBox(width: 16),
              FilledButton(onPressed: () {}, child: const Text('Save Changes')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDdosTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'DDoS Protection',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Switch(value: true, onChanged: (value) {}),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Configure rate limiting and IP blacklisting to prevent DDoS attacks',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate Limiting',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Rate Limit Algorithm',
                    items: [
                      'Token Bucket',
                      'Leaky Bucket',
                      'Fixed Window',
                      'Sliding Window',
                    ],
                    value: 'Token Bucket',
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Requests per Second',
                    hint: '100',
                    icon: Icons.speed,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Burst Size',
                    hint: '200',
                    icon: Icons.show_chart,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Rate Limit Key',
                    items: [
                      'IP Address',
                      'API Key',
                      'User ID',
                      'Custom Header',
                    ],
                    value: 'IP Address',
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Include Rate Limit Headers',
                    subtitle: 'Add X-RateLimit headers to responses',
                    value: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IP Blacklisting',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Auto-blacklist IPs',
                    subtitle:
                        'Automatically blacklist IPs exceeding rate limits',
                    value: true,
                  ),

                  _buildFormField(
                    context,
                    label: 'Violation Threshold',
                    hint: '5',
                    icon: Icons.warning,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Blacklist Duration (minutes)',
                    hint: '30',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'IP Whitelist',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),

                  _buildChipField(
                    context,
                    label: 'Whitelisted IPs',
                    chips: ['192.168.1.1', '10.0.0.0/24'],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Manual IP Blacklist',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),

                  _buildChipField(
                    context,
                    label: 'Blacklisted IPs',
                    chips: ['203.0.113.0/24', '198.51.100.1'],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              const SizedBox(width: 16),
              FilledButton(onPressed: () {}, child: const Text('Save Changes')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWafTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security_update, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'WAF Integration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Switch(value: true, onChanged: (value) {}),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Configure Web Application Firewall (ModSecurity) integration',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ModSecurity Configuration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'ModSecurity Mode',
                    items: ['On', 'DetectionOnly', 'Off'],
                    value: 'On',
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Configuration Path',
                    hint: '/etc/modsecurity/modsecurity.conf',
                    icon: Icons.folder,
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Enable OWASP Core Rule Set',
                    subtitle: 'Use OWASP ModSecurity Core Rule Set (CRS)',
                    value: true,
                  ),

                  _buildDropdownField(
                    context,
                    label: 'Paranoia Level',
                    items: [
                      '1 (Low)',
                      '2 (Medium)',
                      '3 (High)',
                      '4 (Very High)',
                    ],
                    value: '2 (Medium)',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rule Management',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'SQL Injection Protection',
                    subtitle: 'Detect and block SQL injection attacks',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'XSS Protection',
                    subtitle: 'Detect and block cross-site scripting attacks',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Remote File Inclusion Protection',
                    subtitle: 'Block remote file inclusion attempts',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Local File Inclusion Protection',
                    subtitle: 'Block local file inclusion attempts',
                    value: true,
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add Custom Rule'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logging & Alerting',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Log Level',
                    items: ['Error', 'Warning', 'Info', 'Debug'],
                    value: 'Warning',
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Log Path',
                    hint: '/var/log/modsec_audit.log',
                    icon: Icons.description,
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Enable Alert Notifications',
                    subtitle: 'Send notifications for detected attacks',
                    value: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              const SizedBox(width: 16),
              FilledButton(onPressed: () {}, child: const Text('Save Changes')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
    BuildContext context, {
    required String label,
    required String hint,
    IconData? icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            prefixIcon: icon != null ? Icon(icon) : null,
            suffixIcon: isPassword ? const Icon(Icons.visibility_off) : null,
          ),
          obscureText: isPassword,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    BuildContext context, {
    required String label,
    required List<String> items,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          value: value,
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: (String? newValue) {},
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: (bool newValue) {}),
        ],
      ),
    );
  }

  Widget _buildChipField(
    BuildContext context, {
    required String label,
    required List<String> chips,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...chips.map(
              (chip) => InputChip(label: Text(chip), onDeleted: () {}),
            ),
            InputChip(
              label: const Text('Add New...'),
              onPressed: () {},
              avatar: const Icon(Icons.add, size: 16),
            ),
          ],
        ),
      ],
    );
  }
}
