// lib/providers/providers.dart — v2.1
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';
import '../services/api_service.dart';

export '../services/api_service.dart' show apiServiceProvider;

// ─── Settings ─────────────────────────────────────────────────────────────────
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _key = 'app_settings';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final json  = prefs.getString(_key);
    if (json == null) return const AppSettings();
    try { return AppSettings.fromJson(jsonDecode(json)); }
    catch (_) { return const AppSettings(); }
  }

  Future<void> save(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(s.toJson()));
    state = AsyncData(s);
    // Update API base URL whenever settings change
    ref.read(apiServiceProvider).updateBaseUrl('${s.apiBaseUrl}/api');
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

// ─── Auth ─────────────────────────────────────────────────────────────────────
class AuthNotifier extends AsyncNotifier<AuthToken?> {
  @override
  Future<AuthToken?> build() async {
    final api = ref.read(apiServiceProvider);
    // Wire expiry callback
    api.onSessionExpired = () {
      state = const AsyncData(null);
      // Navigate to login — will be handled by router redirect
    };
    // Try to restore persisted token
    return api.loadPersistedTokens();
  }

  Future<bool> login(String username, String password) async {
    state = const AsyncLoading();
    try {
      final token = await ref.read(apiServiceProvider).login(username, password);
      state = AsyncData(token);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(apiServiceProvider).logout();
    state = const AsyncData(null);
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthToken?>(AuthNotifier.new);

final isAuthenticatedProvider = Provider<bool>((ref) {
  final token = ref.watch(authNotifierProvider).value;
  return token != null && !token.isExpired;
});

// ─── Server Status ────────────────────────────────────────────────────────────
final serverStatusProvider = FutureProvider.autoDispose<ServerStatus>((ref) =>
    ref.watch(apiServiceProvider).getServerStatus());

// ─── Stats ────────────────────────────────────────────────────────────────────
final statsPeriodProvider = StateProvider<String>((ref) => '24h');

final statsProvider = FutureProvider.autoDispose<PostfixStats>((ref) {
  final period = ref.watch(statsPeriodProvider);
  return ref.watch(apiServiceProvider).getStats(period: period);
});

// ─── Queue (paginated) ────────────────────────────────────────────────────────
final queueSearchProvider    = StateProvider<String>((ref) => '');
final queueStatusFilterProvider = StateProvider<String?>((ref) => null);
final queueSortFieldProvider = StateProvider<String?>((ref) => null);
final queueSortAscProvider   = StateProvider<bool>((ref) => true);
final selectedQueueItemsProvider = StateProvider<Set<String>>((ref) => {});

class QueueNotifier extends AsyncNotifier<List<MailQueue>> {
  int _currentPage = 0;
  int _total       = 0;
  bool _loadingMore = false;
  static const _pageSize = 50;

  @override
  Future<List<MailQueue>> build() => _fetch(reset: true);

  Future<List<MailQueue>> _fetch({bool reset = false, bool append = false}) async {
    if (reset) _currentPage = 0;

    final api    = ref.read(apiServiceProvider);
    final status = ref.read(queueStatusFilterProvider);
    final search = ref.read(queueSearchProvider);
    final sort   = ref.read(queueSortFieldProvider);
    final asc    = ref.read(queueSortAscProvider);

    final page = await api.getQueuePage(
      status: status, search: search, sortField: sort,
      sortAsc: asc, page: _currentPage, size: _pageSize);

    _total = page.total;

    if (append) {
      final existing = state.value ?? [];
      return [...existing, ...page.items];
    }
    return page.items;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(reset: true));
    ref.read(selectedQueueItemsProvider.notifier).state = {};
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.value ?? [];
    if (current.length >= _total) return;

    _loadingMore = true;
    _currentPage++;
    try {
      final next = await _fetch(append: true);
      state = AsyncData(next);
    } finally {
      _loadingMore = false;
    }
  }

  bool get hasMore => (state.value?.length ?? 0) < _total;
  int  get total   => _total;

  Future<void> flushAll() async {
    await ref.read(apiServiceProvider).flushQueue();
    await refresh();
  }

  Future<void> deleteItem(String id) async {
    await ref.read(apiServiceProvider).deleteQueueItem(id);
    state = AsyncData((state.value ?? []).where((q) => q.id != id).toList());
    _total = (_total - 1).clamp(0, 999999);
  }

  Future<void> deleteSelected(List<String> ids) async {
    await ref.read(apiServiceProvider).deleteSelected(ids);
    state = AsyncData((state.value ?? []).where((q) => !ids.contains(q.id)).toList());
    _total = (_total - ids.length).clamp(0, 999999);
    ref.read(selectedQueueItemsProvider.notifier).state = {};
  }

  Future<void> requeueItem(String id) async {
    await ref.read(apiServiceProvider).requeueItem(id);
    await refresh();
  }

  Future<void> holdItem(String id) async {
    await ref.read(apiServiceProvider).holdItem(id);
    await refresh();
  }

  Future<void> releaseItem(String id) async {
    await ref.read(apiServiceProvider).releaseItem(id);
    await refresh();
  }
}

final queueNotifierProvider =
    AsyncNotifierProvider<QueueNotifier, List<MailQueue>>(QueueNotifier.new);

// ─── Live Logs (WebSocket) ────────────────────────────────────────────────────
final logLevelFilterProvider  = StateProvider<String?>((ref) => null);
final logSearchProvider       = StateProvider<String>((ref) => '');
final logAutoScrollProvider   = StateProvider<bool>((ref) => true);
final logPausedProvider       = StateProvider<bool>((ref) => false);

/// WsConnectionState exposed to UI
final wsStateProvider = StateProvider<WsConnectionState>(
    (ref) => WsConnectionState.disconnected);

/// Live stats from the stream (lines/min, error rate)
final wsStatsProvider = StateProvider<WsLogStats?>((_) => null);

/// Ring buffer of the last 500 log lines
class LogStreamNotifier extends Notifier<List<MailLog>> {
  static const _maxLines = 500;
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  int _reconnectDelay = 2; // seconds, doubles on each failure

  @override
  List<MailLog> build() {
    ref.onDispose(_disconnect);
    return [];
  }

  void connect() {
    _disconnect();
    ref.read(wsStateProvider.notifier).state = WsConnectionState.connecting;
    try {
      _channel = ref.read(apiServiceProvider).connectLogStream();
      ref.read(wsStateProvider.notifier).state = WsConnectionState.connected;
      _reconnectDelay = 2;

      _channel!.stream.listen(
        _onMessage,
        onError: (e) { _onDisconnect(error: e.toString()); },
        onDone:  () { _onDisconnect(); },
      );

      // Push current filters to server
      _applyFilters();
    } catch (e) {
      ref.read(wsStateProvider.notifier).state = WsConnectionState.error;
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = json['type'] as String?;

      if (type == 'log') {
        final log = MailLog.fromJson(json);
        final paused = ref.read(logPausedProvider);
        if (!paused) {
          final current = List<MailLog>.from(state);
          current.add(log);
          if (current.length > _maxLines) {
            current.removeRange(0, current.length - _maxLines);
          }
          state = current;
        }
      } else if (type == 'stats') {
        ref.read(wsStatsProvider.notifier).state = WsLogStats(
          linesPerMin:  (json['linesPerMin']  as num?)?.toInt() ?? 0,
          errorsPerMin: (json['errorsPerMin'] as num?)?.toInt() ?? 0,
          errorRate:    (json['errorRate']    as num?)?.toDouble() ?? 0.0);
      }
    } catch (_) {}
  }

  void _onDisconnect({String? error}) {
    if (error != null) {
      ref.read(wsStateProvider.notifier).state = WsConnectionState.error;
    } else {
      ref.read(wsStateProvider.notifier).state = WsConnectionState.disconnected;
    }
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelay), () {
      _reconnectDelay = (_reconnectDelay * 2).clamp(2, 30);
      connect();
    });
  }

