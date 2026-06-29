import 'package:adaptive_screen/adaptive_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../config/config.dart';
import '../../../utils/helper.dart';
import '../../states/settings/settings_notifier.dart';
import '../../widgets/form/textfield_widget.dart';
import '../../states/auth/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late FocusNode _passwordFocusNode;
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  String? username;
  String? password;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Add listeners for text fields
    _usernameController.addListener(_updateUsername);
    _passwordController.addListener(_updatePassword);
  }

  void _updateUsername() {
    username = _usernameController.text;
  }

  void _updatePassword() {
    password = _passwordController.text;
  }

  @override
  void dispose() {
    _usernameController.removeListener(_updateUsername);
    _passwordController.removeListener(_updatePassword);
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate network delay for UI feedback
      Future.delayed(const Duration(milliseconds: 1500), () {
        ref
            .read(authProvider.notifier)
            .signIn(
              _usernameController.text,
              _passwordController.text,
              true, // Assuming this is rememberMe, which wasn't defined in original
            );
        setState(() {
          _isLoading = false;
        });
        context.go('/');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ThemeMode isDarkMode = ref.watch(settingsProvider.notifier).currentTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDarkMode == ThemeMode.dark
                    ? [Colors.grey.shade900, Colors.black]
                    : [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Form(
          key: _formKey,
          child: AdaptiveScreen(
            phone: _buildLoginForm(context, theme),
            largeScreen: _buildLoginForm(context, theme),
            mediumScreen: _buildLoginForm(context, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, ThemeData theme) {
    return SafeArea(
      child: Center(
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildHeader(context),
                      const SizedBox(height: 32),
                      _buildUsernameField(context),
                      const SizedBox(height: 16),
                      _buildPasswordField(context),
                      _buildForgotPasswordButton(context),
                      const SizedBox(height: 24),
                      _buildSignInButton(context),
                      const SizedBox(height: 24),
                      _buildSettingsSection(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Image.asset(imageLogin, width: 80, height: 80),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.sign_in,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Welcome back! Please enter your credentials",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return TextFieldWidget(
      hint: AppLocalizations.of(context)!.email,
      inputType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        } else if (!validateEmail(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
      icon: Icons.email_outlined,
      iconColor: Theme.of(context).primaryColor,
      textController: _usernameController,
      inputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      errorText: ref.watch(authProvider).loginMessage,
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return TextFieldWidget(
      hint: AppLocalizations.of(context)!.password,
      isObscure: _isObscure,
      icon: Icons.lock_outline,
      iconColor: Theme.of(context).primaryColor,
      textController: _passwordController,
      focusNode: _passwordFocusNode,
      errorText: ref.watch(authProvider).passwordMessage,
      onEyePressed: () => setState(() => _isObscure = !_isObscure),
      isEyeOpen: !_isObscure,
      showEye: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.passwordEmpty;
        } else if (value.length < 4) {
          return AppLocalizations.of(context)!.passwordLength;
        }
        return null;
      },
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        key: const Key('user_forgot_password'),
        onPressed: () => ref.read(authProvider.notifier).forgotPassword(''),
        child: Text(
          AppLocalizations.of(context)!.forgot_password,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      key: const Key('user_sign_button'),
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child:
          _isLoading
              ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
              : Text(
                AppLocalizations.of(context)!.sign_in,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [/* _buildLanguageDropdown(),  */ _buildThemeToggle()],
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButton<Locale>(
      value: ref.watch(settingsProvider.notifier).currentLocale,
      underline: Container(height: 2, color: Theme.of(context).primaryColor),
      icon: const Icon(Icons.language),
      items:
          supportedLocales.map((Locale locale) {
            return DropdownMenuItem<Locale>(
              value: locale,
              child: Text(locale.languageCode.toUpperCase()),
            );
          }).toList(),
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          ref.read(settingsProvider.notifier).changeLocale(newLocale);
        }
      },
    );
  }

  Widget _buildThemeToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          ref.watch(settingsProvider.notifier).currentTheme == ThemeMode.dark
              ? Icons.dark_mode
              : Icons.light_mode,
          color: Theme.of(context).hintColor,
        ),
        const SizedBox(width: 8),
        /* Switch(
          value: ref.watch(settingsProvider.notifier).currentTheme =_animationController,
          onChanged: (bool value) {
            ref.read(settingsProvider.notifier).toggleTheme();
          },
        ), */
      ],
    );
  }
}
