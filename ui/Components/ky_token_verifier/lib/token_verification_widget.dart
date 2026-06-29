import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/token_provider.dart';

class TokenVerificationWidget extends HookConsumerWidget {
  final VoidCallback? onVerificationSuccess;
  final VoidCallback? onVerificationFailure;
  final bool autoVerify;
  final String? initialToken;

  const TokenVerificationWidget({
    Key? key,
    this.onVerificationSuccess,
    this.onVerificationFailure,
    this.autoVerify = false,
    this.initialToken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenState = ref.watch(tokenProvider);
    final tokenNotifier = ref.read(tokenProvider.notifier);

    final tokenController = useTextEditingController(text: initialToken ?? '');
    final isObscured = useState<bool>(true);

    // Auto-verify if initial token is provided
    useEffect(() {
      if (autoVerify && initialToken != null && initialToken!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          tokenNotifier.verifyToken(initialToken!);
        });
      }
      return null;
    }, [initialToken, autoVerify]);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getStatusColor(tokenState.status).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(tokenState.status),
                  color: _getStatusColor(tokenState.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(tokenState.status),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (tokenState.expiresAt != null)
                      Text(
                        'Expires: ${_formatExpiry(tokenState.expiresAt!)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              if (tokenState.status == TokenStatus.valid)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Token Input Field
          if (tokenState.status != TokenStatus.valid)
            TextField(
              controller: tokenController,
              obscureText: isObscured.value,
              decoration: InputDecoration(
                labelText: 'Enter Token',
                hintText: 'e.g., valid_1234567890',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.vpn_key),
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscured.value ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => isObscured.value = !isObscured.value,
                ),
                errorText: tokenState.errorMessage,
              ),
            ),

          const SizedBox(height: 16),

          // Status Message
          if (tokenState.status == TokenStatus.verifying)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Verifying token...'),
                ],
              ),
            ),

          // Action Buttons
          Row(
            children: [
              if (tokenState.status != TokenStatus.valid)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: tokenState.status == TokenStatus.verifying
                        ? null
                        : () async {
                            if (tokenController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a token'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            await tokenNotifier.verifyToken(
                              tokenController.text,
                            );

                            if (tokenState.status == TokenStatus.valid) {
                              onVerificationSuccess?.call();
                            } else {
                              onVerificationFailure?.call();
                            }
                          },
                    icon: const Icon(Icons.verified),
                    label: const Text('Verify Token'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

              if (tokenState.status == TokenStatus.valid) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      tokenNotifier.clearToken();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Clear Token'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await tokenNotifier.refreshToken();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Token Info
          if (tokenState.token != null &&
              tokenState.status == TokenStatus.valid)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Token Details:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Token: ${tokenState.token}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (tokenState.expiresAt != null)
                    Text(
                      'Expires: ${_formatExpiry(tokenState.expiresAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: tokenNotifier.needsRefresh()
                            ? Colors.orange
                            : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),

          // Warning for expiring token
          if (tokenNotifier.needsRefresh() &&
              tokenState.status == TokenStatus.valid)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Token expiring soon',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'Refresh your token to continue using the app',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(TokenStatus status) {
    switch (status) {
      case TokenStatus.valid:
        return Colors.green;
      case TokenStatus.invalid:
        return Colors.red;
      case TokenStatus.expired:
        return Colors.orange;
      case TokenStatus.verifying:
        return Colors.blue;
      case TokenStatus.initial:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(TokenStatus status) {
    switch (status) {
      case TokenStatus.valid:
        return Icons.check_circle;
      case TokenStatus.invalid:
        return Icons.cancel;
      case TokenStatus.expired:
        return Icons.timer_off;
      case TokenStatus.verifying:
        return Icons.hourglass_empty;
      case TokenStatus.initial:
        return Icons.vpn_key;
    }
  }

  String _getStatusTitle(TokenStatus status) {
    switch (status) {
      case TokenStatus.initial:
        return 'Token Verification';
      case TokenStatus.verifying:
        return 'Verifying Token';
      case TokenStatus.valid:
        return 'Token Valid';
      case TokenStatus.invalid:
        return 'Invalid Token';
      case TokenStatus.expired:
        return 'Token Expired';
    }
  }

  String _formatExpiry(DateTime expiry) {
    final now = DateTime.now();
    final difference = expiry.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    } else if (difference.inHours > 24) {
      return '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }
}
