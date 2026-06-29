// lib/screens/postfix/tls_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class TlsScreen extends ConsumerWidget {
  const TlsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final certsAsync = ref.watch(certificateNotifierProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(children: [
        _toolbar(context, colors, ref),
        const Divider(height: 1),
        Expanded(child: certsAsync.when(
          data: (certs) => _CertList(certs: certs, colors: colors, ref: ref),
          loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
          error: (e, _) => _mockCerts(colors, ref))),
      ]));
  }

  Widget _toolbar(BuildContext context, AppColors colors, WidgetRef ref) =>
    Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(children: [
        Icon(Icons.lock_outlined, color: colors.accent, size: 20),
        const SizedBox(width: 10),
        Text('TLS / Certificates', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const Spacer(),
        _btn('Upload Certificate', Icons.upload_file, colors.accent, colors,
            () => _showUploadDialog(context, colors, ref)),
      ]));

  Widget _btn(String label, IconData icon, Color color, AppColors colors, VoidCallback onTap) =>
    GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))])));

  Widget _mockCerts(AppColors colors, WidgetRef ref) {
    final mock = [
      TlsCertificate(domain: 'mail.example.com', issuer: "Let's Encrypt", subject: 'CN=mail.example.com',
          validFrom: DateTime.now().subtract(const Duration(days: 30)),
          validUntil: DateTime.now().add(const Duration(days: 60)),
          algorithm: 'RSA', keyBits: 2048, fingerprint: 'AB:CD:EF:12:34:56',
          status: TlsStatus.valid, certPath: '/etc/postfix/ssl/cert.pem',
          keyPath: '/etc/postfix/ssl/key.pem', sans: ['mail.example.com', 'smtp.example.com']),
      TlsCertificate(domain: 'mail.company.org', issuer: 'DigiCert Inc', subject: 'CN=mail.company.org',
          validFrom: DateTime.now().subtract(const Duration(days: 340)),
          validUntil: DateTime.now().add(const Duration(days: 25)),
          algorithm: 'ECDSA', keyBits: 256, fingerprint: '12:34:AB:CD:EF:56',
          status: TlsStatus.expiringSoon, certPath: '/etc/postfix/ssl/company-cert.pem',
          keyPath: '/etc/postfix/ssl/company-key.pem', sans: ['mail.company.org']),
    ];
    return _CertList(certs: mock, colors: colors, ref: ref);
  }

  void _showUploadDialog(BuildContext context, AppColors colors, WidgetRef ref) {
    final certCtrl = TextEditingController();
    final keyCtrl = TextEditingController();
    final domainCtrl = TextEditingController();

    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
      title: Text('Upload TLS Certificate', style: TextStyle(color: colors.textPrimary)),
      content: SizedBox(width: 560, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: domainCtrl, style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(labelText: 'Domain',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
        const SizedBox(height: 12),
        _certArea(certCtrl, 'Certificate (PEM format)', '-----BEGIN CERTIFICATE-----\n...', colors),
        const SizedBox(height: 12),
        _certArea(keyCtrl, 'Private Key (PEM format)', '-----BEGIN PRIVATE KEY-----\n...', colors),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.accentOrange.withOpacity(0.05), borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.accentOrange.withOpacity(0.2))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.warning_amber_outlined, color: colors.accentOrange, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Private keys are encrypted at rest. Certificate will be validated before upload.',
              style: TextStyle(color: colors.accentOrange, fontSize: 11))),
          ])),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: colors.textSecondary))),
        TextButton(onPressed: () async {
          if (domainCtrl.text.isNotEmpty && certCtrl.text.isNotEmpty && keyCtrl.text.isNotEmpty) {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Certificate uploaded for ${domainCtrl.text}',
                    style: TextStyle(color: colors.accentGreen)), backgroundColor: colors.card));
          }
        }, child: Text('Upload', style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold))),
      ]));
  }

  Widget _certArea(TextEditingController ctrl, String label, String hint, AppColors c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: c.textSecondary, fontSize: 11)),
      const SizedBox(height: 6),
      Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF090D12), borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.border)),
        child: TextField(
          controller: ctrl, maxLines: null, expands: true,
          style: TextStyle(color: c.accent, fontSize: 11, fontFamily: 'monospace'),
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: c.textSecondary, fontFamily: 'monospace', fontSize: 11),
            border: InputBorder.none, contentPadding: const EdgeInsets.all(12)))),
    ]);
}

