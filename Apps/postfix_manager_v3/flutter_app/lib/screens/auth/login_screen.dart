// lib/screens/auth/login_screen.dart — Real JWT auth with persistence
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../../providers/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _userCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController(text: 'admin');
  final _formKey  = GlobalKey<FormState>();
  bool _obscure   = true;
  bool _loading   = false;
  String? _error;
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    // If already authenticated, skip to dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(isAuthenticatedProvider)) {
        context.go('/dashboard');
      }
    });
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final ok = await ref.read(authNotifierProvider.notifier)
        .login(_userCtrl.text.trim(), _passCtrl.text.trim());

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      context.go('/dashboard');
    } else {
      final err = ref.read(authNotifierProvider).error;
      setState(() => _error = err?.toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('DioException [bad response]: ', '') ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(child: SizedBox(width: 420,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

            // Logo block
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.accent.withOpacity(0.3))),
              child: Icon(Icons.email_outlined, color: colors.accent, size: 36)),
            const SizedBox(height: 20),
            Text('PostfixMgr', style: TextStyle(
                color: colors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('v2.0 — Enhanced Mail Server Management',
                style: TextStyle(color: colors.textSecondary, fontSize: 12)),
            const SizedBox(height: 40),

            // Card
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colors.card, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border)),
              child: Form(key: _formKey, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text('Sign in', style: TextStyle(
                      color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Enter your credentials to access the dashboard',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 24),

                  // Username
                  _label('Username', colors),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _userCtrl,
                    style: TextStyle(color: colors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'admin',
                      prefixIcon: Icon(Icons.person_outline,
                          size: 18, color: colors.textSecondary)),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Username required' : null,
                    onFieldSubmitted: (_) => _submit()),
                  const SizedBox(height: 16),

                  // Password
                  _label('Password', colors),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    style: TextStyle(color: colors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: Icon(Icons.lock_outline,
                          size: 18, color: colors.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off_outlined
                                   : Icons.visibility_outlined,
                          size: 18, color: colors.textSecondary),
                        onPressed: () => setState(() => _obscure = !_obscure))),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Password required' : null,
                    onFieldSubmitted: (_) => _submit()),
                  const SizedBox(height: 8),

                  // Error message
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.accentRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.accentRed.withOpacity(0.3))),
                      child: Row(children: [
                        Icon(Icons.error_outline, color: colors.accentRed, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!,
                            style: TextStyle(color: colors.accentRed, fontSize: 12))),
                      ])),
                  ],

                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(width: double.infinity,
                    child: GestureDetector(
                      onTap: _loading ? null : _submit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _loading
                              ? colors.accent.withOpacity(0.5)
                              : colors.accent,
                          borderRadius: BorderRadius.circular(9)),
                        child: Center(child: _loading
                          ? SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  color: colors.bg, strokeWidth: 2))
                          : Text('Sign in', style: TextStyle(
                              color: colors.bg, fontSize: 14,
                              fontWeight: FontWeight.bold)))))),
                ]))),

            const SizedBox(height: 20),

            // Hint
            RichText(text: TextSpan(children: [
              TextSpan(text: 'Default credentials: ',
                  style: TextStyle(color: colors.textSecondary, fontSize: 11)),
              TextSpan(text: 'admin / admin',
                  style: TextStyle(color: colors.accent, fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ])),
          ])))));
  }

  Widget _label(String text, AppColors c) =>
    Text(text, style: TextStyle(color: c.textSecondary, fontSize: 12,
        fontWeight: FontWeight.w500));
}
