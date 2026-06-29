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
        //inset: true,
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

/// Custom neumorphic container widget
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final bool isPressed;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.width = double.infinity,
    this.height = 60,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
    this.isPressed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: NeumorphicColors.surface,
        borderRadius: borderRadius,
        boxShadow:
            isPressed
                ? NeumorphicEffect.innerShadow()
                : NeumorphicEffect.outerShadow(),
      ),
      child: child,
    );
  }
}

/// Example of implementing a custom NeumorphicButton
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double width;
  final double height;

  const NeumorphicButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.width = double.infinity,
    this.height = 50,
  }) : super(key: key);

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
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
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration:
            isEnabled
                ? (_isPressed
                    ? NeumorphicButtonStyle.pressedDecoration
                    : NeumorphicButtonStyle.defaultDecoration)
                : NeumorphicButtonStyle.disabledDecoration,
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

/// Neumorphic Radio Button implementation
class NeumorphicRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T>? onChanged;
  final Widget child;
  final Color activeColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const NeumorphicRadio({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.child,
    this.activeColor = NeumorphicColors.primary,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;
    final bool isEnabled = onChanged != null;

    return GestureDetector(
      onTap: isEnabled ? () => onChanged?.call(value) : null,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: NeumorphicColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow:
              isSelected
                  ? NeumorphicEffect.innerShadow(blurRadius: 4, offset: 2)
                  : NeumorphicEffect.outerShadow(blurRadius: 4, offset: 2),
          border: isSelected ? Border.all(color: activeColor, width: 1) : null,
        ),
        child: child,
      ),
    );
  }
}

/// Neumorphic Card widget
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color color;
  final bool isPressed;

  const NeumorphicCard({
    Key? key,
    required this.child,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16),
    this.color = NeumorphicColors.surface,
    this.isPressed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow:
            isPressed
                ? NeumorphicEffect.innerShadow(blurRadius: 8, offset: 4)
                : NeumorphicEffect.outerShadow(blurRadius: 8, offset: 4),
      ),
      child: child,
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

/// Neumorphic TextField wrapper
class NeumorphicTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const NeumorphicTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = 15.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NeumorphicColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: NeumorphicEffect.innerShadow(blurRadius: 4, offset: 2),
      ),
      child: Padding(
        padding: padding,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          style: TextStyle(color: NeumorphicColors.textPrimary, fontSize: 16.0),
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
  int _selectedRadioValue = 0;
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

            // Basic container
            Text('Container', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            NeumorphicContainer(
              child: Center(
                child: Text(
                  'Neumorphic Container',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SizedBox(height: 24),

            // Button
            Text('Button', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            NeumorphicButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Button pressed!')));
              },
              child: Text(
                'Neumorphic Button',
                style: TextStyle(
                  color: NeumorphicColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 24),

            // Card
            Text('Card', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Neumorphic Card',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This is a card with neumorphic styling that can be used to group related content.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // TextField
            Text('TextField', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            NeumorphicTextField(
              controller: _textController,
              hintText: 'Enter text here',
              onChanged: (value) {
                // Handle text changes
              },
            ),
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

            // Radio buttons
            Text(
              'Radio Buttons',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                NeumorphicRadio<int>(
                  value: 0,
                  groupValue: _selectedRadioValue,
                  onChanged: (value) {
                    setState(() {
                      _selectedRadioValue = value;
                    });
                  },
                  child: Text('Option 1'),
                ),
                SizedBox(width: 16),
                NeumorphicRadio<int>(
                  value: 1,
                  groupValue: _selectedRadioValue,
                  onChanged: (value) {
                    setState(() {
                      _selectedRadioValue = value;
                    });
                  },
                  child: Text('Option 2'),
                ),
                SizedBox(width: 16),
                NeumorphicRadio<int>(
                  value: 2,
                  groupValue: _selectedRadioValue,
                  onChanged: (value) {
                    setState(() {
                      _selectedRadioValue = value;
                    });
                  },
                  child: Text('Option 3'),
                ),
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
