// lib/screens/postfix/dns_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class DnsScreen extends ConsumerStatefulWidget {
  const DnsScreen({super.key});
  @override
  ConsumerState<DnsScreen> createState() => _DnsScreenState();
}

class _DnsScreenState extends ConsumerState<DnsScreen> {
  final _domainCtrl = TextEditingController();
  String _checkedDomain = '';
  bool _checking = false;
  DnsHealth? _result;

  @override
  void dispose() { _domainCtrl.dispose(); super.dispose(); }

  Future<void> _check() async {
    if (_domainCtrl.text.isEmpty) return;
    setState(() { _checking = true; _result = null; });
    try {
      // Mock DNS check result for demo
      await Future.delayed(const Duration(milliseconds: 800));
      _result = _mockDnsHealth(_domainCtrl.text.trim());
      _checkedDomain = _domainCtrl.text.trim();
    } catch (e) {
      _result = _mockDnsHealth(_domainCtrl.text.trim());
      _checkedDomain = _domainCtrl.text.trim();
    } finally {
      setState(() => _checking = false);
    }
  }

  DnsHealth _mockDnsHealth(String domain) => DnsHealth(
    spf: DnsCheckStatus.pass, dkim: DnsCheckStatus.pass,
    dmarc: DnsCheckStatus.fail, mx: DnsCheckStatus.pass, rdns: DnsCheckStatus.pass,
    spfRecord: 'v=spf1 include:_spf.google.com include:mailgun.org ~all',
    dmarcRecord: null,
    mxRecords: [MxRecord(priority: 10, hostname: 'mail.$domain', ip: '203.0.113.1'),
                  MxRecord(priority: 20, hostname: 'mail2.$domain', ip: '203.0.113.2')],
    rdnsResult: 'mail.$domain',
    dkimSelector: 'default');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(children: [
        _buildHeader(colors),
        const Divider(height: 1),
        Expanded(child: _result == null ? _buildEmpty(colors) : _buildResults(colors)),
      ]));
  }

  Widget _buildHeader(AppColors colors) => Container(
    color: colors.surface,
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.dns_outlined, color: colors.accent, size: 20),
        const SizedBox(width: 10),
        Text('DNS Health Inspector', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: TextField(
          controller: _domainCtrl,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Domain to inspect',
            hintText: 'example.com',
            prefixIcon: Icon(Icons.search, color: colors.textSecondary, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          onSubmitted: (_) => _check())),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _checking ? null : _check,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: colors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.accent.withOpacity(0.4))),
            child: _checking
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: colors.accent, strokeWidth: 2))
                : Text('Inspect', style: TextStyle(color: colors.accent, fontSize: 13, fontWeight: FontWeight.bold)))),
      ]),
    ]));

  Widget _buildEmpty(AppColors colors) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.dns_outlined, color: colors.textSecondary, size: 64),
      const SizedBox(height: 20),
      Text('Enter a domain to check DNS health', style: TextStyle(color: colors.textSecondary, fontSize: 16)),
      const SizedBox(height: 8),
      Text('Checks SPF, DKIM, DMARC, MX records, and rDNS', style: TextStyle(color: colors.textSecondary, fontSize: 13)),
    ]));

  Widget _buildResults(AppColors colors) {
    final h = _result!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Score overview
        _ScoreCard(health: h, domain: _checkedDomain, colors: colors),
        const SizedBox(height: 20),
        // Check tiles grid
        GridView.count(
          crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6,
          children: [
            _DnsCheckTile('SPF', 'Sender Policy Framework', h.spf, colors, record: h.spfRecord,
                tip: h.spf == DnsCheckStatus.fail
                    ? 'Add a TXT record: v=spf1 a mx ~all' : 'SPF record is properly configured'),
            _DnsCheckTile('DKIM', 'DomainKeys Identified Mail', h.dkim, colors,
                tip: h.dkim == DnsCheckStatus.pass
                    ? 'DKIM signing is active (selector: ${h.dkimSelector})'
                    : 'Generate DKIM keys with: opendkim-genkey -s default -d $_checkedDomain'),
            _DnsCheckTile('DMARC', 'Domain Message Auth Report', h.dmarc, colors, record: h.dmarcRecord,
                tip: h.dmarc == DnsCheckStatus.fail
                    ? 'Add: v=DMARC1; p=quarantine; rua=mailto:dmarc@$_checkedDomain' : 'DMARC policy is set'),
            _DnsCheckTile('MX', 'Mail Exchange Records', h.mx, colors,
                tip: '${h.mxRecords.length} MX record(s) found'),
            _DnsCheckTile('rDNS', 'Reverse DNS (PTR)', h.rdns, colors, record: h.rdnsResult,
                tip: h.rdns == DnsCheckStatus.pass
                    ? 'PTR record resolves to: ${h.rdnsResult}' : 'Contact your ISP to set rDNS'),
            _DnsCheckTile('DNSSEC', 'DNS Security Extensions', DnsCheckStatus.unknown, colors,
                tip: 'DNSSEC validation requires registrar support'),
          ]),
        const SizedBox(height: 20),
        // MX Records detail
        if (h.mxRecords.isNotEmpty) _MxTable(records: h.mxRecords, colors: colors),
        const SizedBox(height: 20),
        // Recommendations
        _Recommendations(health: h, colors: colors),
      ]));
  }
}

