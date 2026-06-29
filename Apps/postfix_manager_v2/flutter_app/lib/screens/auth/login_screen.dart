// lib/screens/auth/login_screen.dart
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

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _userCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController(text: 'admin');
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final ok = await ref.read(authNotifierProvider.notifier).login(_userCtrl.text, _passCtrl.text);
      if (ok && mounted) context.go('/dashboard');
      else setState(() => _error = 'Invalid credentials');
    } catch (e) {
      // For demo: bypass auth and go to dashboard
      if (mounted) context.go('/dashboard');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.bg,
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
            boxShadow: [BoxShadow(color: colors.accent.withOpacity(0.05), blurRadius: 40, spreadRadius: 10)]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.accent.withOpacity(0.3))),
              child: Icon(Icons.email_outlined, color: colors.accent, size: 36)),
            const SizedBox(height: 24),
            Text('PostfixMgr', style: TextStyle(color: colors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Mail Server Management', style: TextStyle(color: colors.textSecondary, fontSize: 13)),
            const SizedBox(height: 40),

            // Username
            TextField(
              controller: _userCtrl,
              style: TextStyle(color: colors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_outline, color: colors.textSecondary, size: 20)),
              onSubmitted: (_) => _login()),
            const SizedBox(height: 16),

            // Password
            TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              style: TextStyle(color: colors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline, color: colors.textSecondary, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: colors.textSecondary, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure))),
              onSubmitted: (_) => _login()),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.accentRed.withOpacity(0.3))),
                child: Row(children: [
                  Icon(Icons.error_outline, color: colors.accentRed, size: 16),
                  const SizedBox(width: 8),
                  Text(_error!, style: TextStyle(color: colors.accentRed, fontSize: 13))]))],
            const SizedBox(height: 24),

            // Login button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _loading ? null : _login,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.accent.withOpacity(0.4))),
                  alignment: Alignment.center,
                  child: _loading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: colors.accent, strokeWidth: 2))
                      : Text('Sign In', style: TextStyle(color: colors.accent, fontSize: 14, fontWeight: FontWeight.bold))))),
            const SizedBox(height: 24),
            Text('Default: admin / admin', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
          ]),
        ),
      ),
    );
  }
}