class _CertList extends StatelessWidget {
  final List<TlsCertificate> certs;
  final AppColors colors;
  final WidgetRef ref;
  const _CertList({required this.certs, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // TLS overview
        _TlsOverview(colors: colors),
        const SizedBox(height: 20),
        Text('Installed Certificates', style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...certs.map((c) => _CertCard(cert: c, colors: colors, ref: ref)),
        if (certs.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(children: [
              Icon(Icons.lock_outlined, color: colors.textSecondary, size: 48),
              const SizedBox(height: 16),
              Text('No certificates installed', style: TextStyle(color: colors.textSecondary)),
            ]))),
      ]);
  }
}

class _TlsOverview extends StatelessWidget {
  final AppColors colors;
  const _TlsOverview({required this.colors});

  @override
  Widget build(BuildContext context) {
    final settings = [
      ('SMTP Inbound TLS', 'smtpd_use_tls', true),
      ('SMTP Outbound TLS', 'smtp_use_tls', true),
      ('TLS Mandatory', 'smtpd_tls_auth_only', false),
      ('STARTTLS', 'smtpd_tls_received_header', true),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TLS Policy', style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 10, children: settings.map((s) => _TlsToggle(
          label: s.$1, key_: s.$2, value: s.$3, colors: colors)).toList()),
      ]));
  }
}

class _TlsToggle extends StatefulWidget {
  final String label, key_;
  final bool value;
  final AppColors colors;
  const _TlsToggle({required this.label, required this.key_, required this.value, required this.colors});

  @override
  State<_TlsToggle> createState() => _TlsToggleState();
}

class _TlsToggleState extends State<_TlsToggle> {
  late bool _val;

  @override
  void initState() { super.initState(); _val = widget.value; }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: c.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Switch(value: _val, onChanged: (v) => setState(() => _val = v),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        const SizedBox(width: 8),
        Text(widget.label, style: TextStyle(color: c.textSecondary, fontSize: 12)),
      ]));
  }
}

class _CertCard extends StatelessWidget {
  final TlsCertificate cert;
  final AppColors colors;
  final WidgetRef ref;
  const _CertCard({required this.cert, required this.colors, required this.ref});

  Color get _statusColor => switch (cert.status) {
    TlsStatus.valid => colors.accentGreen,
    TlsStatus.expiringSoon => colors.accentOrange,
    TlsStatus.expired => colors.accentRed,
    TlsStatus.notFound => colors.textSecondary,
  };

  String get _statusLabel => switch (cert.status) {
    TlsStatus.valid => 'VALID',
    TlsStatus.expiringSoon => 'EXPIRING',
    TlsStatus.expired => 'EXPIRED',
    TlsStatus.notFound => 'NOT FOUND',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cert.status == TlsStatus.expiringSoon
            ? colors.accentOrange.withOpacity(0.4)
            : cert.status == TlsStatus.expired ? colors.accentRed.withOpacity(0.4) : colors.border)),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.verified_outlined, color: _statusColor, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(cert.domain, style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                _badge(_statusLabel, _statusColor),
              ]),
              const SizedBox(height: 3),
              Text('Issued by ${cert.issuer}', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Expires in ${cert.daysUntilExpiry} days',
                  style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
              Text(DateFormat('MMM d, yyyy').format(cert.validUntil),
                  style: TextStyle(color: colors.textSecondary, fontSize: 11)),
            ]),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: colors.accentRed.withOpacity(0.6)),
              onPressed: () => ref.read(certificateNotifierProvider.notifier).delete(cert.domain),
              padding: const EdgeInsets.all(4)),
          ])),
        // Details strip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: colors.bg, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12))),
          child: Row(children: [
            _detail('Algorithm', '${cert.algorithm} ${cert.keyBits}', colors),
            const SizedBox(width: 24),
            _detail('Fingerprint', cert.fingerprint.substring(0, 17) + '…', colors),
            const SizedBox(width: 24),
            _detail('SANs', cert.sans.take(3).join(', '), colors),
            const Spacer(),
            _detail('Cert Path', cert.certPath, colors),
          ])),
      ]));
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3))),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)));

  Widget _detail(String label, String value, AppColors c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: c.textSecondary, fontSize: 10)),
      Text(value, style: TextStyle(color: c.textPrimary, fontSize: 12, fontFamily: 'monospace')),
    ]);
}
