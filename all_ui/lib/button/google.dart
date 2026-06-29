import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedGoogleSignInButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final double borderRadius;
  final double elevation;
  final Color? textColor;
  final Color? buttonColor;
  final bool isLoading;

  const AnimatedGoogleSignInButton({
    super.key,
    required this.onPressed,
    this.text = 'Sign in with Google',
    this.borderRadius = 8.0,
    this.elevation = 2.0,
    this.textColor,
    this.buttonColor,
    this.isLoading = false,
  });

  @override
  State<AnimatedGoogleSignInButton> createState() =>
      _AnimatedGoogleSignInButtonState();
}

class _AnimatedGoogleSignInButtonState extends State<AnimatedGoogleSignInButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.buttonColor ?? Colors.white,
          foregroundColor: widget.textColor ?? Colors.black87,
          elevation: widget.elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: widget.isLoading ? null : _handleTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isLoading)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                  ),
                ),
              )
            else
              SvgPicture.asset('assets/google_logo.svg', height: 24, width: 24),
            const SizedBox(width: 12),
            Text(
              widget.isLoading ? 'Signing in...' : widget.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
