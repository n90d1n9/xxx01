import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class LayersPanel extends ConsumerWidget {
  const LayersPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 250,
      color: Colors.white,
      child: const Column(
        children: [
          Padding(padding: EdgeInsets.all(16), child: Text('Layers Panel')),
        ],
      ),
    );
  }
}