  void _disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void _applyFilters() {
    if (_channel == null) return;
    final level  = ref.read(logLevelFilterProvider);
    final search = ref.read(logSearchProvider);
    _channel!.sink.add(jsonEncode({
      'action': 'filter',
      'level':  level  ?? '',
      'search': search,
    }));
  }

  void applyFilter() => _applyFilters();

  void togglePause() {
    final paused = !ref.read(logPausedProvider);
    ref.read(logPausedProvider.notifier).state = paused;
    _channel?.sink.add(jsonEncode({'action': paused ? 'pause' : 'resume'}));
  }

  void clear() => state = [];

  void disconnect() {
    _disconnect();
    ref.read(wsStateProvider.notifier).state = WsConnectionState.disconnected;
  }
}

final logStreamProvider =
    NotifierProvider<LogStreamNotifier, List<MailLog>>(LogStreamNotifier.new);

// REST fallback for logs (used when WS not available)
final logsProvider = FutureProvider.autoDispose<List<MailLog>>((ref) {
  final level  = ref.watch(logLevelFilterProvider);
  final search = ref.watch(logSearchProvider);
  return ref.watch(apiServiceProvider).getLogs(level: level, search: search);
});

// ─── Config ───────────────────────────────────────────────────────────────────
final configSearchProvider = StateProvider<String>((ref) => '');

