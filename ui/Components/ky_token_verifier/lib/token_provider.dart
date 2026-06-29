import 'package:riverpod/riverpod.dart';

enum TokenStatus { initial, verifying, valid, invalid, expired }

class TokenState {
  final String? token;
  final TokenStatus status;
  final DateTime? expiresAt;
  final String? errorMessage;

  TokenState({
    this.token,
    required this.status,
    this.expiresAt,
    this.errorMessage,
  });

  TokenState copyWith({
    String? token,
    TokenStatus? status,
    DateTime? expiresAt,
    String? errorMessage,
  }) {
    return TokenState(
      token: token ?? this.token,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      errorMessage: errorMessage,
    );
  }

  bool get isValid => status == TokenStatus.valid;
  bool get isExpired => status == TokenStatus.expired;
}

class TokenNotifier extends StateNotifier<TokenState> {
  TokenNotifier() : super(TokenState(status: TokenStatus.initial));

  // Simulate token verification
  Future<void> verifyToken(String token) async {
    state = state.copyWith(status: TokenStatus.verifying, errorMessage: null);

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation logic - in real app, this would call your backend
    if (token.length >= 10 && token.startsWith('valid_')) {
      state = state.copyWith(
        token: token,
        status: TokenStatus.valid,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
    } else if (token == 'expired_token') {
      state = state.copyWith(
        status: TokenStatus.expired,
        errorMessage: 'Token has expired',
      );
    } else {
      state = state.copyWith(
        status: TokenStatus.invalid,
        errorMessage: 'Invalid token',
      );
    }
  }

  // Refresh token
  Future<void> refreshToken() async {
    if (state.token == null) return;

    state = state.copyWith(status: TokenStatus.verifying);

    // Simulate token refresh
    await Future.delayed(const Duration(seconds: 1));

    // In real app, this would call your refresh token endpoint
    state = state.copyWith(
      token: 'valid_${DateTime.now().millisecondsSinceEpoch}',
      status: TokenStatus.valid,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  // Clear token (logout)
  void clearToken() {
    state = TokenState(status: TokenStatus.initial);
  }

  // Check if token needs refresh (expiring soon)
  bool needsRefresh() {
    if (state.expiresAt == null) return false;
    return state.expiresAt!.difference(DateTime.now()).inMinutes < 30;
  }
}

final tokenProvider = StateNotifierProvider<TokenNotifier, TokenState>((ref) {
  return TokenNotifier();
});
