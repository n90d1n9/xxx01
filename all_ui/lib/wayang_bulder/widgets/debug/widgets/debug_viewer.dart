import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugViewer extends ConsumerWidget {
  final ValueNotifier<String>? data;
  final List<String> debugData;
  const DebugViewer({super.key, this.data, this.debugData = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      bottom: 20,
      left: 300,
      child: Column(children: [
        // Drag tracker display
        Container(
          width: 800,
          height: 200,
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: ListView.builder(
              itemCount: debugData.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(4.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(debugData[index].toString()),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