class ConfigNotifier extends AsyncNotifier<List<PostfixConfig>> {
  // Tracks local edits before save: key → new value
  final Map<String, String> _pendingEdits = {};

  @override
  Future<List<PostfixConfig>> build() => ref.read(apiServiceProvider).getConfig();

  List<PostfixConfig> get withPending {
    final base = state.value ?? [];
    return base.map((c) {
      final edit = _pendingEdits[c.key];
      return edit != null ? c.copyWith(value: edit, isModified: edit != c.defaultValue) : c;
    }).toList();
  }

  void stageEdit(String key, String value) {
    _pendingEdits[key] = value;
    // Trigger rebuild so UI sees pending edits
    final current = state.value ?? [];
    state = AsyncData(current.map((c) =>
        c.key == key ? c.copyWith(value: value, isModified: true) : c).toList());
  }

  int get pendingCount => _pendingEdits.length;
  bool get hasPending  => _pendingEdits.isNotEmpty;

  Future<Map<String, bool>> saveAll() async {
    final results = <String, bool>{};
    for (final entry in _pendingEdits.entries) {
      try {
        await ref.read(apiServiceProvider).updateConfig(entry.key, entry.value);
        results[entry.key] = true;
      } catch (_) {
        results[entry.key] = false;
      }
    }
    _pendingEdits.removeWhere((k, _) => results[k] == true);
    await reload();
    return results;
  }

  Future<void> saveOne(String key, String value) async {
    await ref.read(apiServiceProvider).updateConfig(key, value);
    _pendingEdits.remove(key);
    await reload();
  }

  void discardEdits() {
    _pendingEdits.clear();
    reload();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(apiServiceProvider).getConfig());
  }
}

final configNotifierProvider =
    AsyncNotifierProvider<ConfigNotifier, List<PostfixConfig>>(ConfigNotifier.new);

// ─── Transport ────────────────────────────────────────────────────────────────
final transportSearchProvider = StateProvider<String>((ref) => '');

class TransportNotifier extends AsyncNotifier<List<TransportMap>> {
  @override
  Future<List<TransportMap>> build() =>
      ref.read(apiServiceProvider).getTransports();

  Future<void> add(TransportMap t) async {
    await ref.read(apiServiceProvider).createTransport(t);
    state = await AsyncValue.guard(() => ref.read(apiServiceProvider).getTransports());
  }

  Future<void> remove(String pattern) async {
    await ref.read(apiServiceProvider).deleteTransport(pattern);
    state = AsyncData((state.value ?? []).where((t) => t.pattern != pattern).toList());
  }

  Future<void> reload() => ref.read(apiServiceProvider).reloadTransport();
}

final transportNotifierProvider =
    AsyncNotifierProvider<TransportNotifier, List<TransportMap>>(TransportNotifier.new);

// ─── Access Control ───────────────────────────────────────────────────────────
final accessSearchProvider   = StateProvider<String>((ref) => '');
final accessListTypeProvider = StateProvider<String?>((ref) => null);

class AccessNotifier extends AsyncNotifier<List<AccessRule>> {
  @override
  Future<List<AccessRule>> build() =>
      ref.read(apiServiceProvider).getAccessRules();

  Future<void> add(AccessRule r) async {
    await ref.read(apiServiceProvider).createAccessRule(r);
    state = await AsyncValue.guard(
        () => ref.read(apiServiceProvider).getAccessRules());
  }

  Future<void> remove(String pattern) async {
    await ref.read(apiServiceProvider).deleteAccessRule(pattern);
    state = AsyncData((state.value ?? []).where((r) => r.pattern != pattern).toList());
  }

