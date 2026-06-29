// lib/models/models.dart — ENHANCED v2

enum TlsStatus { valid, expiringSoon, expired, notFound }
enum DnsCheckStatus { pass, fail, none, unknown }
enum AlertSeverity { info, warning, critical }

class MailQueue {
  final String id;
  final String sender;
  final String recipient;
  final String subject;
  final int size;
  final String status;
  final DateTime arrivedAt;
  final int deliveryAttempts;
  final String? lastError;
  final List<String>? allRecipients;
  final String? nextDelivery;

  MailQueue({required this.id, required this.sender, required this.recipient,
    required this.subject, required this.size, required this.status,
    required this.arrivedAt, required this.deliveryAttempts,
    this.lastError, this.allRecipients, this.nextDelivery});

  factory MailQueue.fromJson(Map<String, dynamic> j) => MailQueue(
    id: j['id'], sender: j['sender'], recipient: j['recipient'],
    subject: j['subject'] ?? '(no subject)', size: j['size'],
    status: j['status'], arrivedAt: DateTime.parse(j['arrivedAt']),
    deliveryAttempts: j['deliveryAttempts'], lastError: j['lastError'],
    allRecipients: j['allRecipients'] != null ? List<String>.from(j['allRecipients']) : null,
    nextDelivery: j['nextDelivery']);

  Map<String, dynamic> toJson() => {'id': id, 'sender': sender, 'recipient': recipient,
    'subject': subject, 'size': size, 'status': status,
    'arrivedAt': arrivedAt.toIso8601String(), 'deliveryAttempts': deliveryAttempts, 'lastError': lastError};
}

class MailLog {
  final String id;
  final DateTime timestamp;
  final String level;
  final String process;
  final String message;
  final String? queueId;
  final String? from;
  final String? to;
  final String? status;
  final int? delay;
  final String? host;
  final String? ip;

  MailLog({required this.id, required this.timestamp, required this.level,
    required this.process, required this.message, this.queueId, this.from,
    this.to, this.status, this.delay, this.host, this.ip});

  factory MailLog.fromJson(Map<String, dynamic> j) => MailLog(
    id: j['id'], timestamp: DateTime.parse(j['timestamp']), level: j['level'],
    process: j['process'], message: j['message'], queueId: j['queueId'],
    from: j['from'], to: j['to'], status: j['status'], delay: j['delay'],
    host: j['host'], ip: j['ip']);
}

class PostfixStats {
  final int totalMessages;
  final int deliveredMessages;
  final int bouncedMessages;
  final int deferredMessages;
  final int rejectedMessages;
  final int queueSize;
  final double avgDeliveryTime;
  final double deliveryRate;
  final Map<String, int> hourlyVolume;
  final List<TopSender> topSenders;
  final List<TopDomain> topDomains;
  final List<DeliveryDataPoint> deliveryTimeline;

  PostfixStats({required this.totalMessages, required this.deliveredMessages,
    required this.bouncedMessages, required this.deferredMessages,
    required this.rejectedMessages, required this.queueSize,
    required this.avgDeliveryTime, required this.deliveryRate,
    required this.hourlyVolume, required this.topSenders, required this.topDomains,
    required this.deliveryTimeline});

  factory PostfixStats.fromJson(Map<String, dynamic> j) => PostfixStats(
    totalMessages: j['totalMessages'], deliveredMessages: j['deliveredMessages'],
    bouncedMessages: j['bouncedMessages'], deferredMessages: j['deferredMessages'],
    rejectedMessages: j['rejectedMessages'] ?? 0, queueSize: j['queueSize'],
    avgDeliveryTime: (j['avgDeliveryTime'] as num).toDouble(),
    deliveryRate: (j['deliveryRate'] as num?)?.toDouble() ?? 0.0,
    hourlyVolume: Map<String, int>.from(j['hourlyVolume']),
    topSenders: (j['topSenders'] as List).map((e) => TopSender.fromJson(e)).toList(),
    topDomains: (j['topDomains'] as List).map((e) => TopDomain.fromJson(e)).toList(),
    deliveryTimeline: j['deliveryTimeline'] != null
        ? (j['deliveryTimeline'] as List).map((e) => DeliveryDataPoint.fromJson(e)).toList() : []);
}

class TopSender {
  final String email; final int count;
  TopSender({required this.email, required this.count});
  factory TopSender.fromJson(Map<String, dynamic> j) => TopSender(email: j['email'], count: j['count']);
}

