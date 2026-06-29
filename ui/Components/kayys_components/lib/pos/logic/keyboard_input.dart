import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'keyboard_input.g.dart';

@riverpod
class KeyboardInput extends _$KeyboardInput {
  final String _key='';
  @override
  String build() => _key;

  void inputKey(int keyId, String keyLabel, [String? character]) {
    
    state = keyLabel ;//+ character!;
  }
}
