// lib/providers/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_service.dart';

// ─── Core ─────────────────────────────────────────────────────────────────────
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// ─── Settings ─────────────────────────────────────────────────────────────────
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) => SettingsNotifier());

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void update(AppSettings s) {
    state = s;
    ref.read(apiServiceProvider).updateBaseUrl(s.apiBaseUrl);
  }

  void updateField({String? apiBaseUrl, int? autoRefreshSeconds, bool? notificationsEnabled,
      int? queueAlertThreshold, int? errorRateAlertThreshold}) {
    state = state.copyWith(
      apiBaseUrl: apiBaseUrl, autoRefreshSeconds: autoRefreshSeconds,
      notificationsEnabled: notificationsEnabled, queueAlertThreshold: queueAlertThreshold,
      errorRateAlertThreshold: errorRateAlertThreshold);
  }
}

// ─── Auth ─────────────────────────────────────────────────────────────────────
final authTokenProvider = StateProvider<AuthToken?>((ref) => null);

final isAuthenticatedProvider = Provider<bool>((ref) {
  final token = ref.watch(authTokenProvider);
  return token != null && !token.isExpired;
});

class AuthNotifier extends AsyncNotifier<AuthToken?> {
  @override
  Future<AuthToken?> build() async => null;

  Future<bool> login(String username, String password) async {
    state = const AsyncLoading();
    try {
      final token = await ref.read(apiServiceProvider).login(username, password);
      ref.read(apiServiceProvider).setToken(token.token);
      ref.read(authTokenProvider.notifier).state = token;
      state = AsyncData(token);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<void> logout() async {
    try { await ref.read(apiServiceProvider).logout(); } catch (_) {}
    ref.read(apiServiceProvider).setToken(null);
    ref.read(authTokenProvider.notifier).state = null;
    state = const AsyncData(null);
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthToken?>(AuthNotifier.new);

// ─── Server Status ─────────────────────────────────────────────────────────────
final serverStatusProvider = FutureProvider.autoDispose<ServerStatus>((ref) async {
  return ref.watch(apiServiceProvider).getServerStatus();
});

// ─── Stats ─────────────────────────────────────────────────────────────────────
final statsPeriodProvider = StateProvider<String>((ref) => '24h');

final statsProvider = FutureProvider.autoDispose<PostfixStats>((ref) async {
  final period = ref.watch(statsPeriodProvider);
  return ref.watch(apiServiceProvider).getStats(period: period);
});

// ─── Alerts ────────────────────────────────────────────────────────────────────
class AlertsNotifier extends AsyncNotifier<List<Alert>> {
  @override
  Future<List<Alert>> build() async => ref.read(apiServiceProvider).getAlerts();

  Future<void> markRead(String id) async {
    await ref.read(apiServiceProvider).markAlertRead(id);
    state = AsyncData(state.value?.map((a) => a.id == id
        ? Alert(id: a.id, title: a.title, message: a.message, severity: a.severity,
            createdAt: a.createdAt, isRead: true, actionLabel: a.actionLabel, actionRoute: a.actionRoute)
        : a).toList() ?? []);
  }

  Future<void> markAllRead() async {
    await ref.read(apiServiceProvider).markAllAlertsRead();
    state = AsyncData(state.value?.map((a) =>
        Alert(id: a.id, title: a.title, message: a.message, severity: a.severity,
            createdAt: a.createdAt, isRead: true, actionLabel: a.actionLabel, actionRoute: a.actionRoute)
    ).toList() ?? []);
  }

  Future<void> delete(String id) async {
    await ref.read(apiServiceProvider).deleteAlert(id);
    state = AsyncData(state.value?.where((a) => a.id != id).toList() ?? []);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(apiServiceProvider).getAlerts());
  }
}

final alertsNotifierProvider = AsyncNotifierProvider<AlertsNotifier, List<Alert>>(AlertsNotifier.new);

final unreadAlertCountProvider = Provider<int>((ref) {
  return ref.watch(alertsNotifierProvider).value?.where((a) => !a.isRead).length ?? 0;
});

// ─── Queue ─────────────────────────────────────────────────────────────────────
final queueStatusFilterProvider = StateProvider<String?>((ref) => null);
final queueSearchProvider = StateProvider<String>((ref) => '');
final selectedQueueItemsProvider = StateProvider<Set<String>>((ref) => {});
final queueSortFieldProvider = StateProvider<String>((ref) => 'arrivedAt');
final queueSortAscProvider = StateProvider<bool>((ref) => false);

class QueueNotifier extends AsyncNotifier<List<MailQueue>> {
  @override
  Future<List<MailQueue>> build() async {
    final status = ref.watch(queueStatusFilterProvider);
    final search = ref.watch(queueSearchProvider);
    return ref.read(apiServiceProvider).getQueue(status: status, search: search);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> deleteItem(String id) async {
    await ref.read(apiServiceProvider).deleteQueueItem(id);
    state = AsyncData(state.value?.where((q) => q.id != id).toList() ?? []);
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

  Future<void> flushAll() async {
    await ref.read(apiServiceProvider).flushQueue();
    await refresh();
  }

  Future<void> deleteSelected(List<String> ids) async {
    await ref.read(apiServiceProvider).deleteSelected(ids);
    ref.read(selectedQueueItemsProvider.notifier).state = {};
    await refresh();
  }
}

final queueNotifierProvider = AsyncNotifierProvider<QueueNotifier, List<MailQueue>>(QueueNotifier.new);

// ─── Logs ──────────────────────────────────────────────────────────────────────
final logLevelFilterProvider = StateProvider<String?>((ref) => null);
final logSearchProvider = StateProvider<String>((ref) => '');

final logsProvider = FutureProvider.autoDispose<List<MailLog>>((ref) async {
  final level = ref.watch(logLevelFilterProvider);
  final search = ref.watch(logSearchProvider);
  return ref.watch(apiServiceProvider).getLogs(level: level,
      search: search.isEmpty ? null : search);
});

// ─── Config ────────────────────────────────────────────────────────────────────
class ConfigNotifier extends AsyncNotifier<List<PostfixConfig>> {
  @override
  Future<List<PostfixConfig>> build() async => ref.read(apiServiceProvider).getConfig();

  Future<void> updateConfig(String key, String value) async {
    await ref.read(apiServiceProvider).updateConfig(key, value);
    state = AsyncData(state.value?.map((c) =>
        c.key == key ? c.copyWith(value: value, isModified: true) : c).toList() ?? []);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final configNotifierProvider = AsyncNotifierProvider<ConfigNotifier, List<PostfixConfig>>(ConfigNotifier.new);
final configCategoryProvider = StateProvider<String>((ref) => 'All');
final configSearchProvider = StateProvider<String>((ref) => '');

// ─── Transport Maps ────────────────────────────────────────────────────────────
class TransportNotifier extends AsyncNotifier<List<TransportMap>> {
  @override
  Future<List<TransportMap>> build() async => ref.read(apiServiceProvider).getTransports();

  Future<void> add(TransportMap t) async {
    final created = await ref.read(apiServiceProvider).createTransport(t);
    state = AsyncData([...state.value ?? [], created]);
  }

  Future<void> delete(String pattern) async {
    await ref.read(apiServiceProvider).deleteTransport(pattern);
    state = AsyncData(state.value?.where((t) => t.pattern != pattern).toList() ?? []);
  }

  Future<void> reload() async {
    await ref.read(apiServiceProvider).reloadTransportMaps();
  }
}

final transportNotifierProvider = AsyncNotifierProvider<TransportNotifier, List<TransportMap>>(TransportNotifier.new);

// ─── Access Control ────────────────────────────────────────────────────────────
final accessListTypeFilterProvider = StateProvider<String?>((ref) => null);

class AccessNotifier extends AsyncNotifier<List<AccessRule>> {
  @override
  Future<List<AccessRule>> build() async {
    final listType = ref.watch(accessListTypeFilterProvider);
    return ref.read(apiServiceProvider).getAccessRules(listType: listType);
  }

  Future<void> add(AccessRule rule) async {
    final created = await ref.read(apiServiceProvider).createAccessRule(rule);
    state = AsyncData([...state.value ?? [], created]);
  }

  Future<void> delete(String pattern) async {
    await ref.read(apiServiceProvider).deleteAccessRule(pattern);
    state = AsyncData(state.value?.where((r) => r.pattern != pattern).toList() ?? []);
  }

  Future<void> toggle(String pattern, bool active) async {
    await ref.read(apiServiceProvider).toggleAccessRule(pattern, active);
    state = AsyncData(state.value?.map((r) => r.pattern == pattern
        ? AccessRule(pattern: r.pattern, action: r.action, listType: r.listType,
            matchType: r.matchType, reason: r.reason, createdAt: r.createdAt,
            expiresAt: r.expiresAt, isActive: active)
        : r).toList() ?? []);
  }
}

final accessNotifierProvider = AsyncNotifierProvider<AccessNotifier, List<AccessRule>>(AccessNotifier.new);

// ─── TLS Certificates ──────────────────────────────────────────────────────────
class CertificateNotifier extends AsyncNotifier<List<TlsCertificate>> {
  @override
  Future<List<TlsCertificate>> build() async => ref.read(apiServiceProvider).getCertificates();

  Future<void> delete(String domain) async {
    await ref.read(apiServiceProvider).deleteCertificate(domain);
    state = AsyncData(state.value?.where((c) => c.domain != domain).toList() ?? []);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final certificateNotifierProvider = AsyncNotifierProvider<CertificateNotifier, List<TlsCertificate>>(CertificateNotifier.new);

// ─── DNS Health ────────────────────────────────────────────────────────────────
final selectedDnsdomainProvider = StateProvider<String>((ref) => '');

final dnsHealthProvider = FutureProvider.autoDispose.family<DnsHealth, String>((ref, domain) async {
  if (domain.isEmpty) throw Exception('No domain selected');
  return ref.watch(apiServiceProvider).getDnsHealth(domain);
});

// ─── Backups ───────────────────────────────────────────────────────────────────
class BackupNotifier extends AsyncNotifier<List<BackupEntry>> {
  @override
  Future<List<BackupEntry>> build() async => ref.read(apiServiceProvider).getBackups();

  Future<void> create(List<String> includes) async {
    state = const AsyncLoading();
    try {
      final backup = await ref.read(apiServiceProvider).createBackup(includes);
      state = AsyncData([backup, ...state.value ?? []]);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> delete(String id) async {
    await ref.read(apiServiceProvider).deleteBackup(id);
    state = AsyncData(state.value?.where((b) => b.id != id).toList() ?? []);
  }

  Future<void> restore(String id) async {
    await ref.read(apiServiceProvider).restoreBackup(id);
  }
}

final backupNotifierProvider = AsyncNotifierProvider<BackupNotifier, List<BackupEntry>>(BackupNotifier.new);

// ─── Domains ───────────────────────────────────────────────────────────────────
class DomainsNotifier extends AsyncNotifier<List<VirtualDomain>> {
  @override
  Future<List<VirtualDomain>> build() async => ref.read(apiServiceProvider).getDomains();

  Future<void> addDomain(String domain) async {
    final newDomain = await ref.read(apiServiceProvider).createDomain(domain);
    state = AsyncData([...state.value ?? [], newDomain]);
  }

  Future<void> deleteDomain(String domain) async {
    await ref.read(apiServiceProvider).deleteDomain(domain);
    state = AsyncData(state.value?.where((d) => d.domain != domain).toList() ?? []);
  }

  Future<void> toggleDomain(String domain, bool active) async {
    await ref.read(apiServiceProvider).toggleDomain(domain, active);
    state = AsyncData(state.value?.map((d) => d.domain == domain
        ? VirtualDomain(domain: d.domain, isActive: active, mailboxCount: d.mailboxCount,
            aliasCount: d.aliasCount, createdAt: d.createdAt, dnsHealth: d.dnsHealth)
        : d).toList() ?? []);
  }
}

final domainsNotifierProvider = AsyncNotifierProvider<DomainsNotifier, List<VirtualDomain>>(DomainsNotifier.new);

// ─── Mailboxes ─────────────────────────────────────────────────────────────────
final selectedDomainProvider = StateProvider<String?>((ref) => null);

class MailboxNotifier extends AsyncNotifier<List<VirtualMailbox>> {
  @override
  Future<List<VirtualMailbox>> build() async {
    final domain = ref.watch(selectedDomainProvider);
    return ref.read(apiServiceProvider).getMailboxes(domain: domain);
  }

  Future<void> addMailbox({required String email, required String password,
      required int quotaMb, String? forwardTo}) async {
    final box = await ref.read(apiServiceProvider).createMailbox(
        email: email, password: password, quotaMb: quotaMb, forwardTo: forwardTo);
    state = AsyncData([...state.value ?? [], box]);
  }

  Future<void> deleteMailbox(String email) async {
    await ref.read(apiServiceProvider).deleteMailbox(email);
    state = AsyncData(state.value?.where((m) => m.email != email).toList() ?? []);
  }

  Future<void> toggleMailbox(String email, bool active) async {
    await ref.read(apiServiceProvider).toggleMailbox(email, active);
    state = AsyncData(state.value?.map((m) => m.email == email
        ? VirtualMailbox(email: m.email, domain: m.domain, localPart: m.localPart,
            isActive: active, quotaMb: m.quotaMb, usedMb: m.usedMb,
            createdAt: m.createdAt, lastLogin: m.lastLogin)
        : m).toList() ?? []);
  }
}

final mailboxNotifierProvider = AsyncNotifierProvider<MailboxNotifier, List<VirtualMailbox>>(MailboxNotifier.new);

// ─── Aliases ───────────────────────────────────────────────────────────────────
class AliasNotifier extends AsyncNotifier<List<MailAlias>> {
  @override
  Future<List<MailAlias>> build() async {
    final domain = ref.watch(selectedDomainProvider);
    return ref.read(apiServiceProvider).getAliases(domain: domain);
  }

  Future<void> addAlias({required String source, required String destination, String? comment}) async {
    final alias = await ref.read(apiServiceProvider).createAlias(
        source: source, destination: destination, comment: comment);
    state = AsyncData([...state.value ?? [], alias]);
  }

  Future<void> deleteAlias(String source) async {
    await ref.read(apiServiceProvider).deleteAlias(source);
    state = AsyncData(state.value?.where((a) => a.source != source).toList() ?? []);
  }

  Future<void> toggleAlias(String source, bool active) async {
    await ref.read(apiServiceProvider).toggleAlias(source, active);
    state = AsyncData(state.value?.map((a) => a.source == source
        ? MailAlias(source: a.source, destination: a.destination,
            isActive: active, comment: a.comment)
        : a).toList() ?? []);
  }
}

final aliasNotifierProvider = AsyncNotifierProvider<AliasNotifier, List<MailAlias>>(AliasNotifier.new);
