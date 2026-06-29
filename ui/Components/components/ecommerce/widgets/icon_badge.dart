import 'package:flutter/material.dart';

class IconBadge extends StatelessWidget {
  final int? value;
  final IconData icon;
  final Function() onTap;
  final Color? color;

  const IconBadge(
      {super.key, required this.icon, this.value, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Icon(icon, color: color,)),
            (value != null && value != 0)
                ? Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Text(
                        '${value!}',
                        style: const TextStyle(
                          fontSize: 8.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ));
  }
}
