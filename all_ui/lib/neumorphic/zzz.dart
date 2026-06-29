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

/// Example of implementing a custom NeumorphicButton
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
  }) : super(key: key);

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

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

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration:
            isEnabled
                ? NeumorphicEffect.getStyleDecoration(
                  style: currentStyle,
                  color: buttonColor,
                  borderRadius: widget.borderRadius,
                  intensity: widget.intensity,
                  depth: widget.depth,
                )
                : BoxDecoration(
                  color: buttonColor,
                  borderRadius: widget.borderRadius,
                ),
        child: Center(child: widget.child),
      ),
    );
  }
}

/// Neumorphic Switch implementation
class NeumorphicSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;

  const NeumorphicSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor = NeumorphicColors.primary,
    this.inactiveColor = NeumorphicColors.shadowDark,
    this.width = 60.0,
    this.height = 30.0,
  }) : super(key: key);

  @override
  _NeumorphicSwitchState createState() => _NeumorphicSwitchState();
}

class _NeumorphicSwitchState extends State<NeumorphicSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      value: widget.value ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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

    return GestureDetector(
      onTap: isEnabled ? () => widget.onChanged?.call(!widget.value) : null,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(widget.height / 2),
          boxShadow:
              widget.value
                  ? null
                  : NeumorphicEffect.innerShadow(blurRadius: 4, offset: 2),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  left: _animation.value * (widget.width - widget.height),
                  child: Container(
                    width: widget.height,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: NeumorphicColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: NeumorphicEffect.outerShadow(
                        blurRadius: 4.0,
                        offset: 2.0,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Neumorphic Slider implementation
class NeumorphicSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final double height;

  const NeumorphicSlider({
    Key? key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    required this.onChanged,
    this.activeColor = NeumorphicColors.primary,
    this.inactiveColor = NeumorphicColors.shadowDark,
    this.height = 16.0,
  }) : super(key: key);

  @override
  _NeumorphicSliderState createState() => _NeumorphicSliderState();
}

class _NeumorphicSliderState extends State<NeumorphicSlider> {
  double _currentDragValue = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentDragValue = widget.value;
  }

  @override
  void didUpdateWidget(NeumorphicSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isDragging) {
      _currentDragValue = widget.value;
    }
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

        return GestureDetector(
          onHorizontalDragStart:
              isEnabled
                  ? (details) {
                    setState(() {
                      _isDragging = true;
                    });
                    _updateValue(details.localPosition.dx, width);
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
                  }
                  : null,
          onTapDown:
              isEnabled
                  ? (details) {
                    _updateValue(details.localPosition.dx, width);
                  }
                  : null,
          child: Container(
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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Active track
                Container(
                  width: thumbPosition,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: widget.activeColor,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
                // Thumb
                Positioned(
                  left: thumbPosition - (thumbSize / 2),
                  top: -(thumbSize - widget.height) / 2,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: NeumorphicColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: NeumorphicEffect.outerShadow(
                        blurRadius: 4.0,
                        offset: 2.0,
                      ),
                    ),
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

/// Neumorphic Checkbox implementation
class NeumorphicCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final double size;

  const NeumorphicCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor = NeumorphicColors.primary,
    this.size = 28.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onChanged != null;

    return GestureDetector(
      onTap: isEnabled ? () => onChanged?.call(!value) : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: NeumorphicColors.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow:
              value
                  ? NeumorphicEffect.innerShadow(blurRadius: 4, offset: 2)
                  : NeumorphicEffect.outerShadow(blurRadius: 4, offset: 2),
        ),
        child:
            value
                ? Center(
                  child: Icon(
                    Icons.check,
                    color: activeColor,
                    size: size * 0.6,
                  ),
                )
                : null,
      ),
    );
  }
}

/// Neumorphic Icon Button
class NeumorphicIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color iconColor;
  final double iconSize;

  const NeumorphicIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 50.0,
    this.iconColor = NeumorphicColors.primary,
    this.iconSize = 24.0,
  }) : super(key: key);

  @override
  _NeumorphicIconButtonState createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<NeumorphicIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: NeumorphicColors.surface,
          shape: BoxShape.circle,
          boxShadow:
              isEnabled
                  ? (_isPressed
                      ? NeumorphicEffect.innerShadow(blurRadius: 4, offset: 2)
                      : NeumorphicEffect.outerShadow(blurRadius: 4, offset: 2))
                  : null,
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: isEnabled ? widget.iconColor : NeumorphicColors.textDisabled,
          ),
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
      home: NeumorphicDemoScreen(),
    );
  }
}

class NeumorphicDemoScreen extends StatefulWidget {
  @override
  _NeumorphicDemoScreenState createState() => _NeumorphicDemoScreenState();
}

class _NeumorphicDemoScreenState extends State<NeumorphicDemoScreen> {
  bool _switchValue = false;
  double _sliderValue = 0.5;
  bool _checkboxValue = false;

  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Neumorphic UI Demo'),
        centerTitle: true,
        actions: [
          NeumorphicIconButton(
            icon: Icons.settings,
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Settings pressed!')));
            },
            size: 40,
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Neumorphic UI Components',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SizedBox(height: 40),

            // Neumorphic Styles Demo
            Text(
              'Neumorphic Styles',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),

            // Buttons with different styles
            Text('Buttons', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Flat button pressed!')),
                      );
                    },
                    style: NeumorphicStyle.flat,
                    pressedStyle: NeumorphicStyle.pressed,
                    child: Text(
                      'Flat',
                      style: TextStyle(
                        color: NeumorphicColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Convex button pressed!')),
                      );
                    },
                    style: NeumorphicStyle.convex,
                    pressedStyle: NeumorphicStyle.pressed,
                    child: Text(
                      'Convex',
                      style: TextStyle(
                        color: NeumorphicColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Concave button pressed!')),
                      );
                    },
                    style: NeumorphicStyle.concave,
                    pressedStyle: NeumorphicStyle.emboss,
                    child: Text(
                      'Concave',
                      style: TextStyle(
                        color: NeumorphicColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Embossed button pressed!')),
                      );
                    },
                    style: NeumorphicStyle.emboss,
                    pressedStyle: NeumorphicStyle.pressed,
                    child: Text(
                      'Emboss',
                      style: TextStyle(
                        color: NeumorphicColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            SizedBox(height: 24),

            // Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Switch', style: Theme.of(context).textTheme.titleLarge),
                NeumorphicSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 24),

            // Slider
            Text('Slider', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            NeumorphicSlider(
              value: _sliderValue,
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
            ),
            SizedBox(height: 8),
            Text(
              'Value: ${(_sliderValue * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 24),

            // Checkbox
            Row(
              children: [
                NeumorphicCheckbox(
                  value: _checkboxValue,
                  onChanged: (value) {
                    setState(() {
                      _checkboxValue = value;
                    });
                  },
                ),
                SizedBox(width: 12),
                Text('Checkbox', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            SizedBox(height: 24),

            // Icon Buttons
            Text('Icon Buttons', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NeumorphicIconButton(
                  icon: Icons.favorite,
                  onPressed: () {},
                  iconColor: NeumorphicColors.error,
                ),
                NeumorphicIconButton(
                  icon: Icons.star,
                  onPressed: () {},
                  iconColor: NeumorphicColors.warning,
                ),
                NeumorphicIconButton(icon: Icons.add, onPressed: () {}),
                NeumorphicIconButton(icon: Icons.delete, onPressed: () {}),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