class TopDomain {
  final String domain; final int count; final String type;
  TopDomain({required this.domain, required this.count, required this.type});
  factory TopDomain.fromJson(Map<String, dynamic> j) =>
      TopDomain(domain: j['domain'], count: j['count'], type: j['type']);
}

class DeliveryDataPoint {
  final DateTime time; final int delivered; final int deferred; final int bounced;
  DeliveryDataPoint({required this.time, required this.delivered, required this.deferred, required this.bounced});
  factory DeliveryDataPoint.fromJson(Map<String, dynamic> j) => DeliveryDataPoint(
    time: DateTime.parse(j['time']), delivered: j['delivered'],
    deferred: j['deferred'], bounced: j['bounced']);
}

class PostfixConfig {
  final String key; final String value; final String? description;
  final String category; final String? defaultValue; final bool isModified;

  PostfixConfig({required this.key, required this.value, this.description,
    required this.category, this.defaultValue, this.isModified = false});

  factory PostfixConfig.fromJson(Map<String, dynamic> j) => PostfixConfig(
    key: j['key'], value: j['value'], description: j['description'],
    category: j['category'], defaultValue: j['defaultValue'],
    isModified: j['isModified'] ?? false);

  PostfixConfig copyWith({String? value, bool? isModified}) => PostfixConfig(
    key: key, value: value ?? this.value, description: description,
    category: category, defaultValue: defaultValue, isModified: isModified ?? this.isModified);
}

class ServerStatus {
  final bool isRunning; final DateTime? startedAt; final String version;
  final int pid; final double cpuUsage; final double memoryUsage;
  final int connectionsActive; final Map<String, bool> services;

  ServerStatus({required this.isRunning, this.startedAt, required this.version,
    required this.pid, required this.cpuUsage, required this.memoryUsage,
    required this.connectionsActive, this.services = const {}});

  factory ServerStatus.fromJson(Map<String, dynamic> j) => ServerStatus(
    isRunning: j['isRunning'], startedAt: j['startedAt'] != null ? DateTime.parse(j['startedAt']) : null,
    version: j['version'], pid: j['pid'], cpuUsage: (j['cpuUsage'] as num).toDouble(),
    memoryUsage: (j['memoryUsage'] as num).toDouble(), connectionsActive: j['connectionsActive'],
    services: j['services'] != null ? Map<String, bool>.from(j['services']) : {});
}

class VirtualMailbox {
  final String email; final String domain; final String localPart;
  final bool isActive; final int quotaMb; final int usedMb;
  final DateTime createdAt; final DateTime? lastLogin; final String? forwardTo;

  VirtualMailbox({required this.email, required this.domain, required this.localPart,
    required this.isActive, required this.quotaMb, required this.usedMb,
    required this.createdAt, this.lastLogin, this.forwardTo});

  factory VirtualMailbox.fromJson(Map<String, dynamic> j) => VirtualMailbox(
    email: j['email'], domain: j['domain'], localPart: j['localPart'],
    isActive: j['isActive'], quotaMb: j['quotaMb'], usedMb: j['usedMb'],
    createdAt: DateTime.parse(j['createdAt']),
    lastLogin: j['lastLogin'] != null ? DateTime.parse(j['lastLogin']) : null,
    forwardTo: j['forwardTo']);

  double get usagePercent => quotaMb > 0 ? (usedMb / quotaMb * 100).clamp(0, 100) : 0;
}

class VirtualDomain {
  final String domain; final bool isActive; final int mailboxCount;
  final int aliasCount; final DateTime createdAt; final DnsHealth? dnsHealth;

  VirtualDomain({required this.domain, required this.isActive,
    required this.mailboxCount, required this.aliasCount,
    required this.createdAt, this.dnsHealth});

  factory VirtualDomain.fromJson(Map<String, dynamic> j) => VirtualDomain(
    domain: j['domain'], isActive: j['isActive'], mailboxCount: j['mailboxCount'],
    aliasCount: j['aliasCount'], createdAt: DateTime.parse(j['createdAt']),
    dnsHealth: j['dnsHealth'] != null ? DnsHealth.fromJson(j['dnsHealth']) : null);
}

class MailAlias {
  final String source; final String destination; final bool isActive; final String? comment;
  MailAlias({required this.source, required this.destination, required this.isActive, this.comment});
  factory MailAlias.fromJson(Map<String, dynamic> j) => MailAlias(
    source: j['source'], destination: j['destination'],
    isActive: j['isActive'], comment: j['comment']);
}

