import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OAuth2ConfigPanel extends ConsumerWidget {
  const OAuth2ConfigPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OAuth2 & Authorization',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildOAuth2CredentialsCard(context)),
              const SizedBox(width: 24),
              Expanded(child: _buildScopesCard(context)),
            ],
          ),
          const SizedBox(height: 24),
          _buildGrantTypesCard(context),
          const SizedBox(height: 24),
          _buildTokenManagementCard(context),
        ],
      ),
    );
  }

  Widget _buildOAuth2CredentialsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.vpn_key,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'OAuth2 Credentials',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Client ID',
                hintText: 'a1b2c3d4e5f6g7h8',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Client Secret',
                hintText: '••••••••••••••••',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              label: const Text('Rotate Credentials'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'OAuth2 Scopes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildScopeCheckbox('openid', 'OpenID Connect'),
            _buildScopeCheckbox('profile', 'Profile Information'),
            _buildScopeCheckbox('email', 'Email Address'),
            _buildScopeCheckbox('tools:execute', 'Execute Tools'),
            _buildScopeCheckbox('resources:read', 'Read Resources'),
            _buildScopeCheckbox('resources:write', 'Write Resources'),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeCheckbox(String scope, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [Checkbox(value: true, onChanged: null), Text(label)],
      ),
    );
  }

  Widget _buildGrantTypesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.privacy_tip,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Supported Grant Types',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGrantTypeItem(
              context,
              'Authorization Code',
              'For traditional web applications',
              true,
            ),
            _buildGrantTypeItem(
              context,
              'Client Credentials',
              'For service-to-service communication',
              true,
            ),
            _buildGrantTypeItem(
              context,
              'Resource Owner Password',
              'For trusted applications only',
              false,
            ),
            _buildGrantTypeItem(
              context,
              'Implicit',
              'For browser-based applications (legacy)',
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrantTypeItem(
    BuildContext context,
    String title,
    String description,
    bool enabled,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
        color: enabled ? null : Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Checkbox(value: enabled, onChanged: null),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenManagementCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.token, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Active Tokens',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTokenRow(
              'prod-token-xyz',
              'user@example.com',
              'Authorization Code',
              '3 days',
            ),
            _buildTokenRow(
              'staging-token-abc',
              'system@example.com',
              'Client Credentials',
              '5 minutes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenRow(
    String token,
    String user,
    String grantType,
    String expiresIn,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  token.substring(0, 10) + '...',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Row(
                  children: [
                    Text(user, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        grantType,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Expires in', style: const TextStyle(fontSize: 12)),
              Text(
                expiresIn,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () {}),
        ],
      ),
    );
  }
}
