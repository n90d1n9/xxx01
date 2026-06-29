import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

class Reader {
  final WidgetRef _ref;

  Reader(this._ref);

  T read<T>(ProviderBase<T> provider) {
    return _ref.read(provider);
  }

  T watch<T>(ProviderBase<T> provider) {
    return _ref.watch(provider);
  }

  AutoDisposeStateNotifierProvider<T, State> notifier<
    T extends StateNotifier<State>,
    State
  >(AutoDisposeStateNotifierProvider<T, State> provider) {
    return provider;
  }

  void listen<T>(
    ProviderBase<T> provider,
    void Function(T? previous, T next) listener,
  ) {
    _ref.listen(provider, listener);
  }
}