class TransportMap {
  final String pattern; final String transport; final String? nexthop;
  final bool isActive; final String? comment;

  TransportMap({required this.pattern, required this.transport,
    this.nexthop, required this.isActive, this.comment});

  factory TransportMap.fromJson(Map<String, dynamic> j) => TransportMap(
    pattern: j['pattern'], transport: j['transport'], nexthop: j['nexthop'],
    isActive: j['isActive'], comment: j['comment']);

  Map<String, dynamic> toJson() => {'pattern': pattern, 'transport': transport,
    'nexthop': nexthop, 'isActive': isActive, 'comment': comment};
}

class AccessRule {
  final String pattern; final String action; final String listType;
  final String matchType; final String? reason; final DateTime createdAt;
  final DateTime? expiresAt; final bool isActive;

  AccessRule({required this.pattern, required this.action, required this.listType,
    required this.matchType, this.reason, required this.createdAt,
    this.expiresAt, required this.isActive});

  factory AccessRule.fromJson(Map<String, dynamic> j) => AccessRule(
    pattern: j['pattern'], action: j['action'], listType: j['listType'],
    matchType: j['matchType'], reason: j['reason'],
    createdAt: DateTime.parse(j['createdAt']),
    expiresAt: j['expiresAt'] != null ? DateTime.parse(j['expiresAt']) : null,
    isActive: j['isActive']);

  Map<String, dynamic> toJson() => {'pattern': pattern, 'action': action,
    'listType': listType, 'matchType': matchType, 'reason': reason,
    'isActive': isActive, 'expiresAt': expiresAt?.toIso8601String()};
}

class TlsCertificate {
  final String domain; final String issuer; final String subject;
  final DateTime validFrom; final DateTime validUntil; final String algorithm;
  final int keyBits; final String fingerprint; final TlsStatus status;
  final String certPath; final String keyPath; final List<String> sans;

  TlsCertificate({required this.domain, required this.issuer, required this.subject,
    required this.validFrom, required this.validUntil, required this.algorithm,
    required this.keyBits, required this.fingerprint, required this.status,
    required this.certPath, required this.keyPath, required this.sans});

  factory TlsCertificate.fromJson(Map<String, dynamic> j) => TlsCertificate(
    domain: j['domain'], issuer: j['issuer'], subject: j['subject'],
    validFrom: DateTime.parse(j['validFrom']), validUntil: DateTime.parse(j['validUntil']),
    algorithm: j['algorithm'], keyBits: j['keyBits'], fingerprint: j['fingerprint'],
    status: TlsStatus.values.firstWhere((e) => e.name == j['status'], orElse: () => TlsStatus.notFound),
    certPath: j['certPath'], keyPath: j['keyPath'],
    sans: List<String>.from(j['sans'] ?? []));

  int get daysUntilExpiry => validUntil.difference(DateTime.now()).inDays;
}

class DnsHealth {
  final DnsCheckStatus spf; final DnsCheckStatus dkim; final DnsCheckStatus dmarc;
  final DnsCheckStatus mx; final DnsCheckStatus rdns;
  final String? spfRecord; final String? dmarcRecord;
  final List<MxRecord> mxRecords; final String? rdnsResult; final String? dkimSelector;

  DnsHealth({required this.spf, required this.dkim, required this.dmarc,
    required this.mx, required this.rdns, this.spfRecord, this.dmarcRecord,
    required this.mxRecords, this.rdnsResult, this.dkimSelector});

  factory DnsHealth.fromJson(Map<String, dynamic> j) => DnsHealth(
    spf: DnsCheckStatus.values.firstWhere((e) => e.name == j['spf'], orElse: () => DnsCheckStatus.unknown),
    dkim: DnsCheckStatus.values.firstWhere((e) => e.name == j['dkim'], orElse: () => DnsCheckStatus.unknown),
    dmarc: DnsCheckStatus.values.firstWhere((e) => e.name == j['dmarc'], orElse: () => DnsCheckStatus.unknown),
    mx: DnsCheckStatus.values.firstWhere((e) => e.name == j['mx'], orElse: () => DnsCheckStatus.unknown),
    rdns: DnsCheckStatus.values.firstWhere((e) => e.name == j['rdns'], orElse: () => DnsCheckStatus.unknown),
    spfRecord: j['spfRecord'], dmarcRecord: j['dmarcRecord'],
    mxRecords: (j['mxRecords'] as List? ?? []).map((e) => MxRecord.fromJson(e)).toList(),
    rdnsResult: j['rdnsResult'], dkimSelector: j['dkimSelector']);

