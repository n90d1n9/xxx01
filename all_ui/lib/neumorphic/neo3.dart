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

/// Neumorphic Button styles
class NeumorphicButtonStyle {
  static BoxDecoration defaultDecoration = BoxDecoration(
    color: NeumorphicColors.surface,
    borderRadius: BorderRadius.circular(15),
    boxShadow: NeumorphicEffect.outerShadow(),
  );

  static BoxDecoration pressedDecoration = BoxDecoration(
    color: NeumorphicColors.surface,
    borderRadius: BorderRadius.circular(15),
    boxShadow: NeumorphicEffect.innerShadow(),
  );

  static BoxDecoration disabledDecoration = BoxDecoration(
    color: NeumorphicColors.surface.withOpacity(0.7),
    borderRadius: BorderRadius.circular(15),
  );

  static BoxDecoration concaveDecoration = NeumorphicEffect.getStyleDecoration(
    style: NeumorphicStyle.concave,
    borderRadius: BorderRadius.circular(15),
  );

  static BoxDecoration convexDecoration = NeumorphicEffect.getStyleDecoration(
    style: NeumorphicStyle.convex,
    borderRadius: BorderRadius.circular(15),
  );

  static BoxDecoration embossDecoration = NeumorphicEffect.getStyleDecoration(
    style: NeumorphicStyle.emboss,
    borderRadius: BorderRadius.circular(15),
  );
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

/*
/// Enhanced NeumorphicButton with trendy hover and press effects
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double width;
  final double height;
  final NeumorphicStyle style;
  final NeumorphicStyle pressedStyle;
  final BorderRadius borderRadius;
  final Color color;
  final double intensity;
  final double depth;
  final Duration animationDuration;

  const NeumorphicButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.width = double.infinity,
    this.height = 50,
    this.style = NeumorphicStyle.flat,
    this.pressedStyle = NeumorphicStyle.pressed,
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
    this.color = NeumorphicColors.surface,
    this.intensity = 1.0,
    this.depth = 4.0,
    this.animationDuration = const Duration(milliseconds: 150),
  }) : super(key: key);

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _depthAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _depthAnimation = Tween<double>(
      begin: widget.depth,
      end: widget.depth * 0.5,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;

    // Determine which style to use
    final NeumorphicStyle currentStyle =
        !isEnabled
            ? NeumorphicStyle
                .flat // Disabled state
            : (_isPressed ? widget.pressedStyle : widget.style);

    final Color buttonColor =
        isEnabled ? widget.color : widget.color.withOpacity(0.7);

    // Add hover overlay if hovering
    final Color effectiveColor =
        isEnabled && _isHovered && !_isPressed
            ? Color.alphaBlend(NeumorphicColors.hoverOverlay, buttonColor)
            : buttonColor;

    return MouseRegion(
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown:
            isEnabled
                ? (_) {
                  setState(() => _isPressed = true);
                  _animationController.forward();
                  HapticFeedback.lightImpact(); // Add haptic feedback
                }
                : null,
        onTapUp:
            isEnabled
                ? (_) {
                  setState(() => _isPressed = false);
                  _animationController.reverse();
                }
                : null,
        onTapCancel:
            isEnabled
                ? () {
                  setState(() => _isPressed = false);
                  _animationController.reverse();
                }
                : null,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: widget.animationDuration,
                curve: Curves.easeOutCubic,
                width: widget.width,
                height: widget.height,
                padding: widget.padding,
                decoration:
                    isEnabled
                        ? NeumorphicEffect.getStyleDecoration(
                          style: currentStyle,
                          color: effectiveColor,
                          borderRadius: widget.borderRadius,
                          intensity: widget.intensity,
                          depth: _depthAnimation.value,
                        )
                        : BoxDecoration(
                          color: effectiveColor,
                          borderRadius: widget.borderRadius,
                        ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: widget.animationDuration,
                    style: TextStyle(
                      color:
                          isEnabled
                              ? NeumorphicColors.primary
                              : NeumorphicColors.textDisabled,
                      fontWeight:
                          _isPressed ? FontWeight.w700 : FontWeight.w600,
                      fontSize: _isPressed ? 15.0 : 16.0,
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
*/
/* 
/// Enhanced Neumorphic Switch implementation with modern effects
class NeumorphicSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;
  final Duration animationDuration;

  const NeumorphicSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor = NeumorphicColors.primary,
    this.inactiveColor = NeumorphicColors.shadowDark,
    this.width = 60.0,
    this.height = 30.0,
    this.animationDuration = const Duration(milliseconds: 250),
  }) : super(key: key);

  @override
  _NeumorphicSwitchState createState() => _NeumorphicSwitchState();
}

class _NeumorphicSwitchState extends State<NeumorphicSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: widget.value ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(NeumorphicSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onChanged != null;
    final Color trackColor =
        isEnabled
            ? (widget.value ? widget.activeColor : NeumorphicColors.surface)
            : NeumorphicColors.surface.withOpacity(0.7);

    // Add hover effect
    final Color effectiveTrackColor =
        isEnabled && _isHovered
            ? trackColor.brighten(widget.value ? 0.05 : 0.08)
            : trackColor;

    return MouseRegion(
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap:
            isEnabled
                ? () {
                  widget.onChanged?.call(!widget.value);
                  HapticFeedback.lightImpact(); // Add haptic feedback
                }
                : null,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: effectiveTrackColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow:
                widget.value
                    ? null
                    : NeumorphicEffect.innerShadow(blurRadius: 4, offset: 2),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // Thumb position
              double position =
                  _animation.value * (widget.width - widget.height);
              // For a springy effect, we'll apply a scale based on animation value
              double scale = 1.0 + (_animation.value * 0.1);
              if (_animation.value < 0.1)
                scale = 1.0 + (_animation.value * 0.3);

              return Stack(
                children: [
                  // Glow effect when active
                  if (widget.value)
                    Positioned(
                      left: position + (widget.height * 0.2),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 150),
                        width: widget.height * 0.8,
                        height: widget.height * 0.8,
                        decoration: BoxDecoration(
                          color: widget.activeColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  // Thumb
                  Positioned(
                    left: position,
                    child: Transform.scale(
                      scale: scale,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 150),
                        width: widget.height,
                        height: widget.height,
                        decoration: BoxDecoration(
                          color: NeumorphicColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: NeumorphicEffect.outerShadow(
                            blurRadius: 4.0,
                            offset: _isHovered ? 3.0 : 2.0,
                          ),
                        ),
                        child:
                            widget.value
                                ? Center(
                                  child: Container(
                                    width: widget.height * 0.35,
                                    height: widget.height * 0.35,
                                    decoration: BoxDecoration(
                                      color: widget.activeColor.brighten(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                                : null,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
 */
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
          onEnter:
              isEnabled
                  ? (_) {
                    setState(() => _isHovered = true);
                    _thumbAnimationController.forward();
                  }
                  : null,
          onExit:
              isEnabled
                  ? (_) {
                    setState(() => _isHovered = false);
                    if (!_isDragging) _thumbAnimationController.reverse();
                  }
                  : null,
          onHover:
              isEnabled
                  ? (event) {
                    setState(() {
                      _hoverPosition = event.localPosition.dx.clamp(0, width);
                    });
                  }
                  : null,
          cursor:
              isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onHorizontalDragStart:
                isEnabled
                    ? (details) {
                      setState(() {
                        _isDragging = true;
                      });
                      _thumbAnimationController.forward();
                      _updateValue(details.localPosition.dx, width);
                      HapticFeedback.mediumImpact();
                    }
                    : null,
            onHorizontalDragUpdate:
                isEnabled
                    ? (details) {
                      _updateValue(details.localPosition.dx, width);
                    }
                    : null,
            onHorizontalDragEnd:
                isEnabled
                    ? (details) {
                      setState(() {
                        _isDragging = false;
                      });
                      if (!_isHovered) _thumbAnimationController.reverse();
                      HapticFeedback.lightImpact();
                    }
                    : null,
            onTapDown:
                isEnabled
                    ? (details) {
                      _thumbAnimationController.forward();
                      _updateValue(details.localPosition.dx, width);
                      HapticFeedback.mediumImpact();
                    }
                    : null,
            onTap:
                isEnabled
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
                      BoxShadow(
                        color: widget.activeColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                // Hover effect
                if (_isHovered && isEnabled && !_isDragging)
                  Positioned(
                    left: _hoverPosition - 10,
                    top: -5,
                    child: Container(
                      width: 20,
                      height: widget.height + 10,
                      decoration: BoxDecoration(
                        color: widget.activeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                // Thumb
                AnimatedPositioned(
                  duration:
                      _isDragging
                          ? Duration.zero
                          : const Duration(milliseconds: 100),
                  left: thumbPosition - (thumbSize / 2),
                  top: -(thumbSize - widget.height) / 2,
                  child: AnimatedBuilder(
                    animation: _thumbScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _thumbScaleAnimation.value,
                        child: Container(
                          width: thumbSize,
                          height: thumbSize,
                          decoration: BoxDecoration(
                            color:
                                isEnabled
                                    ? widget.activeColor
                                    : widget.activeColor.withOpacity(0.5),
                            shape: BoxShape.circle,
                            boxShadow: NeumorphicEffect.outerShadow(
                              blurRadius: 5.0,
                              offset: 2.0,
                              darkShadow: NeumorphicColors.shadowDark
                                  .withOpacity(0.5),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: thumbSize * 0.6,
                              height: thumbSize * 0.6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    widget.activeColor.brighten(0.2),
                                    widget.activeColor,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A neumorphic switch component with smooth animations
class NeumorphicSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;
  final double width;
  final double height;
  final Duration animationDuration;

  const NeumorphicSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor = NeumorphicColors.primary,
    this.inactiveColor = NeumorphicColors.shadowDark,
    this.thumbColor = Colors.white,
    this.width = 60.0,
    this.height = 30.0,
    this.animationDuration = const Duration(milliseconds: 250),
  }) : super(key: key);

  @override
  _NeumorphicSwitchState createState() => _NeumorphicSwitchState();
}

class _NeumorphicSwitchState extends State<NeumorphicSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _thumbAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _thumbAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      ),
    );

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(_animationController);

    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(NeumorphicSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    if (widget.activeColor != oldWidget.activeColor ||
        widget.inactiveColor != oldWidget.inactiveColor) {
      _colorAnimation = ColorTween(
        begin: widget.inactiveColor,
        end: widget.activeColor,
      ).animate(_animationController);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged != null) {
      HapticFeedback.lightImpact();
      widget.onChanged!(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onChanged != null;
    final double thumbSize = widget.height * 0.8;
    final double trackPadding = (widget.height - thumbSize) / 2;

    return MouseRegion(
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isEnabled ? _handleTap : null,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.6,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 150),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: NeumorphicColors.surface,
              borderRadius: BorderRadius.circular(widget.height / 2),
              boxShadow:
                  _isHovered
                      ? []
                      : NeumorphicEffect.innerShadow(
                        blurRadius: 4.0,
                        offset: 2.0,
                      ),
            ),
            child: Stack(
              children: [
                // Track background with animated color
                AnimatedBuilder(
                  animation: _colorAnimation,
                  builder: (context, child) {
                    return Container(
                      margin: EdgeInsets.all(trackPadding / 2),
                      decoration: BoxDecoration(
                        color: _colorAnimation.value?.withOpacity(
                          _isHovered ? 0.7 : 0.5,
                        ),
                        borderRadius: BorderRadius.circular(widget.height / 2),
                      ),
                    );
                  },
                ),

                // Thumb with position animation
                AnimatedBuilder(
                  animation: _thumbAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left:
                          trackPadding +
                          _thumbAnimation.value *
                              (widget.width - thumbSize - trackPadding * 2),
                      top: trackPadding,
                      child: Transform.scale(
                        scale: _isHovered ? 1.1 : 1.0,
                        child: Container(
                          width: thumbSize,
                          height: thumbSize,
                          decoration: BoxDecoration(
                            color: widget.thumbColor,
                            shape: BoxShape.circle,
                            boxShadow: NeumorphicEffect.outerShadow(
                              blurRadius: 3.0,
                              offset: 1.0,
                              darkShadow: NeumorphicColors.shadowDark
                                  .withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A neumorphic checkbox with smooth animations
class NeumorphicCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color checkColor;
  final double size;
  final Duration animationDuration;
  final BorderRadius? borderRadius;

  const NeumorphicCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor = NeumorphicColors.primary,
    this.checkColor = Colors.white,
    this.size = 24.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.borderRadius,
  }) : super(key: key);

  @override
  _NeumorphicCheckboxState createState() => _NeumorphicCheckboxState();
}

class _NeumorphicCheckboxState extends State<NeumorphicCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );

    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(NeumorphicCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged != null) {
      HapticFeedback.selectionClick();
      widget.onChanged!(!widget.value);
    }
  }

  NeumorphicStyle _getStyle() {
    if (_isPressed) {
      return NeumorphicStyle.pressed;
    }
    if (widget.value) {
      return NeumorphicStyle.flat;
    }
    return _isHovered ? NeumorphicStyle.concave : NeumorphicStyle.flat;
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onChanged != null;
    final BorderRadius borderRadius =
        widget.borderRadius ?? BorderRadius.circular(widget.size * 0.2);

    return MouseRegion(
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isEnabled ? _handleTap : null,
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel:
            isEnabled ? () => setState(() => _isPressed = false) : null,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.6,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 150),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color:
                  widget.value ? widget.activeColor : NeumorphicColors.surface,
              borderRadius: borderRadius,
              boxShadow:
                  widget.value
                      ? NeumorphicEffect.outerShadow(
                        blurRadius: 4.0,
                        offset: 2.0,
                        darkShadow: widget.activeColor
                            .darken(0.2)
                            .withOpacity(0.5),
                        lightShadow: widget.activeColor
                            .brighten(0.2)
                            .withOpacity(0.5),
                      )
                      : (_isPressed
                          ? NeumorphicEffect.innerShadow(
                            blurRadius: 2.0,
                            offset: 1.0,
                          )
                          : NeumorphicEffect.outerShadow(
                            blurRadius: 4.0,
                            offset: 2.0,
                          )),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _checkAnimation.value,
                      child: Icon(
                        Icons.check,
                        size: widget.size * 0.7,
                        color: widget.checkColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A neumorphic icon button with hover and press animations
class NeumorphicIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color iconColor;
  final double size;
  final double padding;
  final Duration animationDuration;
  final BorderRadius? borderRadius;

  const NeumorphicIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.iconColor = NeumorphicColors.primary,
    this.size = 56.0,
    this.padding = 12.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.borderRadius,
  }) : super(key: key);

  @override
  _NeumorphicIconButtonState createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<NeumorphicIconButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  NeumorphicStyle _getStyle() {
    if (_isPressed) {
      return NeumorphicStyle.pressed;
    }
    if (_isHovered) {
      return NeumorphicStyle.concave;
    }
    return NeumorphicStyle.flat;
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final BorderRadius borderRadius =
        widget.borderRadius ?? BorderRadius.circular(widget.size / 4);
    final totalSize = widget.size + (widget.padding * 2);

    return MouseRegion(
      onEnter:
          isEnabled
              ? (_) {
                setState(() => _isHovered = true);
                _animationController.forward(from: 0.0);
              }
              : null,
      onExit:
          isEnabled
              ? (_) {
                setState(() => _isHovered = false);
                if (!_isPressed) {
                  _animationController.reverse();
                }
              }
              : null,
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap:
            widget.onPressed != null
                ? () {
                  HapticFeedback.mediumImpact();
                  widget.onPressed?.call();
                }
                : null,
        onTapDown:
            isEnabled
                ? (_) {
                  setState(() => _isPressed = true);
                  _animationController.forward();
                }
                : null,
        onTapUp:
            isEnabled
                ? (_) {
                  setState(() => _isPressed = false);
                  if (!_isHovered) {
                    _animationController.reverse();
                  }
                }
                : null,
        onTapCancel:
            isEnabled
                ? () {
                  setState(() => _isPressed = false);
                  if (!_isHovered) {
                    _animationController.reverse();
                  }
                }
                : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                width: totalSize,
                height: totalSize,
                decoration: NeumorphicEffect.getStyleDecoration(
                  style: _getStyle(),
                  borderRadius: borderRadius,
                  intensity: _isHovered ? 1.2 : 1.0,
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: widget.size / 2,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A neumorphic radio button with smooth animations
class NeumorphicRadio<T> extends StatefulWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T>? onChanged;
  final Widget? child;
  final Color activeColor;
  final double size;
  final double innerCircleSize;
  final Duration animationDuration;

  const NeumorphicRadio({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.child,
    this.activeColor = NeumorphicColors.primary,
    this.size = 24.0,
    this.innerCircleSize = 12.0,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  _NeumorphicRadioState<T> createState() => _NeumorphicRadioState<T>();
}

class _NeumorphicRadioState<T> extends State<NeumorphicRadio<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    if (widget.value == widget.groupValue) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(NeumorphicRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value == widget.groupValue &&
        oldWidget.value != oldWidget.groupValue) {
      _animationController.forward();
    } else if (widget.value != widget.groupValue &&
        oldWidget.value == oldWidget.groupValue) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged != null && widget.value != widget.groupValue) {
      HapticFeedback.selectionClick();
      widget.onChanged!(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onChanged != null;
    final bool isSelected = widget.value == widget.groupValue;

    Widget radioButton = MouseRegion(
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isEnabled ? _handleTap : null,
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel:
            isEnabled ? () => setState(() => _isPressed = false) : null,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.6,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 150),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: NeumorphicColors.surface,
              shape: BoxShape.circle,
              boxShadow:
                  _isPressed || isSelected
                      ? NeumorphicEffect.innerShadow(
                        blurRadius: 2.0,
                        offset: 1.0,
                      )
                      : NeumorphicEffect.outerShadow(
                        blurRadius: 4.0,
                        offset: 2.0,
                      ),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: widget.innerCircleSize,
                      height: widget.innerCircleSize,
                      decoration: BoxDecoration(
                        color: widget.activeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.activeColor.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.child != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          radioButton,
          SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onTap: isEnabled ? _handleTap : null,
              child: widget.child!,
            ),
          ),
        ],
      );
    }

    return radioButton;
  }
}

/// A neumorphic card with hover and press animations
class NeumorphicCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double elevation;
  final Duration animationDuration;
  final Color? color;

  const NeumorphicCard({
    Key? key,
    required this.child,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.elevation = 4.0,
    this.animationDuration = const Duration(milliseconds: 150),
    this.color,
  }) : super(key: key);

  @override
  _NeumorphicCardState createState() => _NeumorphicCardState();
}

class _NeumorphicCardState extends State<NeumorphicCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  NeumorphicStyle _getStyle() {
    if (_isPressed) {
      return NeumorphicStyle.pressed;
    }
    if (_isHovered) {
      return NeumorphicStyle.concave;
    }
    return NeumorphicStyle.flat;
  }

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = widget.onTap != null;
    final Color backgroundColor = widget.color ?? NeumorphicColors.surface;

    return MouseRegion(
      onEnter: isInteractive ? (_) => setState(() => _isHovered = true) : null,
      onExit: isInteractive ? (_) => setState(() => _isHovered = false) : null,
      cursor:
          isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown:
            isInteractive ? (_) => setState(() => _isPressed = true) : null,
        onTapUp:
            isInteractive ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel:
            isInteractive ? () => setState(() => _isPressed = false) : null,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          decoration: NeumorphicEffect.getStyleDecoration(
            style: _getStyle(),
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            depth: widget.elevation,
            intensity: _isHovered ? 1.2 : 1.0,
          ),
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}

/// A neumorphic input field with focus and hover effects
class NeumorphicTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final double borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const NeumorphicTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.decoration,
    this.style,
    this.hintStyle,
    this.borderRadius = 15.0,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  _NeumorphicTextFieldState createState() => _NeumorphicTextFieldState();
}

class _NeumorphicTextFieldState extends State<NeumorphicTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(
      widget.borderRadius,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: NeumorphicColors.surface,
          borderRadius: borderRadius,
          boxShadow:
              _isFocused
                  ? [
                    BoxShadow(
                      color: NeumorphicColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                    ...NeumorphicEffect.innerShadow(
                      blurRadius: 4.0,
                      offset: 2.0,
                    ),
                  ]
                  : (_isHovered
                      ? NeumorphicEffect.innerShadow(
                        blurRadius: 3.0,
                        offset: 1.5,
                      )
                      : NeumorphicEffect.innerShadow(
                        blurRadius: 4.0,
                        offset: 2.0,
                      )),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          onChanged: widget.onChanged,
          style:
              widget.style ??
              TextStyle(color: NeumorphicColors.textPrimary, fontSize: 16),
          decoration: (widget.decoration ?? InputDecoration()).copyWith(
            hintText: widget.hintText,
            hintStyle:
                widget.hintStyle ??
                TextStyle(
                  color: NeumorphicColors.textSecondary.withOpacity(0.7),
                  fontSize: 16,
                ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: NeumorphicColors.primary,
                width: 1.0,
              ),
            ),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}

/// A neumorphic button with hover, press animations and ripple effect
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Duration animationDuration;
  final double minWidth;
  final double height;

  const NeumorphicButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.color = NeumorphicColors.surface,
    this.borderRadius = 15.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.animationDuration = const Duration(milliseconds: 200),
    this.minWidth = 120.0,
    this.height = 48.0,
  }) : super(key: key);

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  NeumorphicStyle _getStyle() {
    if (_isPressed) {
      return NeumorphicStyle.pressed;
    }
    if (_isHovered) {
      return NeumorphicStyle.concave;
    }
    return NeumorphicStyle.flat;
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final BorderRadius borderRadius = BorderRadius.circular(
      widget.borderRadius,
    );

    return MouseRegion(
      onEnter:
          isEnabled
              ? (_) {
                setState(() => _isHovered = true);
                _animationController.forward(from: 0.0);
              }
              : null,
      onExit:
          isEnabled
              ? (_) {
                setState(() => _isHovered = false);
                if (!_isPressed) {
                  _animationController.reverse();
                }
              }
              : null,
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap:
            widget.onPressed != null
                ? () {
                  HapticFeedback.mediumImpact();
                  widget.onPressed?.call();
                }
                : null,
        onTapDown:
            isEnabled
                ? (_) {
                  setState(() => _isPressed = true);
                  _animationController.forward();
                }
                : null,
        onTapUp:
            isEnabled
                ? (_) {
                  setState(() => _isPressed = false);
                  if (!_isHovered) {
                    _animationController.reverse();
                  }
                }
                : null,
        onTapCancel:
            isEnabled
                ? () {
                  setState(() => _isPressed = false);
                  if (!_isHovered) {
                    _animationController.reverse();
                  }
                }
                : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                constraints: BoxConstraints(
                  minWidth: widget.minWidth,
                  minHeight: widget.height,
                ),
                decoration: NeumorphicEffect.getStyleDecoration(
                  style: _getStyle(),
                  color: widget.color,
                  borderRadius: borderRadius,
                  intensity: _isHovered ? 1.2 : 1.0,
                ),
                padding: widget.padding,
                child: Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color:
                          isEnabled
                              ? NeumorphicColors.primary
                              : NeumorphicColors.textDisabled,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A neumorphic toggle button group with exclusive selection
class NeumorphicToggleButton<T> extends StatefulWidget {
  final List<T> values;
  final List<Widget> children;
  final T? selectedValue;
  final ValueChanged<T>? onChanged;
  final Color backgroundColor;
  final Color selectedColor;
  final Color textColor;
  final Color selectedTextColor;
  final double height;
  final double borderRadius;
  final Duration animationDuration;

  const NeumorphicToggleButton({
    Key? key,
    required this.values,
    required this.children,
    this.selectedValue,
    required this.onChanged,
    this.backgroundColor = NeumorphicColors.surface,
    this.selectedColor = NeumorphicColors.primary,
    this.textColor = NeumorphicColors.textPrimary,
    this.selectedTextColor = Colors.white,
    this.height = 44.0,
    this.borderRadius = 15.0,
    this.animationDuration = const Duration(milliseconds: 250),
  }) : assert(values.length == children.length),
       super(key: key);

  @override
  _NeumorphicToggleButtonState<T> createState() =>
      _NeumorphicToggleButtonState<T>();
}

class _NeumorphicToggleButtonState<T> extends State<NeumorphicToggleButton<T>> {
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onChanged != null;
    final int selectedIndex =
        widget.selectedValue != null
            ? widget.values.indexOf(widget.selectedValue!)
            : -1;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: NeumorphicEffect.innerShadow(blurRadius: 4.0, offset: 2.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Row(
          children: List.generate(widget.values.length, (index) {
            final bool isSelected = index == selectedIndex;
            final bool isHovered = index == _hoveredIndex;

            return Expanded(
              child: Stack(
                children: [
                  if (isSelected)
                    AnimatedContainer(
                      duration: widget.animationDuration,
                      decoration: BoxDecoration(
                        color: widget.selectedColor,
                        borderRadius: BorderRadius.circular(
                          widget.borderRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.selectedColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  MouseRegion(
                    onEnter:
                        isEnabled
                            ? (_) => setState(() => _hoveredIndex = index)
                            : null,
                    onExit:
                        isEnabled
                            ? (_) => setState(() => _hoveredIndex = -1)
                            : null,
                    cursor:
                        isEnabled
                            ? SystemMouseCursors.click
                            : SystemMouseCursors.basic,
                    child: GestureDetector(
                      onTap:
                          isEnabled && !isSelected
                              ? () {
                                HapticFeedback.selectionClick();
                                widget.onChanged!(widget.values[index]);
                              }
                              : null,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color:
                              isHovered && !isSelected
                                  ? NeumorphicColors.shadowLight.withOpacity(
                                    0.1,
                                  )
                                  : Colors.transparent,
                        ),
                        alignment: Alignment.center,
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color:
                                isSelected
                                    ? widget.selectedTextColor
                                    : widget.textColor,
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          child: widget.children[index],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// A neumorphic progress indicator with animated fill
class NeumorphicProgressBar extends StatefulWidget {
  final double value;
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final double borderRadius;
  final Duration animationDuration;
  final bool showPercentage;
  final TextStyle? percentageTextStyle;

  const NeumorphicProgressBar({
    Key? key,
    required this.value,
    this.height = 16.0,
    this.backgroundColor = NeumorphicColors.surface,
    this.progressColor = NeumorphicColors.primary,
    this.borderRadius = 8.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showPercentage = false,
    this.percentageTextStyle,
  }) : assert(value >= 0.0 && value <= 1.0),
       super(key: key);

  @override
  _NeumorphicProgressBarState createState() => _NeumorphicProgressBarState();
}

class _NeumorphicProgressBarState extends State<NeumorphicProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(NeumorphicProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ),
      );
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height + (widget.showPercentage ? 24 : 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: NeumorphicEffect.innerShadow(
                blurRadius: 4.0,
                offset: 2.0,
              ),
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: _animation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.progressColor,
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.progressColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.showPercentage)
                      Positioned(
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Text(
                            '${(_animation.value * 100).toInt()}%',
                            style:
                                widget.percentageTextStyle ??
                                TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (widget.showPercentage)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Text(
                    '${(_animation.value * 100).toInt()}%',
                    style: TextStyle(
                      color: NeumorphicColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// A customizable neumorphic circular progress indicator
class NeumorphicCircularProgress extends StatefulWidget {
  final double value;
  final double size;
  final double thickness;
  final Color backgroundColor;
  final Color progressColor;
  final Duration animationDuration;
  final bool showPercentage;
  final TextStyle? percentageTextStyle;
  final Widget? child;

  const NeumorphicCircularProgress({
    Key? key,
    required this.value,
    this.size = 120.0,
    this.thickness = 12.0,
    this.backgroundColor = NeumorphicColors.surface,
    this.progressColor = NeumorphicColors.primary,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showPercentage = false,
    this.percentageTextStyle,
    this.child,
  }) : assert(value >= 0.0 && value <= 1.0),
       super(key: key);

  @override
  _NeumorphicCircularProgressState createState() =>
      _NeumorphicCircularProgressState();
}

class _NeumorphicCircularProgressState extends State<NeumorphicCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(NeumorphicCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ),
      );
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          // Outer shadow for 3D effect
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: NeumorphicColors.surface,
              boxShadow: NeumorphicEffect.outerShadow(
                blurRadius: 8.0,
                offset: 4.0,
              ),
            ),
          ),

          // Inner background circle with inner shadow
          Center(
            child: Container(
              width: widget.size - widget.thickness * 2,
              height: widget.size - widget.thickness * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NeumorphicColors.surface,
                boxShadow: NeumorphicEffect.innerShadow(
                  blurRadius: 4.0,
                  offset: 2.0,
                ),
              ),
              child:
                  widget.child != null
                      ? Center(child: widget.child)
                      : widget.showPercentage
                      ? AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Center(
                            child: Text(
                              '${(_animation.value * 100).toInt()}%',
                              style:
                                  widget.percentageTextStyle ??
                                  TextStyle(
                                    color: NeumorphicColors.textPrimary,
                                    fontSize: widget.size / 6,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          );
                        },
                      )
                      : null,
            ),
          ),

          // Progress arc
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircularProgressPainter(
                  progress: _animation.value,
                  progressColor: widget.progressColor,
                  backgroundColor: widget.backgroundColor,
                  thickness: widget.thickness,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double thickness;

  _CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round;

    final progressPaint =
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round;

    // Draw background arc
    canvas.drawArc(
      rect,
      -1.5708, // Start at the top (90 degrees or pi/2 radians)
      2 * 3.14159, // Full circle
      false,
      backgroundPaint,
    );

    // Draw progress arc
    canvas.drawArc(
      rect,
      -1.5708, // Start at the top
      2 * 3.14159 * progress, // Arc angle based on progress
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.thickness != thickness;
  }
}

/// A neumorphic divider with enhanced 3D effect
class NeumorphicDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color? color;
  final double indent;
  final double endIndent;

  const NeumorphicDivider({
    Key? key,
    this.height = 32.0,
    this.thickness = 1.0,
    this.color,
    this.indent = 0.0,
    this.endIndent = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(vertical: (height - thickness) / 2),
      child: Row(
        children: [
          SizedBox(width: indent),
          Expanded(
            child: Container(
              height: thickness,
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: (color ?? NeumorphicColors.shadowDark).withOpacity(
                      0.3,
                    ),
                    offset: Offset(0, 1),
                    blurRadius: 1,
                  ),
                  BoxShadow(
                    color: NeumorphicColors.shadowLight.withOpacity(0.7),
                    offset: Offset(0, -1),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: endIndent),
        ],
      ),
    );
  }
}

/// Example usage demonstration of neumorphic widgets
class NeumorphicWidgetsDemo extends StatefulWidget {
  @override
  _NeumorphicWidgetsDemoState createState() => _NeumorphicWidgetsDemoState();
}

class _NeumorphicWidgetsDemoState extends State<NeumorphicWidgetsDemo> {
  double _sliderValue = 0.4;
  bool _switchValue = true;
  bool _checkboxValue = true;
  String _selectedOption = "Option 1";
  double _progressValue = 0.65;
  TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicColors.surface,
      appBar: AppBar(
        title: Text("Neumorphic Widgets"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Neumorphic UI Components",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: NeumorphicColors.textPrimary,
              ),
            ),
            SizedBox(height: 32),

            // Slider example
            Text(
              "Slider",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            NeumorphicSlider(
              value: _sliderValue,
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
            ),
            SizedBox(height: 24),

            // Switch example
            Text(
              "Switch",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            NeumorphicSwitch(
              value: _switchValue,
              onChanged: (value) {
                setState(() {
                  _switchValue = value;
                });
              },
            ),
            SizedBox(height: 24),

            // Checkbox example
            Text(
              "Checkbox",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            NeumorphicCheckbox(
              value: _checkboxValue,
              onChanged: (value) {
                setState(() {
                  _checkboxValue = value;
                });
              },
            ),
            SizedBox(height: 24),

            // Button example
            Text(
              "Button",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            NeumorphicButton(
              onPressed: () {
                // Button action
              },
              child: Text("Click Me"),
            ),
            SizedBox(height: 24),

            // Icon Button example
            Text(
              "Icon Button",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NeumorphicIconButton(
                  icon: Icons.favorite,
                  onPressed: () {
                    // Icon button action
                  },
                ),
                NeumorphicIconButton(
                  icon: Icons.star,
                  onPressed: () {
                    // Icon button action
                  },
                ),
                NeumorphicIconButton(
                  icon: Icons.lightbulb,
                  onPressed: () {
                    // Icon button action
                  },
                ),
              ],
            ),
            SizedBox(height: 24),

            // Radio button example
            Text(
              "Radio Buttons",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Column(
              children: [
                NeumorphicRadio<String>(
                  value: "Option 1",
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value;
                    });
                  },
                  child: Text("Option 1"),
                ),
                SizedBox(height: 12),
                NeumorphicRadio<String>(
                  value: "Option 2",
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value;
                    });
                  },
                  child: Text("Option 2"),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Toggle button example
            Text(
              "Toggle Button",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            NeumorphicToggleButton<String>(
              values: ["Day", "Night", "Auto"],
              children: [Text("Day"), Text("Night"), Text("Auto")],
              selectedValue: "Day",
              onChanged: (value) {
                // Toggle button action
              },
            ),
            SizedBox(height: 24),

            // Progress bar example
            Text(
              "Progress Bar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            NeumorphicProgressBar(value: _progressValue, showPercentage: true),
            SizedBox(height: 24),

            // Circular progress example
            Text(
              "Circular Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Center(
              child: NeumorphicCircularProgress(
                value: _progressValue,
                showPercentage: true,
              ),
            ),
            SizedBox(height: 24),

            // Text field example
            Text(
              "Text Field",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            NeumorphicTextField(
              controller: _textController,
              hintText: "Enter text here...",
              prefixIcon: Icon(Icons.search, color: NeumorphicColors.primary),
            ),
            SizedBox(height: 24),

            // Card example
            Text(
              "Card",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            NeumorphicCard(
              onTap: () {
                // Card tap action
              },
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Neumorphic Card",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: NeumorphicColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "This is a card with neumorphic styling that can be tapped.",
                      style: TextStyle(color: NeumorphicColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Divider example
            Text(
              "Divider",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            NeumorphicDivider(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Example application using the neumorphic theme
void main() {
  runApp(MyNeumorphicApp());
}

class MyNeumorphicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neumorphic Flutter Demo',
      theme: createNeumorphicTheme(),
      debugShowCheckedModeBanner: false,
      home: NeumorphicWidgetsDemo(),
    );
  }
}
