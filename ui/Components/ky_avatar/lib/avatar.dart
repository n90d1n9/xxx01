import 'package:flutter/material.dart';
import 'package:kayys_components/components/avatar/avatar_animation.dart';

import 'avatar_pile.dart';

class MyAvatar extends StatelessWidget {
  const MyAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Ini Avatar'),
        const AvatarAnimation(),
        const CircleAvatar(
          radius: 30.0,
          backgroundImage: NetworkImage('https://robohash.org/urang'),
          backgroundColor: Colors.transparent,
          /* child: ClipOval(
            child: Image.network(
              'https://api.dicebear.com/8.x/adventurer/svg?seed=Gizmo',
            ),
          ), */
        ),
        AvatarPile(
          faceSize: 50,
          facePercentOverlap: .4,
          borderColor: Colors.white,
          faces: [
            AvatarFrame(
                avatar: const NetworkImage('https://robohash.org/satu'),
                name: 'satu',
                id: '1'),
            AvatarFrame(
                avatar: const NetworkImage('https://robohash.org/ganteng'),
                name: 'dua',
                id: '2'),
            AvatarFrame(
                avatar: const NetworkImage('https://robohash.org/empat'),
                name: 'tiga',
                id: '3'),
            AvatarFrame(
                avatar: const NetworkImage('https://robohash.org/urang'),
                name: 'empat',
                id: '4'),
          ],
        )
      ],
    );
  }
}
