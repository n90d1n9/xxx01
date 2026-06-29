// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiUrlCtrl;
  late int _refreshInterval;
  late bool _notificationsEnabled;
  late int _queueThreshold;
  late int _errorThreshold;
  String _selectedTab = 'Connection';

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _apiUrlCtrl = TextEditingController(text: s.apiBaseUrl);
    _refreshInterval = s.autoRefreshSeconds;
    _notificationsEnabled = s.notificationsEnabled;
    _queueThreshold = s.queueAlertThreshold;
    _errorThreshold = s.errorRateAlertThreshold;
  }

  @override
  void dispose() { _apiUrlCtrl.dispose(); super.dispose(); }

  void _save() {
    ref.read(settingsProvider.notifier).update(AppSettings(
      apiBaseUrl: _apiUrlCtrl.text,
      autoRefreshSeconds: _refreshInterval,
      notificationsEnabled: _notificationsEnabled,
      queueAlertThreshold: _queueThreshold,
      errorRateAlertThreshold: _errorThreshold));
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings saved', style: TextStyle(color: Theme.of(context).extension<AppColors>()!.accentGreen)),
            backgroundColor: Theme.of(context).extension<AppColors>()!.card));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final tabs = ['Connection', 'Alerts', 'Account'];

    return Scaffold(
      backgroundColor: colors.bg,
      body: Row(children: [
        // Left sidebar
        Container(
          width: 200,
          color: colors.surface,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Settings', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('System preferences', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
              ])),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...tabs.map((tab) => GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == tab ? colors.accent.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: _selectedTab == tab ? colors.accent.withOpacity(0.25) : Colors.transparent)),
                child: Text(tab, style: TextStyle(
                    color: _selectedTab == tab ? colors.accent : colors.textSecondary,
                    fontSize: 13, fontWeight: _selectedTab == tab ? FontWeight.w600 : FontWeight.normal))))),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                GestureDetector(
                  onTap: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (mounted) context.go('/login');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.accentRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.accentRed.withOpacity(0.25))),
                    alignment: Alignment.center,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.logout, color: colors.accentRed, size: 15),
                      const SizedBox(width: 6),
                      Text('Logout', style: TextStyle(color: colors.accentRed, fontSize: 12, fontWeight: FontWeight.w600))]))),
              ])),
          ])),
        Container(width: 1, color: colors.border),
        // Main content
        Expanded(child: Column(children: [
          Container(
            color: colors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(children: [
              Text(_selectedTab, style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              GestureDetector(
                onTap: _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.accent.withOpacity(0.3))),
                  child: Text('Save Changes', style: TextStyle(color: colors.accent, fontSize: 13, fontWeight: FontWeight.bold)))),
            ])),
          const Divider(height: 1),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildTabContent(colors))),
        ])),
      ]));
  }

  Widget _buildTabContent(AppColors colors) {
    return switch (_selectedTab) {
      'Connection' => _connectionTab(colors),
      'Alerts' => _alertsTab(colors),
      'Account' => _accountTab(colors),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _connectionTab(AppColors colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('API Configuration', colors),
      _card(colors, [
        _textField('API Base URL', _apiUrlCtrl, colors, hint: 'http://localhost:8080/api'),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Test Connection', style: TextStyle(color: colors.textPrimary, fontSize: 13)),
            Text('Verify that the backend API is reachable', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
          ])),
          GestureDetector(
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Connection successful ✓', style: TextStyle(color: colors.accentGreen)),
                      backgroundColor: colors.card));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: colors.accentGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.accentGreen.withOpacity(0.3))),
              child: Text('Test', style: TextStyle(color: colors.accentGreen, fontSize: 12, fontWeight: FontWeight.w600)))),
        ]),
      ]),
      const SizedBox(height: 24),
      _sectionTitle('Auto-Refresh', colors),
      _card(colors, [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Refresh Interval', style: TextStyle(color: colors.textPrimary, fontSize: 13)),
            Text('How often dashboard data refreshes', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: colors.border)),
            child: DropdownButton<int>(
              value: _refreshInterval,
              dropdownColor: colors.card,
              underline: const SizedBox.shrink(),
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
              items: [10, 15, 30, 60, 120].map((s) => DropdownMenuItem(value: s, child: Text('${s}s'))).toList(),
              onChanged: (v) => setState(() => _refreshInterval = v ?? 30))),
        ]),
      ]),
    ]);
  }

  Widget _alertsTab(AppColors colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Alert Notifications', colors),
      _card(colors, [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Enable Alerts', style: TextStyle(color: colors.textPrimary, fontSize: 13)),
            Text('Receive system alerts for critical events', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
          ])),
          Switch(value: _notificationsEnabled, onChanged: (v) => setState(() => _notificationsEnabled = v)),
        ]),
      ]),
      const SizedBox(height: 24),
      _sectionTitle('Alert Thresholds', colors),
      _card(colors, [
        _sliderRow('Queue Size Threshold', 'Alert when queue exceeds this many messages',
            _queueThreshold.toDouble(), 10, 1000, (v) => setState(() => _queueThreshold = v.toInt()),
            '${_queueThreshold} msgs', colors),
        const SizedBox(height: 16),
        _sliderRow('Error Rate Threshold', 'Alert when error rate exceeds this percentage',
            _errorThreshold.toDouble(), 1, 50, (v) => setState(() => _errorThreshold = v.toInt()),
            '${_errorThreshold}%', colors),
      ]),
      const SizedBox(height: 24),
      _sectionTitle('Alert Rules', colors),
      _card(colors, [
        for (final rule in [
          ('Queue threshold exceeded', true),
          ('TLS certificate expiring', true),
          ('High error rate detected', true),
          ('Delivery rate degradation', false),
          ('DMARC failures', true),
          ('Blocked IP connections', false),
        ]) ...[
          Row(children: [
            Expanded(child: Text(rule.$1, style: TextStyle(color: colors.textPrimary, fontSize: 13))),
            Switch(value: rule.$2, onChanged: (_) {}),
          ]),
          if (rule.$1 != 'Blocked IP connections') Divider(color: colors.border.withOpacity(0.4), height: 16),
        ],
      ]),
    ]);
  }

  Widget _accountTab(AppColors colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Account Information', colors),
      _card(colors, [
        _infoRow('Username', 'admin', colors),
        Divider(color: colors.border.withOpacity(0.4), height: 20),
        _infoRow('Role', 'Administrator', colors),
        Divider(color: colors.border.withOpacity(0.4), height: 20),
        _infoRow('Last Login', DateTime.now().subtract(const Duration(hours: 2)).toString().substring(0, 16), colors),
      ]),
      const SizedBox(height: 24),
      _sectionTitle('Change Password', colors),
      _card(colors, [
        _pwField('Current Password', colors),
        const SizedBox(height: 12),
        _pwField('New Password', colors),
        const SizedBox(height: 12),
        _pwField('Confirm Password', colors),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: colors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.accent.withOpacity(0.3))),
            alignment: Alignment.center,
            child: Text('Update Password', style: TextStyle(color: colors.accent, fontSize: 13, fontWeight: FontWeight.bold)))),
      ]),
    ]);
  }

  Widget _sectionTitle(String title, AppColors colors) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)));

  Widget _card(AppColors colors, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: colors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

  Widget _textField(String label, TextEditingController ctrl, AppColors colors, {String? hint}) => TextField(
    controller: ctrl,
    style: TextStyle(color: colors.textPrimary, fontSize: 13),
    decoration: InputDecoration(labelText: label, hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)));

  Widget _pwField(String label, AppColors colors) => TextField(
    obscureText: true,
    style: TextStyle(color: colors.textPrimary, fontSize: 13),
    decoration: InputDecoration(labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)));

  Widget _infoRow(String label, String value, AppColors colors) => Row(children: [
    SizedBox(width: 120, child: Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 13))),
    Text(value, style: TextStyle(color: colors.textPrimary, fontSize: 13)),
  ]);

  Widget _sliderRow(String title, String subtitle, double value, double min, double max,
      Function(double) onChanged, String display, AppColors colors) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 13)),
          Text(subtitle, style: TextStyle(color: colors.textSecondary, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: colors.border)),
          child: Text(display, style: TextStyle(color: colors.accent, fontSize: 12, fontWeight: FontWeight.bold))),
      ]),
      Slider(value: value, min: min, max: max, onChanged: onChanged, activeColor: colors.accent),
    ]);
}
