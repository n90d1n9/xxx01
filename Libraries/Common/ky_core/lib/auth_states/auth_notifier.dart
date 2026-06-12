import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config_provider.dart';
import '../rest/rest_provider.dart';
import '../rest/rest_services.dart';
import '../core/persistent/secure_storage.dart/secure_storage_provider.dart';

import 'auth_state.dart';
import 'user.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthenticationState>((
  ref,
) {
  return AuthNotifier(ref);
});

// Update the AuthNotifier with additional methods
class AuthNotifier extends StateNotifier<AuthenticationState> {
  final Ref _ref;
  RestClientService get _restClient => _ref.read(restClientProvider);
  static const String _communityUidKey = 'miku.community.uid';
  static const String _communityEmailKey = 'miku.community.email';
  static const String _communityDisplayNameKey = 'miku.community.display_name';
  static const String _communityPhotoUrlKey = 'miku.community.photo_url';
  static const String _communityIdTokenKey = 'miku.community.id_token';
  static const String _communityAccessTokenKey = 'miku.community.access_token';
  static const String _backendUserKey = 'miku.backend.user';
  static const String _rememberedSessionKey = 'miku.remembered.session';
  static const String _rememberMePrefKey = 'miku.auth.remember_me';

  static const String _googleClientId = String.fromEnvironment(
    'MIKU_GOOGLE_CLIENT_ID',
    defaultValue:
        '483733451053-28afqa0qf1k6ac17jkr0kulocnbhtph6.apps.googleusercontent.com',
  );
  static const bool _allowNativeGoogleSignIn = bool.fromEnvironment(
    'MIKU_ENABLE_GOOGLE_SIGN_IN',
    defaultValue: false,
  );
  static const bool _useAuthBackend = bool.fromEnvironment(
    'MIKU_USE_AUTH_BACKEND',
    defaultValue: false,
  );
  static const String _githubClientId = String.fromEnvironment(
    'MIKU_GITHUB_CLIENT_ID',
    defaultValue: '',
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  GoogleSignIn? _googleSignIn;
  bool _githubDeviceFlowCancelled = false;

  Future<void> _initGoogleSignIn() async {
    if (_googleSignIn != null) return;

    // Skip native Google Sign-In on desktop platforms (macOS, Windows, Linux)
    // These platforms don't support native URL scheme callbacks for OAuth
    if (_isDesktop) {
      debugPrint(
        '[GoogleSignIn] Skipping native initialization on desktop platform',
      );
      return;
    }

    GoogleSignIn.instance.initialize(
      clientId: _googleClientId.isEmpty ? null : _googleClientId,
    );
    _googleSignIn = GoogleSignIn.instance;
  }

  bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  AuthNotifier(this._ref) : super(AuthenticationState.initial()) {
    _init();
  }

  Future<void> _init() async {
    _ensureRestClientInitialized();

    //final prefs = await SharedPreferences.getInstance();
    //final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    //final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

    final isFirstTime = true;
    final rememberMe = await _loadRememberMePreference();
    final restoredSession = rememberMe
        ? await _restoreRememberedSession() ??
              await _restoreBackendSession() ??
              await _restoreFirebaseSession() ??
              await _restoreCommunitySession()
        : null;
    final isAuthenticated = restoredSession != null;

    state = state.copyWith(
      isFirstTime: isFirstTime,
      isAuthenticated: isAuthenticated,
      isLoading: false,
      rememberMe: rememberMe,
      loggedIn: isAuthenticated,
      user: restoredSession?.user,
      username: restoredSession?.user.username,
      token: restoredSession?.idToken,
      firebaseUid: restoredSession?.firebaseUid,
    );
  }

  Future<void> setFirstTimeCompleted() async {
    //final prefs = await SharedPreferences.getInstance();
    //await prefs.setBool('isFirstTime', false);
    state = state.copyWith(isFirstTime: false);
  }

  Future<void> signOut() async {
    await logout();
  }

  void cancelGithubSignIn() {
    _githubDeviceFlowCancelled = true;
    state = state.copyWith(
      isLoading: false,
      hasErrorsInLogin: true,
      loginMessage: 'GitHub sign-in cancelled',
      pendingAuthProvider: '',
      authVerificationUri: '',
      authUserCode: '',
    );
  }

  Future<void> signIn(String username, String password) async {
    try {
      _ensureRestClientInitialized();
      state = state.copyWith(
        isLoading: true,
        hasErrorsInLogin: false,
        loginMessage: null,
      );

      //final dio = _ref.read(dioProvider);
      final response = await _restClient.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        await _storage.write(
          key: _ref.watch(appConfigProvider).securityConfig.tokenKey,
          value: response.data['token'],
        );
        await _storage.write(
          key: _ref.watch(appConfigProvider).securityConfig.refreshTokenKey,
          value: response.data['refresh_token'],
        );

        final user = User.fromMap(response.data['user']);
        await _persistBackendSession(user);
        await _persistRememberedSessionIfEnabled(
          user: user,
          token: response.data['token']?.toString(),
          firebaseUid: null,
        );
        // await _dbHelper.insertUser(user);

        state = state.copyWith(
          user: user,
          loggedIn: true,
          isLoading: false,
          hasErrorsInLogin: false,
          loginMessage: null,
        );

        state = state.copyWith(
          isAuthenticated: true,
          token: response.data['token']?.toString(),
        );
        //final prefs = await SharedPreferences.getInstance();
        //await prefs.setBool('isAuthenticated', true);
      } else {
        state = state.copyWith(
          isLoading: false,
          hasErrorsInLogin: true,
          loginMessage: 'Invalid credentials',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasErrorsInLogin: true,
        loginMessage: 'Invalid credentials',
      );
    }
  }

  Future<void> signInWithGithub() async {
    try {
      _ensureRestClientInitialized();
      state = state.copyWith(
        isLoading: true,
        hasErrorsInLogin: false,
        loginMessage: null,
      );

      // Current firebase_auth macOS implementation does not support
      // signInWithProvider/signInWithPopup for GitHub.
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
        if (_githubClientId.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            hasErrorsInLogin: true,
            loginMessage:
                'GitHub Sign-In on macOS requires --dart-define=MIKU_GITHUB_CLIENT_ID=<github-oauth-client-id>.',
          );
          return;
        }

        final githubAccessToken = await _runGithubDeviceFlow(_githubClientId);
        if (githubAccessToken == null || githubAccessToken.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            hasErrorsInLogin: true,
            loginMessage:
                'GitHub authorization was not completed. Please try again.',
          );
          return;
        }

        final credential = fb_auth.GithubAuthProvider.credential(
          githubAccessToken,
        );
        final userCredential = await fb_auth.FirebaseAuth.instance
            .signInWithCredential(credential);
        final firebaseUser =
            userCredential.user ?? fb_auth.FirebaseAuth.instance.currentUser;
        await _completeGithubSignIn(firebaseUser);
        return;
      }

