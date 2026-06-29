import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrintKitchenSetting extends ConsumerWidget {
  const PrintKitchenSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Kitchen Setting'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Print for Server/Checker'),
            subtitle: const Text('Foods & drinks'),
            value: ref.watch(serverCheckerPrintProvider),
            onChanged: (value) {
              ref.read(serverCheckerPrintProvider.notifier).state = value;
            },
          ),
          SwitchListTile(
            title: const Text('Print for Guest Table'),
            subtitle: const Text('Foods & drinks'),
            value: ref.watch(guestTablePrintProvider),
            onChanged: (value) {
              ref.read(guestTablePrintProvider.notifier).state = value;
            },
          ),
          SwitchListTile(
            title: const Text('Print for food station'),
            value: ref.watch(foodStationPrintProvider),
            onChanged: (value) {
              ref.read(foodStationPrintProvider.notifier).state = value;
            },
          ),
          SwitchListTile(
            title: const Text('Print for drink station'),
            value: ref.watch(drinkStationPrintProvider),
            onChanged: (value) {
              ref.read(drinkStationPrintProvider.notifier).state = value;
            },
          ),
        ],
      ),
    );
  }
}

final serverCheckerPrintProvider = StateProvider<bool>((ref) => false);
final guestTablePrintProvider = StateProvider<bool>((ref) => false);
final foodStationPrintProvider = StateProvider<bool>((ref) => false);
final drinkStationPrintProvider = StateProvider<bool>((ref) => false);