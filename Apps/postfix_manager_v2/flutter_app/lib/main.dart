// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'providers/providers.dart';
import 'screens/auth/login_screen.dart';
import 'screens/postfix/dashboard_screen.dart';
import 'screens/postfix/queue_screen.dart';
import 'screens/postfix/logs_screen.dart';
import 'screens/postfix/config_screen.dart';
import 'screens/postfix/transport_screen.dart';
import 'screens/postfix/access_screen.dart';
import 'screens/postfix/tls_screen.dart';
import 'screens/postfix/dns_screen.dart';
import 'screens/postfix/backup_screen.dart';
import 'screens/mail/domains_screen.dart';
import 'screens/mail/mailboxes_screen.dart';
import 'screens/mail/aliases_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/alerts_screen.dart';

void main() {
  runApp(const ProviderScope(child: PostfixManagerApp()));
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(child: child, location: state.uri.toString()),
      routes: [
        GoRoute(path: '/dashboard', builder: (c, s) => const DashboardScreen()),
        GoRoute(path: '/queue',     builder: (c, s) => const QueueScreen()),
        GoRoute(path: '/logs',      builder: (c, s) => const LogsScreen()),
        GoRoute(path: '/config',    builder: (c, s) => const ConfigScreen()),
        GoRoute(path: '/transport', builder: (c, s) => const TransportScreen()),
        GoRoute(path: '/access',    builder: (c, s) => const AccessScreen()),
        GoRoute(path: '/tls',       builder: (c, s) => const TlsScreen()),
        GoRoute(path: '/dns',       builder: (c, s) => const DnsScreen()),
        GoRoute(path: '/backup',    builder: (c, s) => const BackupScreen()),
        GoRoute(path: '/domains',   builder: (c, s) => const DomainsScreen()),
        GoRoute(path: '/mailboxes', builder: (c, s) => const MailboxesScreen()),
        GoRoute(path: '/aliases',   builder: (c, s) => const AliasesScreen()),
        GoRoute(path: '/alerts',    builder: (c, s) => const AlertsScreen()),
        GoRoute(path: '/settings',  builder: (c, s) => const SettingsScreen()),
      ],
    ),
  ],
);

class PostfixManagerApp extends StatelessWidget {
  const PostfixManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PostfixMgr',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: _router,
    );
  }

  ThemeData _buildTheme() {
    const bg          = Color(0xFF0D1117);
    const surface     = Color(0xFF161B22);
    const card        = Color(0xFF1C2128);
    const border      = Color(0xFF30363D);
    const accent      = Color(0xFF00D9FF);
    const accentGreen = Color(0xFF3FB950);
    const accentRed   = Color(0xFFF85149);
    const accentOrange= Color(0xFFD29922);
    const accentPurple= Color(0xFF9E6FFF);
    const textPrimary = Color(0xFFE6EDF3);
    const textSecondary = Color(0xFF8B949E);

    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent, secondary: accentGreen, error: accentRed,
        surface: surface, onSurface: textPrimary),
      cardTheme: CardTheme(
        color: card, elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border))),
      textTheme: GoogleFonts.ibmPlexMonoTextTheme(base.textTheme).copyWith(
        headlineLarge:  GoogleFonts.ibmPlexMono(color: textPrimary, fontSize: 28, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.ibmPlexMono(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w600),
        titleLarge:     GoogleFonts.ibmPlexMono(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium:    GoogleFonts.ibmPlexMono(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge:      GoogleFonts.ibmPlexMono(color: textPrimary,   fontSize: 14),
        bodyMedium:     GoogleFonts.ibmPlexMono(color: textSecondary, fontSize: 13),
        bodySmall:      GoogleFonts.ibmPlexMono(color: textSecondary, fontSize: 11)),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface, elevation: 0, surfaceTintColor: Colors.transparent),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: accent, width: 1.5)),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle:  const TextStyle(color: textSecondary)),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? accent : Colors.transparent),
        side: const BorderSide(color: border)),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? accentGreen : textSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? accentGreen.withOpacity(0.3) : border)),
      extensions: const [AppColors(
        bg: bg, surface: surface, card: card, border: border,
        accent: accent, accentGreen: accentGreen, accentRed: accentRed,
        accentOrange: accentOrange, accentPurple: accentPurple,
        textPrimary: textPrimary, textSecondary: textSecondary)]);
  }
}

// ─── Theme Extension ──────────────────────────────────────────────────────────
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bg, surface, card, border;
  final Color accent, accentGreen, accentRed, accentOrange, accentPurple;
  final Color textPrimary, textSecondary;

  const AppColors({
    required this.bg, required this.surface, required this.card, required this.border,
    required this.accent, required this.accentGreen, required this.accentRed,
    required this.accentOrange, required this.accentPurple,
    required this.textPrimary, required this.textSecondary});

  @override
  AppColors copyWith({
    Color? bg, Color? surface, Color? card, Color? border,
    Color? accent, Color? accentGreen, Color? accentRed, Color? accentOrange,
    Color? accentPurple, Color? textPrimary, Color? textSecondary}) =>
    AppColors(
      bg: bg ?? this.bg, surface: surface ?? this.surface,
      card: card ?? this.card, border: border ?? this.border,
      accent: accent ?? this.accent, accentGreen: accentGreen ?? this.accentGreen,
      accentRed: accentRed ?? this.accentRed, accentOrange: accentOrange ?? this.accentOrange,
      accentPurple: accentPurple ?? this.accentPurple,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary);

  @override
  AppColors lerp(AppColors? other, double t) => this;
}