class _ScoreCard extends StatelessWidget {
  final DnsHealth health;
  final String domain;
  final AppColors colors;
  const _ScoreCard({required this.health, required this.domain, required this.colors});

  @override
  Widget build(BuildContext context) {
    final score = health.passCount;
    final total = health.total;
    final scoreColor = score >= 4 ? colors.accentGreen : score >= 2 ? colors.accentOrange : colors.accentRed;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border)),
      child: Row(children: [
        // Score circle
        SizedBox(width: 80, height: 80, child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(
            value: score / total,
            backgroundColor: colors.border,
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            strokeWidth: 8),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$score/$total', style: TextStyle(color: scoreColor, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('checks', style: TextStyle(color: colors.textSecondary, fontSize: 9)),
          ]),
        ])),
        const SizedBox(width: 24),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('DNS Health: $domain', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: scoreColor.withOpacity(0.3))),
              child: Text(score >= 4 ? 'EXCELLENT' : score >= 2 ? 'NEEDS WORK' : 'CRITICAL',
                  style: TextStyle(color: scoreColor, fontSize: 11, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 8),
          Text(
            score == total
                ? 'All DNS records are properly configured. Your mail delivery should be excellent.'
                : 'Some DNS records need attention. Check the recommendations below.',
            style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        ])),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colors.bg, borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.refresh, color: colors.accent, size: 15),
              const SizedBox(width: 6),
              Text('Re-check', style: TextStyle(color: colors.accent, fontSize: 12)),
            ]))),
      ]));
  }
}

class _DnsCheckTile extends StatelessWidget {
  final String label, description;
  final DnsCheckStatus status;
  final AppColors colors;
  final String? record;
  final String? tip;
  const _DnsCheckTile(this.label, this.description, this.status, this.colors, {this.record, this.tip});

  Color get _statusColor => switch (status) {
    DnsCheckStatus.pass => colors.accentGreen,
    DnsCheckStatus.fail => colors.accentRed,
    DnsCheckStatus.none => colors.accentOrange,
    DnsCheckStatus.unknown => colors.textSecondary,
  };

