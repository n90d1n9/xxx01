import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/auth_status.dart';
import '../models/face_auth_state.dart';
import '../states/encryption_provider.dart';
import '../states/face_auth_provider.dart';
import '../states/security_report_dialog.dart';
import '../widgets/auth_history_dialog.dart';
import '../widgets/face_overlay_painter.dart';
import '../widgets/settings_dialog.dart';

class EnhancedFaceAuthScreen extends ConsumerStatefulWidget {
  const EnhancedFaceAuthScreen({super.key});

  @override
  ConsumerState<EnhancedFaceAuthScreen> createState() =>
      _EnhancedFaceAuthScreenState();
}

class _EnhancedFaceAuthScreenState extends ConsumerState<EnhancedFaceAuthScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  late AnimationController _pulseController;
  late AnimationController _statusController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _statusAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCamera();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _statusController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _statusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statusController, curve: Curves.elasticOut),
    );

    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.nv21,
        );
        await _controller!.initialize();
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pulseController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(faceAuthProvider);
    final authNotifier = ref.watch(faceAuthProvider.notifier);

    // Trigger status animation when status changes
    ref.listen<FaceAuthState>(faceAuthProvider, (previous, current) {
      if (previous?.status != current.status) {
        _statusController.forward(from: 0.0);
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, authState, authNotifier),
      body: Container(
        decoration: _buildBackgroundDecoration(authState),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(flex: 3, child: _buildCameraSection(authState)),
              Expanded(
                flex: 2,
                child: _buildControlPanel(authState, authNotifier),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    FaceAuthState authState,
    EnhancedFaceAuthNotifier authNotifier,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'SecureAuth Pro',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        if (authState.isAuthenticated)
          IconButton(
            onPressed: () => _showSecurityReport(context, authState),
            icon: const Icon(Icons.security),
            tooltip: 'Security Report',
          ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'settings':
                await _showSettings(context, authState, authNotifier);
                break;
              case 'history':
                await _showAuthHistory(context, authState);
                break;
              case 'reset':
                await _showResetDialog(context, authNotifier);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'history',
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('Auth History'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'reset',
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Reset Data'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  BoxDecoration _buildBackgroundDecoration(FaceAuthState authState) {
    Color startColor, endColor;

    switch (authState.status) {
      case AuthStatus.authenticated:
        startColor = const Color(0xFF00C851);
        endColor = const Color(0xFF007E33);
        break;
      case AuthStatus.failed:
      case AuthStatus.locked:
        startColor = const Color(0xFFFF4444);
        endColor = const Color(0xFFCC0000);
        break;
      case AuthStatus.authenticating:
        startColor = const Color(0xFFFFBB33);
        endColor = const Color(0xFFFF8800);
        break;
      default:
        startColor = const Color(0xFF667EEA);
        endColor = const Color(0xFF764BA2);
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [startColor, endColor],
        stops: const [0.0, 1.0],
      ),
    );
  }

  Widget _buildCameraSection(FaceAuthState authState) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            _buildCameraPreview(),
            _buildCameraOverlay(authState),
            _buildStatusOverlay(authState),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: CameraPreview(_controller!),
    );
  }

  Widget _buildCameraOverlay(FaceAuthState authState) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: EnhancedFaceOverlayPainter(
            pulseScale: _pulseAnimation.value,
            status: authState.status,
            confidence: authState.lastMatchConfidence,
          ),
          child: Container(),
        );
      },
    );
  }

  Widget _buildStatusOverlay(FaceAuthState authState) {
    if (authState.status == AuthStatus.initializing) return const SizedBox();

    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _statusAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _statusAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusIcon(authState.status),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(authState),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (authState.lastMatchConfidence != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(authState.lastMatchConfidence! * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon(AuthStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case AuthStatus.authenticated:
        icon = Icons.verified_user;
        color = Colors.green;
        break;
      case AuthStatus.authenticating:
        icon = Icons.face_retouching_natural;
        color = Colors.orange;
        break;
      case AuthStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      case AuthStatus.locked:
        icon = Icons.lock;
        color = Colors.red;
        break;
      case AuthStatus.ready:
        icon = Icons.face;
        color = Colors.blue;
        break;
      case AuthStatus.setupRequired:
        icon = Icons.add_a_photo;
        color = Colors.white;
        break;
      default:
        icon = Icons.hourglass_empty;
        color = Colors.white;
    }

    return Icon(icon, color: color, size: 18);
  }

  String _getStatusText(FaceAuthState authState) {
    switch (authState.status) {
      case AuthStatus.authenticated:
        return 'Authenticated Successfully';
      case AuthStatus.authenticating:
        return 'Scanning...';
      case AuthStatus.failed:
        return 'Authentication Failed';
      case AuthStatus.locked:
        if (authState.lockUntil != null) {
          final remaining = authState.lockUntil!.difference(DateTime.now());
          return 'Locked for ${remaining.inMinutes}m ${remaining.inSeconds % 60}s';
        }
        return 'Account Locked';
      case AuthStatus.ready:
        return 'Ready to Authenticate';
      case AuthStatus.setupRequired:
        return 'Setup Required';
      default:
        return 'Initializing...';
    }
  }

  Widget _buildControlPanel(
    FaceAuthState authState,
    EnhancedFaceAuthNotifier authNotifier,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMainActionButton(authState, authNotifier),
          const SizedBox(height: 20),
          if (authState.biometricAvailable && !authState.isAuthenticated) ...[
            _buildBiometricButton(authState, authNotifier),
            const SizedBox(height: 16),
          ],
          if (authState.error != null) ...[
            _buildErrorMessage(authState.error!),
            const SizedBox(height: 16),
          ],
          _buildInfoRow(authState),
        ],
      ),
    );
  }

  Widget _buildMainActionButton(
    FaceAuthState authState,
    EnhancedFaceAuthNotifier authNotifier,
  ) {
    if (authState.isLoading) {
      return SizedBox(
        width: double.infinity,
        height: 64,
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text(
                  'Processing...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (authState.isAuthenticated) {
      return SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton.icon(
          onPressed: () => authNotifier.signOut(),
          icon: const Icon(Icons.logout, size: 24),
          label: const Text(
            'Sign Out',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
          ),
        ),
      );
    }

    if (authState.isLocked) {
      return SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.lock, size: 24),
          label: const Text(
            'Account Locked',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: () => _takePicture(authNotifier, authState.isSetup),
        icon: Icon(
          authState.isSetup ? Icons.camera_alt : Icons.face_retouching_natural,
          size: 24,
        ),
        label: Text(
          authState.isSetup ? 'Authenticate with Face' : 'Setup Face ID',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildBiometricButton(
    FaceAuthState authState,
    EnhancedFaceAuthNotifier authNotifier,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: authState.canAuthenticate
            ? () => authNotifier.authenticateWithBiometrics()
            : null,
        icon: const Icon(Icons.fingerprint, size: 22),
        label: const Text(
          'Use Biometric',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(FaceAuthState authState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoItem(
          icon: Icons.security,
          label: 'Security',
          value: authState.isSetup ? 'Active' : 'Setup',
          color: authState.isSetup ? Colors.green : Colors.orange,
        ),
        _buildInfoItem(
          icon: Icons.devices,
          label: 'Device',
          value: 'Secured',
          color: Colors.blue,
        ),
        _buildInfoItem(
          icon: Icons.history,
          label: 'Attempts',
          value: authState.recentAttempts.length.toString(),
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> _takePicture(
    EnhancedFaceAuthNotifier notifier,
    bool isSetup,
  ) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      HapticFeedback.mediumImpact();

      await _controller!.startImageStream((image) async {
        await _controller!.stopImageStream();

        if (isSetup) {
          await notifier.authenticateWithFace(image);
        } else {
          await notifier.setupFaceAuth(image);
        }
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _showSecurityReport(
    BuildContext context,
    FaceAuthState authState,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => SecurityReportDialog(authState: authState),
    );
  }

  Future<void> _showSettings(
    BuildContext context,
    FaceAuthState authState,
    EnhancedFaceAuthNotifier authNotifier,
  ) async {
    await showDialog(
      context: context,
      builder: (context) =>
          SettingsDialog(authState: authState, authNotifier: authNotifier),
    );
  }

  Future<void> _showAuthHistory(
    BuildContext context,
    FaceAuthState authState,
  ) async {
    await showDialog(
      context: context,
      builder: (context) =>
          AuthHistoryDialog(attempts: authState.recentAttempts),
    );
  }

  Future<void> _showResetDialog(
    BuildContext context,
    EnhancedFaceAuthNotifier authNotifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'This will permanently delete all face templates, authentication history, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authNotifier.resetAllData();
    }
  }
}
