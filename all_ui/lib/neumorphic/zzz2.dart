import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom theme configuration for neumorphic styling in Flutter
/// This file contains theme data, color schemes, and helper classes
/// to implement a consistent neumorphic look across your application

// Main colors for the neumorphic theme
class NeumorphicColors {
  // Base surface color - light grayish background
  static const Color surface = Color(0xFFE0E5EC);

  // Accent colors
  static const Color primary = Color(0xFF6B8EAE);
  static const Color secondary = Color(0xFF8A9EB5);
  static const Color accent = Color(0xFF64AFCD);

  // Text colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textDisabled = Color(0xFFA0AEC0);

  // Shadow colors
  static const Color shadowDark = Color(0xFFA8B5C3);
  static const Color shadowLight = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF68D391);
  static const Color warning = Color(0xFFF6E05E);
  static const Color error = Color(0xFFF56565);
  static const Color info = Color(0xFF63B3ED);
  
  // Hover state color overlays
  static const Color hoverOverlay = Color(0x0A000000); // Subtle dark overlay
  static const Color activeOverlay = Color(0x14000000); // Stronger dark overlay
}

/// Enum for the different neumorphic styles
enum NeumorphicStyle {
  flat, // Default flat with shadows
  concave, // Surface curves inward
  convex, // Surface bulges outward
  emboss, // Pressed into the background
  pressed, // Pressed in (inner shadow)
}

/// Helper class for generating neumorphic effects
class NeumorphicEffect {
  // Creates an inner shadow effect (pressed state)
  static List<BoxShadow> innerShadow({
    double blurRadius = 8.0,
    double offset = 4.0,
    Color darkShadow = NeumorphicColors.shadowDark,
    Color lightShadow = NeumorphicColors.shadowLight,
  }) {
    return [
      BoxShadow(
        color: darkShadow,
        offset: Offset(offset, offset),
        blurRadius: blurRadius,
        // inset: true,
      ),
      BoxShadow(
        color: lightShadow,
        offset: Offset(-offset, -offset),
        blurRadius: blurRadius,
        //inset: true,
      ),
    ];
  }

  // Creates an outer shadow effect (default state)
  static List<BoxShadow> outerShadow({
    double blurRadius = 8.0,
    double offset = 4.0,
    Color darkShadow = NeumorphicColors.shadowDark,
    Color lightShadow = NeumorphicColors.shadowLight,
  }) {
    return [
      BoxShadow(
        color: darkShadow,
        offset: Offset(offset, offset),
        blurRadius: blurRadius,
      ),
      BoxShadow(
        color: lightShadow,
        offset: Offset(-offset, -offset),
        blurRadius: blurRadius,
      ),
    ];
  }

  // Get decoration based on the specified neumorphic style
  static BoxDecoration getStyleDecoration({
    required NeumorphicStyle style,
    Color color = NeumorphicColors.surface,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(15)),
    double intensity = 1.0,
    double depth = 4.0,
  }) {
    final double blurRadius = 8.0 * intensity;
    final double offset = depth;

    // The gradients help create the concave and convex visual effects
    final LinearGradient? gradient;
    final List<BoxShadow>? shadows;

    switch (style) {
      case NeumorphicStyle.flat:
        gradient = null;
        shadows = outerShadow(blurRadius: blurRadius, offset: offset);
        break;

      case NeumorphicStyle.concave:
        // Concave effect - darker in the middle, lighter at edges
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.brighten(0.15), color.darken(0.15)],
        );
        shadows = outerShadow(blurRadius: blurRadius, offset: offset);
        break;

      case NeumorphicStyle.convex:
        // Convex effect - lighter in the middle, darker at edges
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.darken(0.15), color.brighten(0.15)],
        );
        shadows = outerShadow(blurRadius: blurRadius, offset: offset);
        break;

      case NeumorphicStyle.emboss:
        // Emboss effect - inset shadow with subtle gradient
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.darken(0.1), color.brighten(0.05)],
        );
        shadows = innerShadow(
          blurRadius: blurRadius * 0.8,
          offset: offset * 0.6,
        );
        break;

      case NeumorphicStyle.pressed:
        gradient = null;
        shadows = innerShadow(blurRadius: blurRadius, offset: offset);
        break;
    }

    return BoxDecoration(
      color: gradient == null ? color : null,
      gradient: gradient,
      borderRadius: borderRadius,
      boxShadow: shadows,
    );
  }
}

// Extension methods to lighten and darken colors
extension ColorModifier on Color {
  // Lighten a color by the given percentage (0.0 to 1.0)
  Color brighten(double amount) {
    return Color.fromARGB(
      alpha,
      (red + (255 - red) * amount).round().clamp(0, 255),
      (green + (255 - green) * amount).round().clamp(0, 255),
      (blue + (255 - blue) * amount).round().clamp(0, 255),
    );
  }

  // Darken a color by the given percentage (0.0 to 1.0)
  Color darken(double amount) {
    return Color.fromARGB(
      alpha,
      (red * (1 - amount)).round().clamp(0, 255),
      (green * (1 - amount)).round().clamp(0, 255),
      (blue * (1 - amount)).round().clamp(0, 255),
    );
  }
}

