// lib/services/api_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  static String _baseUrl = 'http://localhost:8080/api';
  static String get baseUrl => _baseUrl;

  late Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  // Callback so providers can re-route to /login on session expiry
  void Function()? onSessionExpired;

  ApiService() { _init(); }

  void _init() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    // ── Request interceptor: attach Bearer token ───────────────────────────
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },

      // ── Response interceptor: auto-refresh on 401 ─────────────────────
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 && _refreshToken != null) {
          try {
            final newToken = await _doRefresh();
            _accessToken = newToken.token;
            _refreshToken = newToken.refreshToken;
            await _persistTokens(newToken);

            // Retry original request with new token
            final opts = e.requestOptions;
            opts.headers['Authorization'] = 'Bearer $_accessToken';
            final retried = await _dio.fetch(opts);
            handler.resolve(retried);
            return;
          } catch (_) {
            // Refresh failed — session expired
            await clearTokens();
            onSessionExpired?.call();
          }
        }
        handler.next(e);
      },
    ));
  }

  // ─── Token management ─────────────────────────────────────────────────────

  void setTokens(AuthToken t) {
    _accessToken  = t.token;
    _refreshToken = t.refreshToken;
  }

  void setToken(String? token) => _accessToken = token;

  Future<void> persistAndSetTokens(AuthToken t) async {
    setTokens(t);
    await _persistTokens(t);
  }

  Future<AuthToken?> loadPersistedTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final json  = prefs.getString('auth_token');
    if (json == null) return null;
    try {
      final t = AuthToken.fromJson(jsonDecode(json));
      if (t.isExpired) {
        // Try refresh immediately
        _refreshToken = t.refreshToken;
        final refreshed = await _doRefresh();
        await _persistTokens(refreshed);
        setTokens(refreshed);
        return refreshed;
      }
      setTokens(t);
      return t;
    } catch (_) {
      await clearTokens();
      return null;
    }
  }

  Future<void> clearTokens() async {
    _accessToken  = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> _persistTokens(AuthToken t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', jsonEncode(t.toJson()));
  }

  Future<AuthToken> _doRefresh() async {
    // Bypass interceptor to avoid infinite loop
    final dio = Dio(BaseOptions(baseUrl: _baseUrl));
    final res = await dio.post('/auth/refresh',
        data: {'refreshToken': _refreshToken});
    return AuthToken.fromJson(res.data);
  }

  void updateBaseUrl(String url) {
    _baseUrl = url;
    _dio.options.baseUrl = url;
  }

  // ─── WebSocket log stream ──────────────────────────────────────────────────

  /// Returns a WebSocketChannel connected to the live log stream.
  /// The caller is responsible for closing it.
  WebSocketChannel connectLogStream() {
    final wsBase = _baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://')
        .replaceFirst('/api', '');
    final uri = Uri.parse('$wsBase/api/logs/stream');
    return WebSocketChannel.connect(uri);
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  Future<AuthToken> login(String username, String password) async {
    final res = await _dio.post('/auth/login',
        data: {'username': username, 'password': password});
    final token = AuthToken.fromJson(res.data);
    await persistAndSetTokens(token);
    return token;
  }

  Future<void> logout() async {
    try { await _dio.post('/auth/logout',
        data: {'refreshToken': _refreshToken}); } catch (_) {}
    await clearTokens();
  }

  Future<AuthToken> refresh(String refreshToken) => _doRefresh();

  // ─── Server ───────────────────────────────────────────────────────────────

  Future<ServerStatus> getServerStatus() async =>
      ServerStatus.fromJson((await _dio.get('/postfix/status')).data);
  Future<void> startServer()  => _dio.post('/postfix/start');
  Future<void> stopServer()   => _dio.post('/postfix/stop');
  Future<void> reloadServer() => _dio.post('/postfix/reload');

  // ─── Stats ────────────────────────────────────────────────────────────────

  Future<PostfixStats> getStats({String period = '24h'}) async =>
      PostfixStats.fromJson(
          (await _dio.get('/postfix/stats', queryParameters: {'period': period})).data);

  // ─── Queue (paginated) ────────────────────────────────────────────────────

  /// Returns a [QueuePage] with items + total count from the X-Total-Count header.
  Future<QueuePage> getQueuePage({
    String? status, String? search, String? sortField,
    bool sortAsc = true, int page = 0, int size = 50,
  }) async {
    final res = await _dio.get('/postfix/queue', queryParameters: {
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty)  'search': search,
      if (sortField != null) 'sort': sortField,
      'order': sortAsc ? 'asc' : 'desc',
      'page': page, 'size': size,
    });
    final items = (res.data as List).map((e) => MailQueue.fromJson(e)).toList();
    final total = int.tryParse(
            res.headers.value('x-total-count') ?? '') ?? items.length;
    return QueuePage(items: items, total: total, page: page, pageSize: size);
  }

  Future<void> flushQueue()                      => _dio.post('/postfix/queue/flush');
  Future<void> deleteQueueItem(String id)        => _dio.delete('/postfix/queue/$id');
  Future<void> requeueItem(String id)            => _dio.post('/postfix/queue/$id/requeue');
  Future<void> holdItem(String id)               => _dio.post('/postfix/queue/$id/hold');
  Future<void> releaseItem(String id)            => _dio.post('/postfix/queue/$id/release');
  Future<void> deleteSelected(List<String> ids)  =>
      _dio.post('/postfix/queue/delete-batch', data: ids);

  // ─── Logs (REST fallback) ─────────────────────────────────────────────────

  Future<List<MailLog>> getLogs({
    String? level, String? search, int page = 0, int size = 200,
  }) async {
    final res = await _dio.get('/postfix/logs', queryParameters: {
      if (level  != null && level.isNotEmpty)  'level':  level,
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page, 'size': size,
    });
    return (res.data as List).map((e) => MailLog.fromJson(e)).toList();
  }

  // ─── Config ───────────────────────────────────────────────────────────────

  Future<List<PostfixConfig>> getConfig() async =>
      ((await _dio.get('/postfix/config')).data as List)
          .map((e) => PostfixConfig.fromJson(e)).toList();

  Future<void> updateConfig(String key, String value) =>
      _dio.put('/postfix/config/$key', data: {'value': value});

  Future<bool> testConfig() async {
    try { await _dio.post('/postfix/config/test'); return true; }
    catch (_) { return false; }
  }

  Future<String> exportConfig() async =>
      (await _dio.get('/postfix/config/export')).data as String;

  Future<void> importConfig(String content) =>
      _dio.post('/postfix/config/import', data: {'content': content});

  // ─── Transport ────────────────────────────────────────────────────────────

  Future<List<TransportMap>> getTransports() async =>
      ((await _dio.get('/postfix/transport')).data as List)
          .map((e) => TransportMap.fromJson(e)).toList();

  Future<TransportMap> createTransport(TransportMap t) async =>
      TransportMap.fromJson(
          (await _dio.post('/postfix/transport', data: t.toJson())).data);

  Future<void> deleteTransport(String pattern) =>
      _dio.delete('/postfix/transport/${Uri.encodeComponent(pattern)}');

  Future<void> reloadTransport() => _dio.post('/postfix/transport/reload');

  // ─── Access ───────────────────────────────────────────────────────────────

  Future<List<AccessRule>> getAccessRules({String? listType}) async =>
      ((await _dio.get('/postfix/access', queryParameters: {
        if (listType != null) 'listType': listType
      })).data as List).map((e) => AccessRule.fromJson(e)).toList();

  Future<AccessRule> createAccessRule(AccessRule r) async =>
      AccessRule.fromJson(
          (await _dio.post('/postfix/access', data: r.toJson())).data);

  Future<void> deleteAccessRule(String pattern) =>
      _dio.delete('/postfix/access/${Uri.encodeComponent(pattern)}');

  Future<void> toggleAccessRule(String pattern, bool active) =>
      _dio.patch('/postfix/access/${Uri.encodeComponent(pattern)}',
          data: {'isActive': active});

  // ─── TLS ──────────────────────────────────────────────────────────────────

  Future<List<TlsCertificate>> getCertificates() async =>
      ((await _dio.get('/postfix/tls/certificates')).data as List)
          .map((e) => TlsCertificate.fromJson(e)).toList();

  Future<TlsCertificate> uploadCertificate(
          String domain, String certPem, String keyPem) async =>
      TlsCertificate.fromJson((await _dio.post('/postfix/tls/certificates',
          data: {'domain': domain, 'certContent': certPem, 'keyContent': keyPem})).data);

  Future<void> deleteCertificate(String domain) =>
      _dio.delete('/postfix/tls/certificates/${Uri.encodeComponent(domain)}');

  // ─── DNS ──────────────────────────────────────────────────────────────────

  Future<DnsHealth> getDnsHealth(String domain) async =>
      DnsHealth.fromJson(
          (await _dio.get('/postfix/dns/${Uri.encodeComponent(domain)}')).data);

  Future<DnsHealth> recheckDns(String domain) async =>
      DnsHealth.fromJson(
          (await _dio.post('/postfix/dns/${Uri.encodeComponent(domain)}/check')).data);

  // ─── Alerts ───────────────────────────────────────────────────────────────

  Future<List<Alert>> getAlerts({bool unreadOnly = false}) async =>
      ((await _dio.get('/alerts', queryParameters: {'unreadOnly': unreadOnly})).data as List)
          .map((e) => Alert.fromJson(e)).toList();

  Future<void> markAlertRead(String id)  => _dio.patch('/alerts/$id/read');
  Future<void> markAllAlertsRead()       => _dio.post('/alerts/read-all');
  Future<void> deleteAlert(String id)    => _dio.delete('/alerts/$id');

  // ─── Backup ───────────────────────────────────────────────────────────────

  Future<List<BackupEntry>> getBackups() async =>
      ((await _dio.get('/postfix/backups')).data as List)
          .map((e) => BackupEntry.fromJson(e)).toList();

  Future<BackupEntry> createBackup(List<String> includes) async =>
      BackupEntry.fromJson(
          (await _dio.post('/postfix/backups', data: {'includes': includes})).data);

  Future<void> restoreBackup(String id) => _dio.post('/postfix/backups/$id/restore');
  Future<void> deleteBackup(String id)  => _dio.delete('/postfix/backups/$id');

  // ─── Domains ──────────────────────────────────────────────────────────────

  Future<List<VirtualDomain>> getDomains() async =>
      ((await _dio.get('/mail/domains')).data as List)
          .map((e) => VirtualDomain.fromJson(e)).toList();

  Future<VirtualDomain> createDomain(String domain) async =>
      VirtualDomain.fromJson(
          (await _dio.post('/mail/domains', data: {'domain': domain})).data);

  Future<void> deleteDomain(String domain) =>
      _dio.delete('/mail/domains/${Uri.encodeComponent(domain)}');

  Future<void> toggleDomain(String domain, bool active) =>
      _dio.patch('/mail/domains/${Uri.encodeComponent(domain)}',
          data: {'isActive': active});

  // ─── Mailboxes ────────────────────────────────────────────────────────────

  Future<List<VirtualMailbox>> getMailboxes({String? domain}) async =>
      ((await _dio.get('/mail/mailboxes', queryParameters: {
        if (domain != null) 'domain': domain
      })).data as List).map((e) => VirtualMailbox.fromJson(e)).toList();

  Future<VirtualMailbox> createMailbox(
          String email, String password, int quotaMb, String? forwardTo) async =>
      VirtualMailbox.fromJson((await _dio.post('/mail/mailboxes', data: {
        'email': email, 'password': password,
        'quotaMb': quotaMb, 'forwardTo': forwardTo
      })).data);

  Future<void> deleteMailbox(String email) =>
      _dio.delete('/mail/mailboxes/${Uri.encodeComponent(email)}');

  Future<void> toggleMailbox(String email, bool active) =>
      _dio.patch('/mail/mailboxes/${Uri.encodeComponent(email)}',
          data: {'isActive': active});

  Future<void> updateMailboxPassword(String email, String password) =>
      _dio.patch('/mail/mailboxes/${Uri.encodeComponent(email)}/password',
          data: {'password': password});

  Future<void> updateMailboxQuota(String email, int quotaMb) =>
      _dio.patch('/mail/mailboxes/${Uri.encodeComponent(email)}/quota',
          data: {'quotaMb': quotaMb});

  // ─── Aliases ──────────────────────────────────────────────────────────────

  Future<List<MailAlias>> getAliases({String? domain}) async =>
      ((await _dio.get('/mail/aliases', queryParameters: {
        if (domain != null) 'domain': domain
      })).data as List).map((e) => MailAlias.fromJson(e)).toList();

  Future<MailAlias> createAlias(
          String source, String destination, String? comment) async =>
      MailAlias.fromJson((await _dio.post('/mail/aliases', data: {
        'source': source, 'destination': destination, 'comment': comment
      })).data);

  Future<void> deleteAlias(String source) =>
      _dio.delete('/mail/aliases/${Uri.encodeComponent(source)}');

  Future<void> toggleAlias(String source, bool active) =>
      _dio.patch('/mail/aliases/${Uri.encodeComponent(source)}',
          data: {'isActive': active});
}

// ─── Queue pagination model ───────────────────────────────────────────────────
class QueuePage {
  final List<MailQueue> items;
  final int total;
  final int page;
  final int pageSize;

  const QueuePage({
    required this.items, required this.total,
    required this.page,  required this.pageSize,
  });

  bool get hasMore => (page + 1) * pageSize < total;
  int  get totalPages => (total / pageSize).ceil();
}