  IconData get _icon => switch (status) {
    DnsCheckStatus.pass => Icons.check_circle_outline,
    DnsCheckStatus.fail => Icons.cancel_outlined,
    DnsCheckStatus.none => Icons.help_outline,
    DnsCheckStatus.unknown => Icons.remove_circle_outline,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: status == DnsCheckStatus.fail
            ? colors.accentRed.withOpacity(0.3) : colors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(_icon, color: _statusColor, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: _statusColor.withOpacity(0.4), blurRadius: 4)])),
        ]),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(color: colors.textSecondary, fontSize: 11)),
        if (record != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.bg, borderRadius: BorderRadius.circular(4), border: Border.all(color: colors.border)),
            child: Row(children: [
              Expanded(child: Text(record!, style: TextStyle(color: _statusColor, fontSize: 10, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis)),
              GestureDetector(onTap: () => Clipboard.setData(ClipboardData(text: record!)),
                  child: Icon(Icons.copy, size: 12, color: colors.textSecondary)),
            ])),
        ],
        if (tip != null) ...[
          const SizedBox(height: 8),
          Text(tip!, style: TextStyle(color: colors.textSecondary, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ]));
  }
}

class _MxTable extends StatelessWidget {
  final List<MxRecord> records;
  final AppColors colors;
  const _MxTable({required this.records, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.border)),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            Icon(Icons.mail_outline, color: colors.accent, size: 16),
            const SizedBox(width: 8),
            Text('MX Records', style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          ])),
        ...records.map((r) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.border.withOpacity(0.4)))),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: colors.accent.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
              alignment: Alignment.center,
              child: Text('${r.priority}', style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold, fontSize: 13))),
            const SizedBox(width: 14),
            Expanded(child: Text(r.hostname, style: TextStyle(color: colors.textPrimary, fontSize: 13, fontFamily: 'monospace'))),
            if (r.ip != null) Text(r.ip!, style: TextStyle(color: colors.textSecondary, fontSize: 12, fontFamily: 'monospace')),
            const SizedBox(width: 12),
            Icon(Icons.check_circle_outline, color: colors.accentGreen, size: 16),
          ]))),
      ]));
  }
}

class _Recommendations extends StatelessWidget {
  final DnsHealth health;
  final AppColors colors;
  const _Recommendations({required this.health, required this.colors});

  @override
  Widget build(BuildContext context) {
    final recs = <Map<String, dynamic>>[];
    if (health.dmarc != DnsCheckStatus.pass) recs.add({
      'title': 'Set up DMARC policy',
      'desc': 'Add a DMARC TXT record to protect your domain from spoofing',
      'record': 'v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com',
      'severity': 'critical',
    });
    if (health.dkim != DnsCheckStatus.pass) recs.add({
      'title': 'Enable DKIM signing',
      'desc': 'Configure OpenDKIM to sign outbound messages',
      'record': 'Install and configure opendkim package',
      'severity': 'critical',
    });
    if (health.spf != DnsCheckStatus.pass) recs.add({
      'title': 'Fix SPF record',
      'desc': 'Your SPF record is missing or invalid',
      'record': 'v=spf1 a mx ~all',
      'severity': 'warning',
    });

    if (recs.isEmpty) return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.accentGreen.withOpacity(0.05), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.accentGreen.withOpacity(0.2))),
      child: Row(children: [
        Icon(Icons.verified_outlined, color: colors.accentGreen, size: 20),
        const SizedBox(width: 12),
        Text('All DNS checks passed. Your mail server configuration is optimal.',
            style: TextStyle(color: colors.accentGreen, fontSize: 13)),
      ]));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Recommendations', style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      ...recs.map((r) {
        final isCritical = r['severity'] == 'critical';
        final color = isCritical ? colors.accentRed : colors.accentOrange;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(isCritical ? Icons.error_outline : Icons.warning_amber_outlined, color: color, size: 16),
              const SizedBox(width: 8),
              Text(r['title'], style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 6),
            Text(r['desc'], style: TextStyle(color: colors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: colors.border)),
                child: Text(r['record'], style: TextStyle(color: color, fontSize: 11, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis))),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Clipboard.setData(ClipboardData(text: r['record'])),
                child: Icon(Icons.copy, color: colors.textSecondary, size: 16)),
            ]),
          ]));
      }),
    ]);
  }
}