// ─── App Shell ────────────────────────────────────────────────────────────────
class AppShell extends ConsumerWidget {
  final Widget child;
  final String location;
  const AppShell({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final alertCount  = ref.watch(unreadAlertCountProvider);
    final statusAsync = ref.watch(serverStatusProvider);

    return Scaffold(
      body: Row(children: [
        _Sidebar(location: location, colors: colors,
                 alertCount: alertCount, statusAsync: statusAsync),
        Container(width: 1, color: colors.border),
        Expanded(child: child),
      ]),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String location;
  final AppColors colors;
  final int alertCount;
  final AsyncValue<dynamic> statusAsync;

  const _Sidebar({
    required this.location, required this.colors,
    required this.alertCount, required this.statusAsync});

  @override
  Widget build(BuildContext context) {
    final status = statusAsync.value;
    return Container(
      width: 230,
      color: colors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.accent.withOpacity(0.4))),
              child: Icon(Icons.email_outlined, color: colors.accent, size: 20)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PostfixMgr',
                style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
              Text('v2.0 Enhanced',
                style: TextStyle(color: colors.accent.withOpacity(0.7), fontSize: 10)),
            ]),
          ])),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _section('POSTFIX ENGINE', [
                _NavItem('/dashboard', 'Dashboard',      Icons.dashboard_outlined,    location, colors),
                _NavItem('/queue',     'Mail Queue',     Icons.queue_outlined,         location, colors),
                _NavItem('/logs',      'Live Logs',      Icons.terminal_outlined,      location, colors),
                _NavItem('/config',    'Configuration',  Icons.tune_outlined,          location, colors),
              ], colors),
              const Divider(height: 24),
              _section('DELIVERY', [
                _NavItem('/transport', 'Transport Maps', Icons.route_outlined,         location, colors),
                _NavItem('/access',    'Access Control', Icons.security_outlined,      location, colors),
                _NavItem('/tls',       'TLS / Certs',    Icons.lock_outlined,          location, colors),
                _NavItem('/dns',       'DNS Health',     Icons.dns_outlined,           location, colors),
              ], colors),
              const Divider(height: 24),
              _section('MAIL MANAGEMENT', [
                _NavItem('/domains',   'Domains',        Icons.domain_outlined,        location, colors),
                _NavItem('/mailboxes', 'Mailboxes',      Icons.inbox_outlined,         location, colors),
                _NavItem('/aliases',   'Aliases',        Icons.alt_route_outlined,     location, colors),
              ], colors),
              const Divider(height: 24),
              _section('SYSTEM', [
                _NavItem('/alerts',   'Alerts',          Icons.notifications_outlined, location, colors, badge: alertCount),
                _NavItem('/backup',   'Backup & Restore',Icons.backup_outlined,        location, colors),
                _NavItem('/settings', 'Settings',        Icons.settings_outlined,      location, colors),
              ], colors),
            ]))),
        // Footer: server status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.border))),
          child: Row(children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: status?.isRunning == true ? colors.accentGreen : colors.accentRed,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: (status?.isRunning == true
                      ? colors.accentGreen : colors.accentRed).withOpacity(0.5),
                  blurRadius: 6)])),
            const SizedBox(width: 8),
            Expanded(child: Text(
              status?.isRunning == true
                  ? 'Postfix ${status?.version ?? "Running"}'
                  : 'Postfix Stopped',
              style: TextStyle(color: colors.textSecondary, fontSize: 11),
              overflow: TextOverflow.ellipsis)),
          ])),
      ]));
  }

  Widget _section(String title, List<Widget> items, AppColors c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Text(title,
          style: TextStyle(color: c.textSecondary, fontSize: 9,
              letterSpacing: 1.5, fontWeight: FontWeight.w600))),
      ...items,
    ]);
}

class _NavItem extends StatelessWidget {
  final String path, label;
  final IconData icon;
  final String location;
  final AppColors colors;
  final int badge;

  const _NavItem(this.path, this.label, this.icon, this.location, this.colors,
      {this.badge = 0});

  @override
  Widget build(BuildContext context) {
    final active = location == path || (path != '/login' && location.startsWith(path));
    return GestureDetector(
      onTap: () => context.go(path),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color:  active ? colors.accent.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
              color: active ? colors.accent.withOpacity(0.25) : Colors.transparent)),
        child: Row(children: [
          Icon(icon, size: 16,
              color: active ? colors.accent : colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(label,
            style: TextStyle(
              color: active ? colors.accent : colors.textSecondary,
              fontSize: 12.5,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal))),
          if (badge > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: colors.accentRed, borderRadius: BorderRadius.circular(10)),
              child: Text('$badge',
                style: const TextStyle(color: Colors.white, fontSize: 10,
                    fontWeight: FontWeight.bold))),
        ])));
  }
}
