import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'amount.g.dart';

@riverpod
class Amount extends _$Amount {
  @override
  double build() => 0;

  void minus(value) {
    state = state - parse(value);
  }
  void clear(){
    state = 0;
  }

  void add(value) {
      state = state + parse(value); 
  }

  double parse(value){
    double val = 0;
    try {
      val = double.parse(value);
    } catch (e) {
      val;
    }
    return val;
  }
}