  Future<void> toggle(String pattern, bool active) async {
    await ref.read(apiServiceProvider).toggleAccessRule(pattern, active);
    state = AsyncData((state.value ?? []).map((r) =>
        r.pattern == pattern ? AccessRule(
            pattern: r.pattern, action: r.action, listType: r.listType,
            matchType: r.matchType, reason: r.reason, createdAt: r.createdAt,
            expiresAt: r.expiresAt, isActive: active) : r).toList());
  }
}

final accessNotifierProvider =
    AsyncNotifierProvider<AccessNotifier, List<AccessRule>>(AccessNotifier.new);

// ─── TLS ──────────────────────────────────────────────────────────────────────
class CertificateNotifier extends AsyncNotifier<List<TlsCertificate>> {
  @override
  Future<List<TlsCertificate>> build() =>
      ref.read(apiServiceProvider).getCertificates();

  Future<void> upload(String domain, String cert, String key) async {
    await ref.read(apiServiceProvider).uploadCertificate(domain, cert, key);
    state = await AsyncValue.guard(
        () => ref.read(apiServiceProvider).getCertificates());
  }

  Future<void> remove(String domain) async {
    await ref.read(apiServiceProvider).deleteCertificate(domain);
    state = AsyncData((state.value ?? []).where((c) => c.domain != domain).toList());
  }
}

final certificateNotifierProvider =
    AsyncNotifierProvider<CertificateNotifier, List<TlsCertificate>>(CertificateNotifier.new);

// ─── DNS ──────────────────────────────────────────────────────────────────────
final dnsHealthProvider = FutureProvider.family<DnsHealth, String>((ref, domain) =>
    ref.read(apiServiceProvider).getDnsHealth(domain));

// ─── Alerts ───────────────────────────────────────────────────────────────────
class AlertsNotifier extends AsyncNotifier<List<Alert>> {
  @override
  Future<List<Alert>> build() => ref.read(apiServiceProvider).getAlerts();

  Future<void> markRead(String id) async {
    await ref.read(apiServiceProvider).markAlertRead(id);
    state = AsyncData((state.value ?? []).map((a) =>
        a.id == id ? Alert(id: a.id, title: a.title, message: a.message,
            severity: a.severity, createdAt: a.createdAt, isRead: true,
            actionLabel: a.actionLabel, actionRoute: a.actionRoute) : a).toList());
  }

  Future<void> markAllRead() async {
    await ref.read(apiServiceProvider).markAllAlertsRead();
    state = AsyncData((state.value ?? []).map((a) =>
        Alert(id: a.id, title: a.title, message: a.message,
            severity: a.severity, createdAt: a.createdAt, isRead: true,
            actionLabel: a.actionLabel, actionRoute: a.actionRoute)).toList());
  }

  Future<void> dismiss(String id) async {
    await ref.read(apiServiceProvider).deleteAlert(id);
    state = AsyncData((state.value ?? []).where((a) => a.id != id).toList());
  }
}

final alertsNotifierProvider =
    AsyncNotifierProvider<AlertsNotifier, List<Alert>>(AlertsNotifier.new);

final unreadAlertCountProvider = Provider<int>((ref) =>
    ref.watch(alertsNotifierProvider).value?.where((a) => !a.isRead).length ?? 0);

// ─── Backup ───────────────────────────────────────────────────────────────────
final backupScheduleProvider = StateProvider<String?>((ref) => null); // cron

class BackupNotifier extends AsyncNotifier<List<BackupEntry>> {
  @override
  Future<List<BackupEntry>> build() =>
      ref.read(apiServiceProvider).getBackups();

  Future<BackupEntry> create(List<String> includes) async {
    final entry = await ref.read(apiServiceProvider).createBackup(includes);
    state = AsyncData([entry, ...(state.value ?? [])]);
    return entry;
  }

  Future<void> restore(String id) =>
      ref.read(apiServiceProvider).restoreBackup(id);

  Future<void> remove(String id) async {
    await ref.read(apiServiceProvider).deleteBackup(id);
    state = AsyncData((state.value ?? []).where((b) => b.id != id).toList());
  }
}

final backupNotifierProvider =
    AsyncNotifierProvider<BackupNotifier, List<BackupEntry>>(BackupNotifier.new);

// ─── Domains ──────────────────────────────────────────────────────────────────
final domainSearchProvider = StateProvider<String>((ref) => '');

