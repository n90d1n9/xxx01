import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kasir/modules/pos/logic/amount.dart';
import 'package:kasir/modules/pos/model/button_value.dart';
part 'button_key.g.dart';

@riverpod
class ButtonKey extends _$ButtonKey {
  @override
  ButtonValue build() {
    return ButtonValue('keyId', 'keyLabel', 'character');
  }

  void inputKey(key, value){
    
    switch (key) {
      case 'Clear':
      
        ref.read(amountProvider.notifier).clear();
        break;
      case 'Enter':
        ref.read(amountProvider.notifier).add(value);
        break;
      default:
        number(key);
    }
  }

  double number(value){
    var val = double.parse(value);
    return val;
  }
}