import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kayys_components/models/index.dart';

class FloatingBottomBar extends StatefulWidget {
  final Color bottonNavBgColor;
  final List<Menu> items;
  final double height;
  final double width;
  final double opacity;
  const FloatingBottomBar(
      {super.key,
      this.opacity = 1.0,
      this.bottonNavBgColor = Colors.cyan,
      this.height = 35,
      this.width = 35,
      required this.items});

  @override
  State<FloatingBottomBar> createState() => _FloatingBottomBarState();
}

class _FloatingBottomBarState extends State<FloatingBottomBar> {
  int currentIndex = 0;
  int selctedNavIndex = 0;
  @override
  Widget build(BuildContext contextw) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 20),
        decoration: BoxDecoration(
          color: widget.bottonNavBgColor.withOpacity(widget.opacity),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              offset: const Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            widget.items.length,
            (index) {
              return GestureDetector(
                  onTap: () {
                    setState(() {
                      selctedNavIndex = index;
                    });
                    context.go(widget.items[index].path!);
                  },
                  child: SizedBox(
                      height: widget.height,
                      width: widget.width,
                      child: Column(children: [
                        AnimatedBar(
                          isActive: selctedNavIndex == index,
                        ),
                        /*  AnimatedIcon(
                          isActive: selctedNavIndex == index,
                          child: widget.items[index].iconWidget!,
                        ), */
                        widget.items[index].iconWidget!
                      ])));
            },
          ),
        ),
      ),
    );
  }
}

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({
    super.key,
    required this.isActive,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 2),
      height: 4,
      width: isActive ? 20 : 0,
      decoration: const BoxDecoration(
        color: Color(0xFF81B4FF),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

class AnimatedIcon extends StatelessWidget {
  const AnimatedIcon(
      {super.key,
      required this.isActive,
      required this.child,
      this.backgroundColor = Colors.white});

  final bool isActive;
  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40, //isActive ? 50 : 30,
        width: 40, //isActive ? 80 : 30,
        decoration: BoxDecoration(
          color: isActive ? backgroundColor : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(100)),
        ),
        child: child);
  }
}
