import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'token_verification_widget.dart';

enum AuthMode { pattern, token, both }

enum AuthStep { pattern, token }

class PatternTokenAuth extends HookConsumerWidget {
  final AuthMode mode;
  final double size;
  final VoidCallback? onAuthenticationSuccess;
  final Function(String)? onPatternSaved;
  final List<int>? savedPattern;

  const PatternTokenAuth({
    Key? key,
    this.mode = AuthMode.both,
    this.size = 300,
    this.onAuthenticationSuccess,
    this.onPatternSaved,
    this.savedPattern,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patternState = ref.watch(patternLockProvider);
    final tokenState = ref.watch(tokenProvider);
    final patternNotifier = ref.read(patternLockProvider.notifier);
    final tokenNotifier = ref.read(tokenProvider.notifier);

    final authStep = useState<AuthStep>(AuthStep.pattern);
    final errorMessage = useState<String?>(null);

    // Handle successful pattern authentication
    useEffect(() {
      if (authStep.value == AuthStep.pattern &&
          patternState.status == PatternStatus.completed) {
        if (savedPattern != null) {
          // Verify pattern
          final isValid = patternNotifier.verifyPattern(savedPattern!);
          if (isValid) {
            if (mode == AuthMode.pattern) {
              // Pattern only - success
              onAuthenticationSuccess?.call();
            } else {
              // Move to token verification
              authStep.value = AuthStep.token;
            }
          } else {
            errorMessage.value = 'Invalid pattern';
            Future.delayed(const Duration(milliseconds: 500), () {
              patternNotifier.reset();
              errorMessage.value = null;
            });
          }
        }
      }
      return null;
    }, [patternState.status]);

    // Handle token verification
    useEffect(() {
      if (authStep.value == AuthStep.token &&
          tokenState.status == TokenStatus.valid) {
        // Both pattern and token verified
        onAuthenticationSuccess?.call();
      }
      return null;
    }, [tokenState.status]);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    authStep.value == AuthStep.pattern ? '1' : '2',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authStep.value == AuthStep.pattern
                            ? 'Step 1: Pattern Authentication'
                            : 'Step 2: Token Verification',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        authStep.value == AuthStep.pattern
                            ? 'Draw your pattern to continue'
                            : 'Verify your token to complete authentication',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (mode == AuthMode.both)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${authStep.value == AuthStep.pattern ? '1/2' : '2/2'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Error message
          if (errorMessage.value != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage.value!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          // Content based on step
          if (authStep.value == AuthStep.pattern)
            Column(
              children: [
                PatternLock(
                  size: size,
                  isSettingPattern: savedPattern == null,
                  savedPattern: savedPattern,
                  onPatternCompleted: (pattern) {
                    if (savedPattern == null) {
                      // Saving new pattern
                      onPatternSaved?.call(pattern);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  savedPattern == null
                      ? 'Create your pattern (minimum 4 points)'
                      : 'Draw your pattern to unlock',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            )
          else
            TokenVerificationWidget(
              onVerificationSuccess: () {
                // Success handled by useEffect
              },
              onVerificationFailure: () {
                errorMessage.value = 'Token verification failed';
              },
            ),

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (authStep.value == AuthStep.token)
                TextButton.icon(
                  onPressed: () {
                    authStep.value = AuthStep.pattern;
                    patternNotifier.reset();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Pattern'),
                ),

              if (authStep.value == AuthStep.pattern && savedPattern != null)
                TextButton.icon(
                  onPressed: () {
                    patternNotifier.reset();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),

              if (authStep.value == AuthStep.token)
                TextButton.icon(
                  onPressed: () {
                    tokenNotifier.clearToken();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Token'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
