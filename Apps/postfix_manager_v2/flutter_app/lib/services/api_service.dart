// lib/services/api_service.dart
import 'package:dio/dio.dart';
import '../models/models.dart';

class ApiService {
  static String baseUrl = 'http://localhost:8080/api';
  late Dio _dio;
  String? _token;

  ApiService() { _init(); }

  void _init() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'}));
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (_token != null) options.headers['Authorization'] = 'Bearer $_token';
      handler.next(options);
    }));
  }

  void updateBaseUrl(String url) { baseUrl = url; _dio.options.baseUrl = url; }
  void setToken(String? token) => _token = token;

  // Auth
  Future<AuthToken> login(String u, String p) async {
    final res = await _dio.post('/auth/login', data: {'username': u, 'password': p});
    return AuthToken.fromJson(res.data);
  }
  Future<void> logout() => _dio.post('/auth/logout');

  // Server
  Future<ServerStatus> getServerStatus() async =>
      ServerStatus.fromJson((await _dio.get('/postfix/status')).data);
  Future<void> startServer() => _dio.post('/postfix/start');
  Future<void> stopServer() => _dio.post('/postfix/stop');
  Future<void> reloadServer() => _dio.post('/postfix/reload');

  // Stats
  Future<PostfixStats> getStats({String period = '24h'}) async =>
      PostfixStats.fromJson((await _dio.get('/postfix/stats', queryParameters: {'period': period})).data);

  // Queue
  Future<List<MailQueue>> getQueue({String? status, String? search, int page = 0, int size = 50}) async {
    final res = await _dio.get('/postfix/queue', queryParameters: {
      if (status != null) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page, 'size': size});
    return (res.data as List).map((e) => MailQueue.fromJson(e)).toList();
  }
  Future<void> flushQueue() => _dio.post('/postfix/queue/flush');
  Future<void> deleteQueueItem(String id) => _dio.delete('/postfix/queue/$id');
  Future<void> requeueItem(String id) => _dio.post('/postfix/queue/$id/requeue');
  Future<void> holdItem(String id) => _dio.post('/postfix/queue/$id/hold');
  Future<void> releaseItem(String id) => _dio.post('/postfix/queue/$id/release');
  Future<void> deleteSelected(List<String> ids) => _dio.post('/postfix/queue/delete-batch', data: ids);

  // Logs
  Future<List<MailLog>> getLogs({String? level, String? search, int page = 0, int size = 100}) async {
    final res = await _dio.get('/postfix/logs', queryParameters: {
      if (level != null) 'level': level,
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page, 'size': size});
    return (res.data as List).map((e) => MailLog.fromJson(e)).toList();
  }

  // Config
  Future<List<PostfixConfig>> getConfig() async =>
      ((await _dio.get('/postfix/config')).data as List).map((e) => PostfixConfig.fromJson(e)).toList();
  Future<void> updateConfig(String key, String value) =>
      _dio.put('/postfix/config/$key', data: {'value': value});
  Future<void> testConfig() => _dio.post('/postfix/config/test');
  Future<String> exportConfig() async => (await _dio.get('/postfix/config/export')).data as String;
  Future<void> importConfig(String content) =>
      _dio.post('/postfix/config/import', data: {'content': content});

  // Transport Maps
  Future<List<TransportMap>> getTransports() async =>
      ((await _dio.get('/postfix/transport')).data as List).map((e) => TransportMap.fromJson(e)).toList();
  Future<TransportMap> createTransport(TransportMap t) async =>
      TransportMap.fromJson((await _dio.post('/postfix/transport', data: t.toJson())).data);
  Future<void> deleteTransport(String pattern) => _dio.delete('/postfix/transport/$pattern');
  Future<void> reloadTransportMaps() => _dio.post('/postfix/transport/reload');

  // Access Control
  Future<List<AccessRule>> getAccessRules({String? listType}) async {
    final res = await _dio.get('/postfix/access',
        queryParameters: {if (listType != null) 'listType': listType});
    return (res.data as List).map((e) => AccessRule.fromJson(e)).toList();
  }
  Future<AccessRule> createAccessRule(AccessRule rule) async =>
      AccessRule.fromJson((await _dio.post('/postfix/access', data: rule.toJson())).data);
  Future<void> deleteAccessRule(String pattern) => _dio.delete('/postfix/access/$pattern');
  Future<void> toggleAccessRule(String pattern, bool active) =>
      _dio.patch('/postfix/access/$pattern', data: {'isActive': active});

  // TLS
  Future<List<TlsCertificate>> getCertificates() async =>
      ((await _dio.get('/postfix/tls/certificates')).data as List)
          .map((e) => TlsCertificate.fromJson(e)).toList();
  Future<void> deleteCertificate(String domain) =>
      _dio.delete('/postfix/tls/certificates/$domain');

  // DNS Health
  Future<DnsHealth> getDnsHealth(String domain) async =>
      DnsHealth.fromJson((await _dio.get('/postfix/dns/$domain')).data);
  Future<DnsHealth> recheckDns(String domain) async =>
      DnsHealth.fromJson((await _dio.post('/postfix/dns/$domain/check')).data);

  // Alerts
  Future<List<Alert>> getAlerts({bool? unreadOnly}) async {
    final res = await _dio.get('/alerts',
        queryParameters: {if (unreadOnly != null) 'unreadOnly': unreadOnly});
    return (res.data as List).map((e) => Alert.fromJson(e)).toList();
  }
  Future<void> markAlertRead(String id) => _dio.patch('/alerts/$id/read');
  Future<void> markAllAlertsRead() => _dio.post('/alerts/read-all');
  Future<void> deleteAlert(String id) => _dio.delete('/alerts/$id');

  // Backups
  Future<List<BackupEntry>> getBackups() async =>
      ((await _dio.get('/postfix/backups')).data as List).map((e) => BackupEntry.fromJson(e)).toList();
  Future<BackupEntry> createBackup(List<String> includes) async =>
      BackupEntry.fromJson((await _dio.post('/postfix/backups', data: {'includes': includes})).data);
  Future<void> restoreBackup(String id) => _dio.post('/postfix/backups/$id/restore');
  Future<void> deleteBackup(String id) => _dio.delete('/postfix/backups/$id');

  // Virtual Domains
  Future<List<VirtualDomain>> getDomains() async =>
      ((await _dio.get('/mail/domains')).data as List).map((e) => VirtualDomain.fromJson(e)).toList();
  Future<VirtualDomain> createDomain(String domain) async =>
      VirtualDomain.fromJson((await _dio.post('/mail/domains', data: {'domain': domain})).data);
  Future<void> deleteDomain(String domain) => _dio.delete('/mail/domains/$domain');
  Future<void> toggleDomain(String domain, bool active) =>
      _dio.patch('/mail/domains/$domain', data: {'isActive': active});

  // Virtual Mailboxes
  Future<List<VirtualMailbox>> getMailboxes({String? domain}) async {
    final res = await _dio.get('/mail/mailboxes',
        queryParameters: {if (domain != null) 'domain': domain});
    return (res.data as List).map((e) => VirtualMailbox.fromJson(e)).toList();
  }
  Future<VirtualMailbox> createMailbox({required String email, required String password,
    required int quotaMb, String? forwardTo}) async =>
      VirtualMailbox.fromJson((await _dio.post('/mail/mailboxes', data: {
        'email': email, 'password': password, 'quotaMb': quotaMb,
        if (forwardTo != null) 'forwardTo': forwardTo})).data);
  Future<void> deleteMailbox(String email) => _dio.delete('/mail/mailboxes/$email');
  Future<void> updateMailboxPassword(String email, String pass) =>
      _dio.patch('/mail/mailboxes/$email/password', data: {'password': pass});
  Future<void> toggleMailbox(String email, bool active) =>
      _dio.patch('/mail/mailboxes/$email', data: {'isActive': active});

  // Aliases
  Future<List<MailAlias>> getAliases({String? domain}) async {
    final res = await _dio.get('/mail/aliases',
        queryParameters: {if (domain != null) 'domain': domain});
    return (res.data as List).map((e) => MailAlias.fromJson(e)).toList();
  }
  Future<MailAlias> createAlias({required String source, required String destination, String? comment}) async =>
      MailAlias.fromJson((await _dio.post('/mail/aliases', data: {
        'source': source, 'destination': destination,
        if (comment != null) 'comment': comment})).data);
  Future<void> deleteAlias(String source) => _dio.delete('/mail/aliases/$source');
  Future<void> toggleAlias(String source, bool active) =>
      _dio.patch('/mail/aliases/$source', data: {'isActive': active});
}