  int get passCount => [spf, dkim, dmarc, mx, rdns].where((s) => s == DnsCheckStatus.pass).length;
  int get total => 5;
}

class MxRecord {
  final int priority; final String hostname; final String? ip;
  MxRecord({required this.priority, required this.hostname, this.ip});
  factory MxRecord.fromJson(Map<String, dynamic> j) =>
      MxRecord(priority: j['priority'], hostname: j['hostname'], ip: j['ip']);
}

class Alert {
  final String id; final String title; final String message;
  final AlertSeverity severity; final DateTime createdAt;
  final bool isRead; final String? actionLabel; final String? actionRoute;

  Alert({required this.id, required this.title, required this.message,
    required this.severity, required this.createdAt, this.isRead = false,
    this.actionLabel, this.actionRoute});

  factory Alert.fromJson(Map<String, dynamic> j) => Alert(
    id: j['id'], title: j['title'], message: j['message'],
    severity: AlertSeverity.values.firstWhere((e) => e.name == j['severity'], orElse: () => AlertSeverity.info),
    createdAt: DateTime.parse(j['createdAt']), isRead: j['isRead'] ?? false,
    actionLabel: j['actionLabel'], actionRoute: j['actionRoute']);
}

class BackupEntry {
  final String id; final String filename; final DateTime createdAt;
  final int sizeBytes; final String type; final List<String> includes;

  BackupEntry({required this.id, required this.filename, required this.createdAt,
    required this.sizeBytes, required this.type, required this.includes});

  factory BackupEntry.fromJson(Map<String, dynamic> j) => BackupEntry(
    id: j['id'], filename: j['filename'], createdAt: DateTime.parse(j['createdAt']),
    sizeBytes: j['sizeBytes'], type: j['type'],
    includes: List<String>.from(j['includes'] ?? []));

  String get sizeFormatted {
    if (sizeBytes < 1024) return '${sizeBytes}B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(sizeBytes / 1024 / 1024).toStringAsFixed(1)}MB';
  }
}

class AuthToken {
  final String token; final String refreshToken;
  final DateTime expiresAt; final String username; final String role;

  AuthToken({required this.token, required this.refreshToken,
    required this.expiresAt, required this.username, required this.role});

  factory AuthToken.fromJson(Map<String, dynamic> j) => AuthToken(
    token: j['token'], refreshToken: j['refreshToken'],
    expiresAt: DateTime.parse(j['expiresAt']),
    username: j['username'], role: j['role']);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class AppSettings {
  final String apiBaseUrl;
  final int autoRefreshSeconds;
  final bool notificationsEnabled;
  final int queueAlertThreshold;
  final int errorRateAlertThreshold;

  const AppSettings({
    this.apiBaseUrl = 'http://localhost:8080/api',
    this.autoRefreshSeconds = 30,
    this.notificationsEnabled = true,
    this.queueAlertThreshold = 100,
    this.errorRateAlertThreshold = 10,
  });

  AppSettings copyWith({String? apiBaseUrl, int? autoRefreshSeconds,
    bool? notificationsEnabled, int? queueAlertThreshold, int? errorRateAlertThreshold}) =>
    AppSettings(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      autoRefreshSeconds: autoRefreshSeconds ?? this.autoRefreshSeconds,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      queueAlertThreshold: queueAlertThreshold ?? this.queueAlertThreshold,
      errorRateAlertThreshold: errorRateAlertThreshold ?? this.errorRateAlertThreshold);

  Map<String, dynamic> toJson() => {'apiBaseUrl': apiBaseUrl,
    'autoRefreshSeconds': autoRefreshSeconds, 'notificationsEnabled': notificationsEnabled,
    'queueAlertThreshold': queueAlertThreshold, 'errorRateAlertThreshold': errorRateAlertThreshold};

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
    apiBaseUrl: j['apiBaseUrl'] ?? 'http://localhost:8080/api',
    autoRefreshSeconds: j['autoRefreshSeconds'] ?? 30,
    notificationsEnabled: j['notificationsEnabled'] ?? true,
    queueAlertThreshold: j['queueAlertThreshold'] ?? 100,
    errorRateAlertThreshold: j['errorRateAlertThreshold'] ?? 10);
}
