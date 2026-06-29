// Connection routing modes
import 'package:flutter_riverpod/legacy.dart';

enum ConnectionRoutingMode { straight, bezier, orthogonal }

final connectionRoutingModeProvider = StateProvider<ConnectionRoutingMode>(
  (ref) => ConnectionRoutingMode.orthogonal,
);