      final auth = fb_auth.FirebaseAuth.instance;
      _githubDeviceFlowCancelled = false;
      final credential = await _signInWithGithubProvider(auth);
      final firebaseUser = credential?.user ?? await _waitForFirebaseUser(auth);
      await _completeGithubSignIn(firebaseUser);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasErrorsInLogin: true,
        loginMessage: 'GitHub Sign-In failed: $e',
      );
    }
  }

  Future<void> _completeGithubSignIn(fb_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      state = state.copyWith(
        isLoading: false,
        hasErrorsInLogin: true,
        loginMessage:
            'GitHub Sign-In failed: user not found on ${defaultTargetPlatform.name}. '
            'Check Firebase GitHub provider setup and callback URL.',
      );
      return;
    }

    final idToken = await firebaseUser.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        hasErrorsInLogin: true,
        loginMessage: 'GitHub Sign-In failed: token not found.',
      );
      return;
    }

    final email = firebaseUser.email ?? 'github-user@miku.local';
    final displayName = firebaseUser.displayName ?? email;
    final photoUrl = firebaseUser.photoURL;

    await _trackFirebaseLogin(
      uid: firebaseUser.uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      provider: 'github',
    );

    await _persistCommunitySession(
      firebaseUid: firebaseUser.uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      idToken: idToken,
      accessToken: null,
    );

    final user = User(
      id: 0,
      login: email,
      username: displayName,
      firstName: displayName,
      email: email,
      imageUrl: photoUrl,
    );
    await _persistRememberedSessionIfEnabled(
      user: user,
      token: idToken,
      firebaseUid: firebaseUser.uid,
    );

    state = state.copyWith(
      user: user,
      username: user.username,
      loggedIn: true,
      isAuthenticated: true,
      isLoading: false,
      hasErrorsInLogin: false,
      loginMessage: 'Signed in with GitHub',
      token: idToken,
      firebaseUid: firebaseUser.uid,
      pendingAuthProvider: '',
      authVerificationUri: '',
      authUserCode: '',
    );
  }

  Future<String?> _runGithubDeviceFlow(String clientId) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    );

    final deviceResponse = await dio.post(
      'https://github.com/login/device/code',
      data: {'client_id': clientId, 'scope': 'read:user user:email'},
    );
    final deviceData = Map<String, dynamic>.from(
      deviceResponse.data as Map<dynamic, dynamic>,
    );
    final deviceCode = deviceData['device_code']?.toString();
    final verificationUri = deviceData['verification_uri']?.toString();
    final userCode = deviceData['user_code']?.toString();
    final interval =
        int.tryParse(deviceData['interval']?.toString() ?? '5') ?? 5;
    final expiresIn =
        int.tryParse(deviceData['expires_in']?.toString() ?? '900') ?? 900;

    if (deviceCode == null || verificationUri == null || userCode == null) {
      throw Exception('GitHub device flow initialization failed');
    }

    state = state.copyWith(
      isLoading: true,
      hasErrorsInLogin: false,
      loginMessage:
          'Open $verificationUri and enter code $userCode to continue GitHub sign-in.',
      pendingAuthProvider: 'github',
      authVerificationUri: verificationUri,
      authUserCode: userCode,
    );

    final uri = Uri.parse(verificationUri);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      state = state.copyWith(
        loginMessage:
            'Open $verificationUri and enter code $userCode to continue.',
      );
    }

    final startedAt = DateTime.now();
    var pollingInterval = interval;

    while (DateTime.now().difference(startedAt).inSeconds < expiresIn) {
      if (_githubDeviceFlowCancelled) {
        return null;
      }
      await Future.delayed(Duration(seconds: pollingInterval));

      final tokenResponse = await dio.post(
        'https://github.com/login/oauth/access_token',
        data: {
          'client_id': clientId,
          'device_code': deviceCode,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        },
      );

      final tokenData = Map<String, dynamic>.from(
        tokenResponse.data as Map<dynamic, dynamic>,
      );

      final accessToken = tokenData['access_token']?.toString();
      if (accessToken != null && accessToken.isNotEmpty) {
        return accessToken;
      }

      final error = tokenData['error']?.toString() ?? '';
      if (error == 'authorization_pending') {
        continue;
      }
      if (error == 'slow_down') {
        pollingInterval += 5;
        continue;
      }
      if (error == 'expired_token') {
        return null;
      }
      throw Exception('GitHub device flow error: $error');
    }

    return null;
  }

  Future<fb_auth.UserCredential?> _signInWithGithubProvider(
    fb_auth.FirebaseAuth auth,
  ) async {
    if (kIsWeb) {
      final provider = fb_auth.GithubAuthProvider()
        ..addScope('read:user')
        ..addScope('user:email');
      return auth.signInWithPopup(provider);
    }

    fb_auth.UserCredential? credential;

    try {
      final provider = fb_auth.OAuthProvider('github.com')
        ..addScope('read:user')
        ..addScope('user:email');
      credential = await auth.signInWithProvider(provider);
      if (credential.user != null) {
        return credential;
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code != 'null-error' &&
          !(e.message?.contains('return null') ?? false)) {
        rethrow;
      }
    }

    try {
      final fallbackProvider = fb_auth.GithubAuthProvider()
        ..addScope('read:user')
        ..addScope('user:email');
      final fallbackCredential = await auth.signInWithProvider(
        fallbackProvider,
      );
      if (fallbackCredential.user != null) {
        return fallbackCredential;
      }
      return credential ?? fallbackCredential;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'null-error' ||
          (e.message?.contains('return null') ?? false)) {
        return credential;
      }
      rethrow;
    }
  }

  Future<fb_auth.User?> _waitForFirebaseUser(fb_auth.FirebaseAuth auth) async {
    final existing = auth.currentUser;
    if (existing != null) {
      return existing;
    }

    try {
      return await auth
          .authStateChanges()
          .firstWhere((user) => user != null)
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      return auth.currentUser;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _ensureRestClientInitialized();
      final isApplePlatform =
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.iOS;

      // For desktop platforms (macOS, Windows, Linux), use fallback auth
      if (_isDesktop) {
        debugPrint('[GoogleSignIn] Using desktop fallback authentication');
        state = state.copyWith(isLoading: true);

        // Simulate successful login for desktop testing/development
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          loginMessage: 'Desktop mode: Signed in with fallback authentication',
          username: 'Desktop User',
          email: 'user@desktop.local',
        );
        return;
      }

      if (isApplePlatform &&
          !_allowNativeGoogleSignIn &&
          _googleClientId.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          hasErrorsInLogin: true,
          loginMessage:
              'Google Sign-In is not configured for Apple platform. '
              'Set -DMIKU_ENABLE_GOOGLE_SIGN_IN=true and configure '
              'GID_CLIENT_ID / GID_REVERSED_CLIENT_ID in macOS/iOS runner config '
              'or pass --dart-define=MIKU_GOOGLE_CLIENT_ID=<client-id>.',
        );
        return;
      }

      state = state.copyWith(isLoading: true);

      // Initialize Google Sign In if not already done
      await _initGoogleSignIn();

      final googleUser = await _googleSignIn!.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      // In v7.x, accessToken requires explicit authorization
      String? accessToken;
      try {
        final authz = await googleUser.authorizationClient.authorizeScopes([
          'email',
          'profile',
        ]);
        accessToken = authz.accessToken;
      } catch (_) {
        // Authorization failed, but we can still try with just idToken
      }

      if (idToken != null) {
        final tracking = await _signInFirebaseAndTrackUsage(
          idToken: idToken,
          accessToken: accessToken,
          googleUser: googleUser,
        );

        try {
          await _persistCommunitySession(
            firebaseUid: tracking.firebaseUid,
            email: googleUser.email,
            displayName: googleUser.displayName ?? googleUser.email,
            photoUrl: googleUser.photoUrl,
            idToken: idToken,
            accessToken: accessToken,
          );
        } catch (e) {
          debugPrint('Community session persistence failed: $e');
        }

        if (!_useAuthBackend) {
          _completeLocalGoogleSignIn(
            googleUser,
            tracking.loginMessage,
            idToken: idToken,
            firebaseUid: tracking.firebaseUid,
          );
          return;
        }

        try {
          // Optional backend token exchange (enterprise/cloud mode).
          final response = await _restClient.post(
            '/auth/google',
            data: {'id_token': idToken},
          );

          if (response.statusCode == 200) {
            await _storage.write(
              key: _ref.watch(appConfigProvider).securityConfig.tokenKey,
              value: response.data['token'],
            );
            await _storage.write(
              key: _ref.watch(appConfigProvider).securityConfig.refreshTokenKey,
              value: response.data['refresh_token'],
            );

            final user = User.fromMap(response.data['user']);
            await _persistBackendSession(user);
            await _persistRememberedSessionIfEnabled(
              user: user,
              token: response.data['token']?.toString() ?? idToken,
              firebaseUid: tracking.firebaseUid,
            );
            state = state.copyWith(
              user: user,
              loggedIn: true,
              isAuthenticated: true,
              isLoading: false,
              token: idToken,
              firebaseUid: tracking.firebaseUid,
            );
          } else {
            _completeLocalGoogleSignIn(
              googleUser,
              'Signed in locally (auth backend unavailable)',
              idToken: idToken,
              firebaseUid: tracking.firebaseUid,
            );
          }
        } on DioException catch (e) {
          if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            _completeLocalGoogleSignIn(
              googleUser,
              'Signed in locally (auth service offline)',
              idToken: idToken,
              firebaseUid: tracking.firebaseUid,
            );
          } else {
            state = state.copyWith(
              isLoading: false,
              hasErrorsInLogin: true,
              loginMessage: 'Google Sign-In backend error: ${e.message}',
            );
          }
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          hasErrorsInLogin: true,
          loginMessage: 'Google ID Token is null',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasErrorsInLogin: true,
        loginMessage: 'Google Sign-In failed: $e',
      );
    }
  }

  void updateUsername(String username) {
    state = state.copyWith(
      username: username,
      loginMessage: null,
      hasErrorsInLogin: false,
    );
  }

  void updatePassword(String password) {
    state = state.copyWith(
      password: password,
      passwordMessage: null,
      hasErrorsInLogin: false,
    );
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordMessage: null,
    );
  }

  void toggleRememberMe() {
    final newValue = !state.rememberMe;
    state = state.copyWith(rememberMe: newValue);
    _saveRememberMePreference(newValue);

    if (!newValue) {
      _clearRememberedSession();
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      _ensureRestClientInitialized();
      state = state.copyWith(
        isLoading: true,
        hasErrorInForgotPassword: false,
        loginMessage: null,
      );

      final response = await _postWithFallback(
        paths: const [
          '/account/reset-password/init',
          '/api/account/reset-password/init',
          '/auth/forgot-password',
          '/api/auth/forgot-password',
        ],
        data: {'email': email},
      );

      final success =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202 ||
          response.statusCode == 204;

      if (!success) {
        state = state.copyWith(
          isLoading: false,
          hasErrorInForgotPassword: true,
          loginMessage: 'Error resetting password',
        );
        return false;
      }

      state = state.copyWith(
        isLoading: false,
        hasErrorInForgotPassword: false,
        loginMessage: 'Password reset email sent',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasErrorInForgotPassword: true,
        loginMessage: 'Error resetting password',
      );
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      _ensureRestClientInitialized();
      state = state.copyWith(
        isLoading: true,
        hasErrorsInLogin: false,
        loginMessage: null,
      );

      final response = await _postWithFallback(
        paths: const ['/register', '/api/register', '/auth/register'],
        data: {'username': username, 'email': email, 'password': password},
      );

      if (response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          hasErrorsInLogin: false,
          loginMessage: 'Account created successfully. Please sign in.',
        );
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        hasErrorsInLogin: true,
        loginMessage: 'Registration failed',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasErrorsInLogin: true,
        loginMessage: 'Error during registration',
      );
      return false;
    }
  }

  Future<void> checkAuth() async {
    try {
      _ensureRestClientInitialized();
      final token = await _ref
          .read(secureStorageProvider)
          .read(key: _ref.watch(appConfigProvider).securityConfig.tokenKey);
      if (token != null) {
        final response = await _restClient.get('/account');
        if (response.statusCode == 200) {
          final user = User.fromMap(response.data);
          state = state.copyWith(user: user, loggedIn: true, token: token);
        }
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    // Clear local auth state first so UI/redirect updates immediately.
    state = AuthenticationState.initial().copyWith(isLoading: false);

    try {
      await _googleSignIn?.signOut();
    } catch (_) {
      // Ignore Google sign-out failures so local logout can still complete.
    }

    try {
      await fb_auth.FirebaseAuth.instance.signOut();
    } catch (_) {
      // Ignore Firebase sign-out failures so local logout can still complete.
    }

    // Clear token/session keys best-effort; do not fail logout if storage has issues.
    try {
      final securityConfig = _ref.read(appConfigProvider).securityConfig;
      final tokenKey = securityConfig.tokenKey;
      final refreshTokenKey = securityConfig.refreshTokenKey;
      if (tokenKey.isNotEmpty) {
        await _storage.delete(key: tokenKey);
      }
      if (refreshTokenKey.isNotEmpty) {
        await _storage.delete(key: refreshTokenKey);
      }

      await _storage.delete(key: _backendUserKey);
      await _storage.delete(key: _communityUidKey);
      await _storage.delete(key: _communityEmailKey);
      await _storage.delete(key: _communityDisplayNameKey);
      await _storage.delete(key: _communityPhotoUrlKey);
      await _storage.delete(key: _communityIdTokenKey);
      await _storage.delete(key: _communityAccessTokenKey);
    } catch (_) {
      // Ignore keychain/storage failures. Local auth state is already reset.
    }

    try {
      await _ref.read(secureStorageProvider).deleteAll();
    } catch (_) {
      // Ignore deleteAll failures.
    }

    try {
      await _clearRememberedSession();
    } catch (_) {
      // Ignore preferences failures.
    }
  }

  void _completeLocalGoogleSignIn(
    GoogleSignInAccount googleUser,
    String loginMessage, {
    required String idToken,
    String? firebaseUid,
  }) {
    final user = User(
      id: 0,
      login: googleUser.email,
      username: googleUser.displayName ?? googleUser.email,
      firstName: googleUser.displayName,
      email: googleUser.email,
      imageUrl: googleUser.photoUrl,
    );

    state = state.copyWith(
      user: user,
      username: user.username,
      loggedIn: true,
      isAuthenticated: true,
      isLoading: false,
      hasErrorsInLogin: false,
      loginMessage: loginMessage,
      token: idToken,
      firebaseUid: firebaseUid,
    );
    _persistRememberedSessionIfEnabled(
      user: user,
      token: idToken,
      firebaseUid: firebaseUid,
    );
  }

  Future<_TrackingResult> _signInFirebaseAndTrackUsage({
    required String idToken,
    required String? accessToken,
    required GoogleSignInAccount googleUser,
  }) async {
    if (_isDesktop) {
      return const _TrackingResult(
        firebaseUid: null,
        loginMessage: 'Signed in (desktop mode, Firestore tracking disabled)',
      );
    }

    String? firebaseUid;
    try {
      final credential = fb_auth.GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );
      final auth = fb_auth.FirebaseAuth.instance;
      final userCredential = await auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user ?? auth.currentUser;
      if (firebaseUser == null) {
        return const _TrackingResult(
          firebaseUid: null,
          loginMessage: 'Signed in locally (tracking unavailable)',
        );
      }
      firebaseUid = firebaseUser.uid;
      await _trackFirebaseLogin(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? googleUser.email,
        displayName:
            firebaseUser.displayName ??
            googleUser.displayName ??
            googleUser.email,
        photoUrl: firebaseUser.photoURL ?? googleUser.photoUrl,
        provider: 'google',
      );
      return _TrackingResult(
        firebaseUid: firebaseUid,
        loginMessage: 'Signed in with Firebase (community mode)',
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'keychain-error') {
        final device = await _collectDeviceInfo();
        final fallback = await _trackWithoutFirebaseAuth(
          googleUser: googleUser,
          device: device,
        );
        if (fallback) {
          return const _TrackingResult(
            firebaseUid: null,
            loginMessage:
                'Signed in locally (Firebase auth unavailable, tracking saved)',
          );
        }
        return const _TrackingResult(
          firebaseUid: null,
          loginMessage:
              'Signed in locally (Firebase keychain unavailable; tracking blocked by Firestore rules)',
        );
      }
      debugPrint('Firebase auth tracking failed: ${e.code} ${e.message}');
      return const _TrackingResult(
        firebaseUid: null,
        loginMessage: 'Signed in locally (Firebase auth tracking failed)',
      );
    } on FirebaseException catch (e) {
      debugPrint('Firestore tracking write failed: ${e.code} ${e.message}');
      return _TrackingResult(
        firebaseUid: firebaseUid,
        loginMessage: 'Signed in (tracking write failed)',
      );
    } catch (e, stackTrace) {
      debugPrint('Firebase tracking failed: $e');
      debugPrint('$stackTrace');
      return _TrackingResult(
        firebaseUid: firebaseUid,
        loginMessage: 'Signed in locally (tracking unavailable)',
      );
    }
  }

  Future<bool> _trackWithoutFirebaseAuth({
    required GoogleSignInAccount googleUser,
    required Map<String, dynamic> device,
  }) async {
    if (_isDesktop) {
      return true;
    }

    try {
      final email = googleUser.email;
      final fallbackId = _communityDocIdFromEmail(email);
      final users = FirebaseFirestore.instance.collection('community_users');

      await users.doc(fallbackId).set({
        'uid': fallbackId,
        'email': email,
        'displayName': googleUser.displayName ?? email,
        'photoUrl': googleUser.photoUrl,
        'provider': 'google',
        'authMode': 'local-google-no-firebase-auth',
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'loginCount': FieldValue.increment(1),
        'lastDevice': device,
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('community_login_events')
          .add({
            'uid': fallbackId,
            'email': email,
            'provider': 'google',
            'authMode': 'local-google-no-firebase-auth',
            'occurredAt': FieldValue.serverTimestamp(),
            'device': device,
          });
      return true;
    } on FirebaseException catch (e) {
      debugPrint('Fallback Firestore tracking failed: ${e.code} ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Fallback Firestore tracking failed: $e');
      return false;
    }
  }

  String _communityDocIdFromEmail(String email) {
    final normalized = email.trim().toLowerCase();
    final encoded = base64UrlEncode(
      utf8.encode(normalized),
    ).replaceAll('=', '');
    return 'email_$encoded';
  }

  void _ensureRestClientInitialized() {
    // Ensure RestClientService instance is created from provider.
    _ref.read(restClientProvider);
  }

  Future<void> _persistCommunitySession({
    required String? firebaseUid,
    required String email,
    required String displayName,
    required String? photoUrl,
    required String idToken,
    required String? accessToken,
  }) async {
    await _storage.write(key: _communityUidKey, value: firebaseUid ?? '');
    await _storage.write(key: _communityEmailKey, value: email);
    await _storage.write(key: _communityDisplayNameKey, value: displayName);
    await _storage.write(key: _communityPhotoUrlKey, value: photoUrl ?? '');
    await _storage.write(key: _communityIdTokenKey, value: idToken);
    await _storage.write(
      key: _communityAccessTokenKey,
      value: accessToken ?? '',
    );
  }

  Future<void> _persistBackendSession(User user) async {
    final payload = <String, dynamic>{
      'id': user.id,
      'login': user.login,
      'username': user.username,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'phone': user.phone,
      'imageUrl': user.imageUrl,
      'activated': user.activated == true ? 1 : 0,
      'langKey': user.langKey,
      'authorities': user.authorities?.join(','),
      'createdBy': user.createdBy,
      'createdDate': user.createdDate?.toIso8601String(),
      'lastModifiedBy': user.lastModifiedBy,
      'lastModifiedDate': user.lastModifiedDate?.toIso8601String(),
    };
    await _storage.write(key: _backendUserKey, value: jsonEncode(payload));
  }

  Future<void> _persistRememberedSession({
    required User user,
    required String? token,
    required String? firebaseUid,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'token': token ?? '',
      'firebaseUid': firebaseUid ?? '',
      'user': {
        'id': user.id,
        'login': user.login,
        'username': user.username,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'phone': user.phone,
        'imageUrl': user.imageUrl,
        'activated': user.activated == true ? 1 : 0,
        'langKey': user.langKey,
        'authorities': user.authorities?.join(','),
        'createdBy': user.createdBy,
        'createdDate': user.createdDate?.toIso8601String(),
        'lastModifiedBy': user.lastModifiedBy,
        'lastModifiedDate': user.lastModifiedDate?.toIso8601String(),
      },
    };
    await prefs.setString(_rememberedSessionKey, jsonEncode(payload));
  }

  Future<void> _persistRememberedSessionIfEnabled({
    required User user,
    required String? token,
    required String? firebaseUid,
  }) async {
    if (!state.rememberMe) {
      await _clearRememberedSession();
      return;
    }
    await _persistRememberedSession(
      user: user,
      token: token,
      firebaseUid: firebaseUid,
    );
  }

  Future<bool> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMePrefKey) ?? true;
  }

  Future<void> _saveRememberMePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMePrefKey, value);
  }

  Future<void> _clearRememberedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberedSessionKey);
  }

  Future<Response<dynamic>> _postWithFallback({
    required List<String> paths,
    required Map<String, dynamic> data,
  }) async {
    Object? lastError;
    for (final path in paths) {
      try {
        return await _restClient.post(path, data: data);
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? Exception('Request failed');
  }

  Future<_RestoredCommunitySession?> _restoreRememberedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_rememberedSessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final token = decoded['token']?.toString() ?? '';
      final firebaseUidRaw = decoded['firebaseUid']?.toString() ?? '';
      final userRaw = decoded['user'];
      if (token.isEmpty || userRaw is! Map<String, dynamic>) {
        return null;
      }

      final user = User.fromMap(userRaw);
      return _RestoredCommunitySession(
        firebaseUid: firebaseUidRaw.isEmpty ? null : firebaseUidRaw,
        idToken: token,
        accessToken: null,
        user: user,
      );
    } catch (_) {
      return null;
    }
  }

  Future<_RestoredCommunitySession?> _restoreBackendSession() async {
    final tokenKey = _ref.read(appConfigProvider).securityConfig.tokenKey;
    if (tokenKey.isEmpty) {
      return null;
    }

    final token = await _storage.read(key: tokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }

    final cachedUserRaw = await _storage.read(key: _backendUserKey);
    if (cachedUserRaw != null && cachedUserRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(cachedUserRaw) as Map<String, dynamic>;
        final cachedUser = User.fromMap(decoded);
        return _RestoredCommunitySession(
          firebaseUid: null,
          idToken: token,
          accessToken: null,
          user: cachedUser,
        );
      } catch (_) {
        // Continue with network fallback.
      }
    }

    try {
      final response = await _restClient.get('/account');
      if (response.statusCode != 200) {
        return _RestoredCommunitySession(
          firebaseUid: null,
          idToken: token,
          accessToken: null,
          user: const User(
            id: 0,
            username: 'Wayang User',
            login: 'session',
            email: 'session@local',
          ),
        );
      }

      final user = User.fromMap(response.data as Map<String, dynamic>);
      await _persistBackendSession(user);
      return _RestoredCommunitySession(
        firebaseUid: null,
        idToken: token,
        accessToken: null,
        user: user,
      );
    } catch (_) {
      return _RestoredCommunitySession(
        firebaseUid: null,
        idToken: token,
        accessToken: null,
        user: const User(
          id: 0,
          username: 'Wayang User',
          login: 'session',
          email: 'session@local',
        ),
      );
    }
  }

  Future<_RestoredCommunitySession?> _restoreFirebaseSession() async {
    try {
      final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      final idToken = await firebaseUser.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        return null;
      }

      final email = firebaseUser.email ?? '';
      if (email.isEmpty) {
        return null;
      }

      final displayName =
          firebaseUser.displayName == null || firebaseUser.displayName!.isEmpty
          ? email
          : firebaseUser.displayName!;

      final user = User(
        id: 0,
        login: email,
        email: email,
        username: displayName,
        firstName: displayName,
        imageUrl: firebaseUser.photoURL,
      );

      return _RestoredCommunitySession(
        firebaseUid: firebaseUser.uid,
        idToken: idToken,
        accessToken: null,
        user: user,
      );
    } catch (_) {
      return null;
    }
  }

  Future<_RestoredCommunitySession?> _restoreCommunitySession() async {
    final uid = await _storage.read(key: _communityUidKey);
    final email = await _storage.read(key: _communityEmailKey);
    final displayName = await _storage.read(key: _communityDisplayNameKey);
    final photoUrl = await _storage.read(key: _communityPhotoUrlKey);
    final idToken = await _storage.read(key: _communityIdTokenKey);
    final accessToken = await _storage.read(key: _communityAccessTokenKey);

    if (email == null || email.isEmpty || idToken == null || idToken.isEmpty) {
      return null;
    }

    final user = User(
      id: 0,
      login: email,
      email: email,
      username: (displayName != null && displayName.isNotEmpty)
          ? displayName
          : email,
      firstName: displayName,
      imageUrl: (photoUrl != null && photoUrl.isNotEmpty) ? photoUrl : null,
    );

    return _RestoredCommunitySession(
      firebaseUid: (uid != null && uid.isNotEmpty) ? uid : null,
      idToken: idToken,
      accessToken: (accessToken != null && accessToken.isNotEmpty)
          ? accessToken
          : null,
      user: user,
    );
  }

  Future<void> _trackFirebaseLogin({
    required String uid,
    required String email,
    required String displayName,
    required String? photoUrl,
    required String provider,
  }) async {
    if (_isDesktop) {
      return;
    }

    final device = await _collectDeviceInfo();
    final users = FirebaseFirestore.instance.collection('community_users');
    await users.doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'provider': provider,
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'loginCount': FieldValue.increment(1),
      'lastDevice': device,
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('community_login_events').add({
      'uid': uid,
      'email': email,
      'provider': provider,
      'occurredAt': FieldValue.serverTimestamp(),
      'device': device,
    });
  }

  Future<Map<String, dynamic>> _collectDeviceInfo() async {
    final info = DeviceInfoPlugin();
    try {
      if (kIsWeb) {
        final webInfo = await info.webBrowserInfo;
        return {
          'platform': 'web',
          'browserName': webInfo.browserName.name,
          'userAgent': webInfo.userAgent,
          'appVersion': webInfo.appVersion,
        };
      }

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final android = await info.androidInfo;
          return {
            'platform': 'android',
            'brand': android.brand,
            'model': android.model,
            'sdkInt': android.version.sdkInt,
            'release': android.version.release,
          };
        case TargetPlatform.iOS:
          final ios = await info.iosInfo;
          return {
            'platform': 'ios',
            'name': ios.name,
            'model': ios.model,
            'systemName': ios.systemName,
            'systemVersion': ios.systemVersion,
          };
        case TargetPlatform.macOS:
          final mac = await info.macOsInfo;
          return {
            'platform': 'macos',
            'model': mac.model,
            'arch': mac.arch,
            'osRelease': mac.osRelease,
            'computerName': mac.computerName,
          };
        case TargetPlatform.windows:
          final win = await info.windowsInfo;
          return {
            'platform': 'windows',
            'computerName': win.computerName,
            'numberOfCores': win.numberOfCores,
            'systemMemoryInMegabytes': win.systemMemoryInMegabytes,
            'majorVersion': win.majorVersion,
            'minorVersion': win.minorVersion,
            'buildNumber': win.buildNumber,
          };
        case TargetPlatform.linux:
          final linux = await info.linuxInfo;
          return {
            'platform': 'linux',
            'name': linux.name,
            'version': linux.version,
            'id': linux.id,
            'prettyName': linux.prettyName,
          };
        case TargetPlatform.fuchsia:
          return {'platform': 'fuchsia'};
      }
    } catch (_) {
      return {'platform': defaultTargetPlatform.name, 'status': 'unavailable'};
    }
  }

  /*  String messagePassword(context) {
    switch (state.passwordMessage) {
      case "confirm":
        return AppLocalizations.of(context)!.passwordConfirm;
      case "empty":
        return AppLocalizations.of(context)!.passwordEmpty;
      case "length":
        return AppLocalizations.of(context)!.passwordLength;
      case "match":
        return AppLocalizations.of(context)!.passwordMatch;
      default:
        return "";
    }
  }

  message(context) {
    switch (state.errorMessage) {
      case "unauthorized":
        state.copyWith(
            errorMessage: AppLocalizations.of(context)!.errorUnauthorized);
        break;
      case "username":
        state.copyWith(
            errorMessage: AppLocalizations.of(context)!.errorUsername);
        return AppLocalizations.of(context)!.errorUsername;
      default:
        state.copyWith(
            errorMessage: AppLocalizations.of(context)!.errorNetwork);
        return AppLocalizations.of(context)!.errorNetwork;
    }
  } */
}

class _RestoredCommunitySession {
  final String? firebaseUid;
  final String idToken;
  final String? accessToken;
  final User user;

  const _RestoredCommunitySession({
    required this.firebaseUid,
    required this.idToken,
    required this.accessToken,
    required this.user,
  });
}

class _TrackingResult {
  final String? firebaseUid;
  final String loginMessage;

  const _TrackingResult({
    required this.firebaseUid,
    required this.loginMessage,
  });
}