class DomainsNotifier extends AsyncNotifier<List<VirtualDomain>> {
  @override
  Future<List<VirtualDomain>> build() =>
      ref.read(apiServiceProvider).getDomains();

  Future<void> add(String domain) async {
    await ref.read(apiServiceProvider).createDomain(domain);
    state = await AsyncValue.guard(() => ref.read(apiServiceProvider).getDomains());
  }

  Future<void> remove(String domain) async {
    await ref.read(apiServiceProvider).deleteDomain(domain);
    state = AsyncData((state.value ?? []).where((d) => d.domain != domain).toList());
  }

  Future<void> toggle(String domain, bool active) async {
    await ref.read(apiServiceProvider).toggleDomain(domain, active);
    state = AsyncData((state.value ?? []).map((d) => d.domain == domain
        ? VirtualDomain(domain: d.domain, isActive: active,
            mailboxCount: d.mailboxCount, aliasCount: d.aliasCount,
            createdAt: d.createdAt) : d).toList());
  }
}

final domainsNotifierProvider =
    AsyncNotifierProvider<DomainsNotifier, List<VirtualDomain>>(DomainsNotifier.new);

// ─── Mailboxes ────────────────────────────────────────────────────────────────
final mailboxSearchProvider  = StateProvider<String>((ref) => '');
final mailboxDomainFilter    = StateProvider<String?>((ref) => null);

class MailboxNotifier extends AsyncNotifier<List<VirtualMailbox>> {
  @override
  Future<List<VirtualMailbox>> build() {
    final domain = ref.watch(mailboxDomainFilter);
    return ref.read(apiServiceProvider).getMailboxes(domain: domain);
  }

  Future<void> add(String email, String password,
      int quotaMb, String? forwardTo) async {
    await ref.read(apiServiceProvider)
        .createMailbox(email, password, quotaMb, forwardTo);
    state = await AsyncValue.guard(() => ref.read(apiServiceProvider).getMailboxes());
  }

  Future<void> remove(String email) async {
    await ref.read(apiServiceProvider).deleteMailbox(email);
    state = AsyncData(
        (state.value ?? []).where((m) => m.email != email).toList());
  }

  Future<void> toggle(String email, bool active) async {
    await ref.read(apiServiceProvider).toggleMailbox(email, active);
    state = AsyncData((state.value ?? []).map((m) => m.email == email
        ? VirtualMailbox(email: m.email, domain: m.domain, localPart: m.localPart,
            isActive: active, quotaMb: m.quotaMb, usedMb: m.usedMb,
            createdAt: m.createdAt, lastLogin: m.lastLogin, forwardTo: m.forwardTo)
        : m).toList());
  }

  Future<void> updatePassword(String email, String pw) =>
      ref.read(apiServiceProvider).updateMailboxPassword(email, pw);

  Future<void> updateQuota(String email, int mb) =>
      ref.read(apiServiceProvider).updateMailboxQuota(email, mb);
}

final mailboxNotifierProvider =
    AsyncNotifierProvider<MailboxNotifier, List<VirtualMailbox>>(MailboxNotifier.new);

// ─── Aliases ──────────────────────────────────────────────────────────────────
final aliasSearchProvider = StateProvider<String>((ref) => '');
final aliasDomainFilter   = StateProvider<String?>((ref) => null);

class AliasNotifier extends AsyncNotifier<List<MailAlias>> {
  @override
  Future<List<MailAlias>> build() {
    final domain = ref.watch(aliasDomainFilter);
    return ref.read(apiServiceProvider).getAliases(domain: domain);
  }

  Future<void> add(String source, String dest, String? comment) async {
    await ref.read(apiServiceProvider).createAlias(source, dest, comment);
    state = await AsyncValue.guard(() => ref.read(apiServiceProvider).getAliases());
  }

  Future<void> remove(String source) async {
    await ref.read(apiServiceProvider).deleteAlias(source);
    state = AsyncData(
        (state.value ?? []).where((a) => a.source != source).toList());
  }

  Future<void> toggle(String source, bool active) async {
    await ref.read(apiServiceProvider).toggleAlias(source, active);
    state = AsyncData((state.value ?? []).map((a) => a.source == source
        ? MailAlias(source: a.source, destination: a.destination,
            isActive: active, comment: a.comment) : a).toList());
  }
}

final aliasNotifierProvider =
    AsyncNotifierProvider<AliasNotifier, List<MailAlias>>(AliasNotifier.new);