/// Main theme data for the app
ThemeData createNeumorphicTheme() {
  return ThemeData(
    scaffoldBackgroundColor: NeumorphicColors.surface,
    primaryColor: NeumorphicColors.primary,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: NeumorphicColors.primary,
      onPrimary: Colors.white,
      secondary: NeumorphicColors.secondary,
      onSecondary: Colors.white,
      error: NeumorphicColors.error,
      onError: Colors.white,
      background: NeumorphicColors.surface,
      onBackground: NeumorphicColors.textPrimary,
      surface: NeumorphicColors.surface,
      onSurface: NeumorphicColors.textPrimary,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: NeumorphicColors.textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: NeumorphicColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: NeumorphicColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: NeumorphicColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: NeumorphicColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: NeumorphicColors.textPrimary, fontSize: 16),
      bodyMedium: TextStyle(
        color: NeumorphicColors.textSecondary,
        fontSize: 14,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return NeumorphicColors.surface.withOpacity(0.7);
          }
          return NeumorphicColors.surface;
        }),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return NeumorphicColors.textDisabled;
          }
          return NeumorphicColors.primary;
        }),
        elevation: MaterialStateProperty.all(0),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NeumorphicColors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: NeumorphicColors.primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: NeumorphicColors.error, width: 1),
      ),
    ),
    cardTheme: CardThemeData(
      color: NeumorphicColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.all(8),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: NeumorphicColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: NeumorphicColors.primary),
    ),
    iconTheme: IconThemeData(color: NeumorphicColors.primary, size: 24),
    dividerTheme: DividerThemeData(
      color: NeumorphicColors.shadowDark.withOpacity(0.3),
      thickness: 1,
      space: 32,
    ),
  );
}

/// Enhanced Neumorphic Slider implementation with modern interaction
class NeumorphicSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final double height;
  final Duration animationDuration;

  const NeumorphicSlider({
    Key? key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    required this.onChanged,
    this.activeColor = NeumorphicColors.primary,
    this.inactiveColor = NeumorphicColors.shadowDark,
    this.height = 16.0,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  _NeumorphicSliderState createState() => _NeumorphicSliderState();
}

class _NeumorphicSliderState extends State<NeumorphicSlider>
    with SingleTickerProviderStateMixin {
  double _currentDragValue = 0.0;
  bool _isDragging = false;
  bool _isHovered = false;
  double _hoverPosition = 0.0;
  late AnimationController _thumbAnimationController;
  late Animation<double> _thumbScaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentDragValue = widget.value;
    
    _thumbAnimationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _thumbScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _thumbAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(NeumorphicSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isDragging) {
      _currentDragValue = widget.value;
    }
  }

  @override
  void dispose() {
    _thumbAnimationController.dispose();
    super.dispose();
  }

  void _updateValue(double dx, double width) {
    final double newValue =
        (dx / width) * (widget.max - widget.min) + widget.min;
    final double clampedValue = newValue.clamp(widget.min, widget.max);

    if (_currentDragValue != clampedValue) {
      setState(() {
        _currentDragValue = clampedValue;
      });
      widget.onChanged?.call(_currentDragValue);
      
      // Provide haptic feedback but not too often
      if ((clampedValue * 10).round() != (_currentDragValue * 10).round()) {
        HapticFeedback.selectionClick();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onChanged != null;
    final double normalizedValue =
        (widget.value - widget.min) / (widget.max - widget.min);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double thumbPosition = normalizedValue * width;
        final double thumbSize = widget.height * 1.8;

        return MouseRegion(
          onEnter: isEnabled ? (_) {
            setState(() => _isHovered = true);
            _thumbAnimationController.forward();
          } : null,
          onExit: isEnabled ? (_) {
            setState(() => _isHovered = false);
            if (!_isDragging) _thumbAnimationController.reverse();
          } : null,
          onHover: isEnabled ? (event) {
            setState(() {
              _hoverPosition = event.localPosition.dx.clamp(0, width);
            });
          } : null,
          cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onHorizontalDragStart: isEnabled
                ? (details) {
                    setState(() {
                      _isDragging = true;
                    });
                    _thumbAnimationController.forward();
                    _updateValue(details.localPosition.dx, width);
                    HapticFeedback.mediumImpact();
                  }
                : null,
            onHorizontalDragUpdate: isEnabled
                ? (details) {
                    _updateValue(details.localPosition.dx, width);
                  }
                : null,
            onHorizontalDragEnd: isEnabled
                ? (details) {
                    setState(() {
                      _isDragging = false;
                    });
                    if (!_isHovered) _thumbAnimationController.reverse();
                    HapticFeedback.lightImpact();
                  }
                : null,
            onTapDown: isEnabled
                ? (details) {
                    _thumbAnimationController.forward();
                    _updateValue(details.localPosition.dx, width);
                    HapticFeedback.mediumImpact();
                  }
                : null,
            onTap: isEnabled
                ? () {
                    if (!_isHovered) _thumbAnimationController.reverse();
                  }
                : null,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Track background
                AnimatedContainer(
                  duration: widget.animationDuration,
                  height: widget.height,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: NeumorphicColors.surface,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    boxShadow: NeumorphicEffect.innerShadow(
                      blurRadius: 4.0,
                      offset: 2.0,
                    ),
                  ),
                ),
                
                // Active track
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: thumbPosition,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: widget.activeColor,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    boxShadow: [
                      BoxS