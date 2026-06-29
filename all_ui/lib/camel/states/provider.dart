import 'package:flutter_riverpod/legacy.dart';

final connectingNodeIdProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final darkModeProvider = StateProvider<bool>((ref) => false);
final selectedNodesProvider = StateProvider<Set<String>>((ref) => {});
final showMiniMapProvider = StateProvider<bool>((ref) => true);
final snapToGridProvider = StateProvider<bool>((ref) => true);

final isDraggingComponentProvider = StateProvider<bool>((ref) => false);
