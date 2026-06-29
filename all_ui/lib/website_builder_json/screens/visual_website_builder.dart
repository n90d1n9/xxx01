import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VisualWebsiteBuilder extends ConsumerStatefulWidget {
  const VisualWebsiteBuilder({super.key});

  @override
  ConsumerState<VisualWebsiteBuilder> createState() =>
      _VisualWebsiteBuilderState();
}

class _VisualWebsiteBuilderState extends ConsumerState<VisualWebsiteBuilder> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
        ],
      ),
    );
  }
}

class _FontSizeField extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const _FontSizeField({this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text('Size', style: TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: TextEditingController(text: value ?? '16'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                suffixText: 'px',
              ),
              onChanged: (value) => onChanged('${value}px'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FontWeightField extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const _FontWeightField({this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text('Weight', style: TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: value ?? 'normal',
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
              items: const [
                DropdownMenuItem(value: '100', child: Text('Thin')),
                DropdownMenuItem(value: '300', child: Text('Light')),
                DropdownMenuItem(value: 'normal', child: Text('Normal')),
                DropdownMenuItem(value: '500', child: Text('Medium')),
                DropdownMenuItem(value: '600', child: Text('Semibold')),
                DropdownMenuItem(value: 'bold', child: Text('Bold')),
                DropdownMenuItem(value: '800', child: Text('Extra Bold')),
              ],
              onChanged: (value) => onChanged(value ?? 'normal'),
            ),
          ),
        ],
      ),
    );
  }
}
