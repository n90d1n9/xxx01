import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:syirkah/modules/pos/model/order.dart';
part 'transaction.g.dart';

@riverpod
class Transaction extends _$Transaction {
  @override
  List<OrderTrx> build() => [];

  void add(OrderTrx order) => state.add(order);

  //sortBy(double id) => state.sortedBy((order) => null)
  
  void deleteByIndex(int index)=> state.removeAt(index);
}