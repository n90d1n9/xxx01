import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class QiblaView extends StatefulWidget {
  const QiblaView({super.key});

  @override
  State<QiblaView> createState() => _QiblaViewState();
}

class _QiblaViewState extends State<QiblaView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _currentDirection = 0.0;
  double _qiblaDirection = 0.0;
  bool _hasPermission = false;
  bool _isCalibrating = false;
  bool _locationLoading = false;
  String _errorMessage = '';
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeCompass();
  }

  Future<void> _initializeCompass() async {
    setState(() {
      _isCalibrating = true;
      _errorMessage = '';
    });

    try {
      // Check and request permissions
      await _checkPermissions();

      // If we have permissions, start compass and calculate Qibla
      if (_hasPermission) {
        await _startCompass();
        await _calculateQiblaDirection();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: ${e.toString()}';
        _hasPermission = false;
      });
    } finally {
      if (mounted) {
        setState(() => _isCalibrating = false);
      }
    }
  }

  Future<void> _checkPermissions() async {
    // Check compass permission (Android 12+ needs this)
    if (await Permission.locationWhenInUse.serviceStatus.isDisabled) {
      setState(() {
        _hasPermission = false;
        _errorMessage = 'Location services are disabled';
      });
      return;
    }

    // Check and request location permission
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    if (!status.isGranted) {
      setState(() {
        _hasPermission = false;
        _errorMessage = 'Location permission denied';
      });
      return;
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _hasPermission = false;
        _errorMessage = 'Please enable location services';
      });
      return;
    }

    setState(() {
      _hasPermission = true;
      _errorMessage = '';
    });
  }

  Future<void> _startCompass() async {
    // Cancel any existing subscription
    _compassSubscription?.cancel();

    // Check if compass is available
    if (FlutterCompass.events == null) {
      setState(() {
        _hasPermission = false;
        _errorMessage = 'Compass not available on this device';
      });
      return;
    }

    // Listen to compass events
    _compassSubscription = FlutterCompass.events!.listen((event) {
      if (event.heading == null) {
        setState(() {
          _errorMessage = 'Failed to get compass heading';
        });
        return;
      }

      // Update direction with animation
      _updateDirection(event.heading!);
    });
  }

  void _updateDirection(double newDirection) {
    _animation = Tween<double>(
      begin: _currentDirection,
      end: newDirection,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.reset();
    _animationController.forward();

    setState(() {
      _currentDirection = newDirection;
    });
  }

  Future<void> _calculateQiblaDirection() async {
    if (!_hasPermission) return;

    setState(() {
      _locationLoading = true;
      _errorMessage = '';
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Kaaba coordinates
      const double kaabaLat = 21.4225;
      const double kaabaLng = 39.8262;

      // Calculate Qibla direction
      final double latDiff = kaabaLat - position.latitude;
      final double lngDiff = kaabaLng - position.longitude;

      final double userLatRad = position.latitude * (pi / 180);
      final double kaabaLatRad = kaabaLat * (pi / 180);
      final double lngDiffRad = lngDiff * (pi / 180);

      final double y = sin(lngDiffRad);
      final double x =
          cos(userLatRad) * tan(kaabaLatRad) -
          sin(userLatRad) * cos(lngDiffRad);

      double qiblaRad = atan2(y, x);
      double qiblaDeg = qiblaRad * (180 / pi);
      qiblaDeg = (qiblaDeg + 360) % 360;

      setState(() {
        _qiblaDirection = qiblaDeg;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: ${e.toString()}';
      });
    } finally {
      setState(() => _locationLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Direction'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isCalibrating)
              _buildCalibrationView()
            else if (!_hasPermission || _errorMessage.isNotEmpty)
              _buildPermissionErrorView()
            else
              _buildCompassView(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationView() {
    return Column(
      children: [
        const CircularProgressIndicator(color: Colors.teal),
        const SizedBox(height: 16),
        const Text(
          'Calibrating compass...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Move your phone in a figure-8 pattern',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildPermissionErrorView() {
    return Column(
      children: [
        const Icon(Icons.location_disabled, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        const Text(
          'Permission required',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage.isNotEmpty
              ? _errorMessage
              : 'Please enable location services for this app',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _initializeCompass,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          child: const Text('Grant Permission'),
        ),
      ],
    );
  }

  Widget _buildCompassView() {
    return Column(
      children: [
        // Qibla direction display
        const Text(
          'Qibla Direction',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Align the needle with the Qibla marker',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 32),

        // Compass widget
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer compass circle
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),

                // Rotating compass
                Transform.rotate(
                  angle: (_animation.value * (pi / 180) * -1),
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Compass markers
                        CustomPaint(
                          size: const Size(220, 220),
                          painter: CompassPainter(),
                        ),

                        // North indicator
                        Positioned(
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'N',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // East indicator
                        Positioned(
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'E',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Fixed Qibla direction indicator
                Transform.rotate(
                  angle:
                      (_qiblaDirection * (pi / 180) -
                          _animation.value * (pi / 180)),
                  child: Container(
                    width: 200,
                    height: 200,
                    child: CustomPaint(painter: QiblaPainter()),
                  ),
                ),

                // Center dot
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 32),

        // Degree information
        Text(
          'Current heading: ${_currentDirection.toStringAsFixed(1)}°',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Qibla direction: ${_qiblaDirection.toStringAsFixed(1)}°',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 24),

        // Recalibrate button
        ElevatedButton.icon(
          onPressed: () {
            setState(() => _isCalibrating = true);
            _initializeCompass();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Recalibrate'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final circlePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final markingsPaint =
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius, circlePaint);

    for (int i = 0; i < 360; i += 15) {
      final angle = i * (pi / 180);
      final outerPoint = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );

      final innerPoint = Offset(
        center.dx + cos(angle) * (radius - (i % 90 == 0 ? 15 : 10)),
        center.dy + sin(angle) * (radius - (i % 90 == 0 ? 15 : 10)),
      );

      canvas.drawLine(innerPoint, outerPoint, markingsPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class QiblaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final qiblaPaint =
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx - 10, center.dy - radius + 20);
    path.lineTo(center.dx, center.dy - radius + 10);
    path.lineTo(center.dx + 10, center.dy - radius + 20);
    path.close();

    canvas.drawPath(path, qiblaPaint);

    final kaabaPaint =
        Paint()
          ..color = Colors.green.shade800
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius + 40),
        width: 12,
        height: 12,
      ),
      kaabaPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
