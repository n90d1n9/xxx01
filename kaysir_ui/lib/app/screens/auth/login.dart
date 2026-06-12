import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/app/states/settings/settings_notifier.dart';
import 'package:kaysir/config/config.dart';

import '../../../config/translations/app_localizations.dart';
import '../../../utils/helper.dart';
import '../../states/auth/auth_provider.dart';
import '../../../routes/redirect_config.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/login_form_card.dart';
import 'widgets/login_settings_section.dart';
import 'widgets/login_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late FocusNode _passwordFocusNode;
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    await ref
        .read(authProvider.notifier)
        .signIn(
          _usernameController.text.trim(),
          _passwordController.text,
          _rememberMe,
        );

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go(dashboardRoute);
      return;
    }

    final message = authState.loginMessage ?? 'Unable to sign in';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleForgotPassword() async {
    final email = _usernameController.text.trim();

    if (email.isEmpty || !validateEmail(email)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Enter a valid email first.')),
        );
      return;
    }

    await ref.read(authProvider.notifier).forgotPassword(email);

    if (!mounted) return;

    final authState = ref.read(authProvider);
    final message =
        authState.hasErrorInForgotPassword
            ? authState.loginMessage ?? 'Unable to send reset email'
            : 'Password reset email requested';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: LoginShell(
          appName: appName,
          logoAsset: imageLogin,
          formPanel: LoginFormCard(
            title: localizations.sign_in,
            subtitle: 'Welcome back. Keep today\'s operations moving.',
            child: _buildLoginControls(context, settings.themeMode),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginControls(BuildContext context, ThemeMode themeMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildUsernameField(context),
        const SizedBox(height: 16),
        _buildPasswordField(context),
        _buildForgotPasswordButton(context),
        const SizedBox(height: 24),
        _buildSignInButton(context),
        const SizedBox(height: 22),
        Divider(color: Theme.of(context).colorScheme.outlineVariant),
        const SizedBox(height: 10),
        _buildSettingsSection(themeMode),
      ],
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return AuthTextField(
      label: 'Email or username',
      controller: _usernameController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      icon: Icons.alternate_email,
      errorText: ref.watch(authProvider).loginMessage,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email or username';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return AuthTextField(
      label: AppLocalizations.of(context)!.password,
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      textInputAction: TextInputAction.done,
      icon: Icons.lock_outline,
      obscureText: _isObscure,
      showVisibilityToggle: true,
      isPasswordVisible: !_isObscure,
      onVisibilityToggle: () => setState(() => _isObscure = !_isObscure),
      errorText: ref.watch(authProvider).passwordMessage,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.passwordEmpty;
        } else if (value.length < 4) {
          return AppLocalizations.of(context)!.passwordLength;
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        key: const Key('user_forgot_password'),
        onPressed:
            ref.watch(authProvider).isLoading ? null : _handleForgotPassword,
        child: Text(
          AppLocalizations.of(context)!.forgot_password,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    final authState = ref.watch(authProvider);

    return FilledButton.icon(
      key: const Key('user_sign_button'),
      onPressed: authState.isLoading ? null : _handleLogin,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon:
          authState.isLoading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.login),
      label: Text(
        authState.isLoading
            ? 'Signing in...'
            : AppLocalizations.of(context)!.sign_in,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsSection(ThemeMode themeMode) {
    final authState = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return LoginSettingsSection(
      rememberMe: _rememberMe,
      isLoading: authState.isLoading,
      locale: settings.locale,
      supportedLocales: settingsNotifier.supportedLocales,
      isDarkMode: themeMode == ThemeMode.dark,
      localeLabel: _localeLabel,
      onRememberChanged: (value) {
        setState(() => _rememberMe = value ?? true);
      },
      onLocaleChanged: (newLocale) {
        if (newLocale != null) {
          ref.read(settingsProvider.notifier).changeLocale(newLocale);
        }
      },
      onThemeToggle: () => ref.read(settingsProvider.notifier).toggleTheme(),
    );
  }

  String _localeLabel(Locale locale) {
    switch (locale.languageCode) {
      case 'id':
        return 'Bahasa Indonesia';
      case 'en':
        return 'English';
      default:
        return locale.toLanguageTag();
    }
  }
}
