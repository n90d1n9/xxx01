import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../components/connection/model/connection_state.dart';
import '../components/connection/widget/connection_painter.dart';

final connectingFromNodeProvider = StateProvider<String?>((ref) => null);
final connectingFromPortProvider = StateProvider<String?>((ref) => null);

final connectionProvider =
    StateNotifierProvider<ConnectionNotifier, ConnectionState>((ref) {
      return ConnectionNotifier(ref);
    });

class ConnectionNotifier extends StateNotifier<ConnectionState> {
  final Ref ref;
  ConnectionNotifier(this.ref)
    : super(
        ConnectionState(
          id: _generateId(),
          sourceNodeId: '',
          targetNodeId: '',
          sourcePortId: '',
          targetPortId: '',
          start: Offset(0, 0),
          end: Offset(0, 0),
        ),
      );

  static String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  void changeLineType(ConnectionLineType lineType) {
    state = state.copyWith(lineType: ConnectionLineType.curved);
  }
}
