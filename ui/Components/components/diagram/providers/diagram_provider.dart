import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final diagramProvider = StateNotifierProvider<DiagramNotifier, Map<String, String>>((ref) {
  return DiagramNotifier();
});

class DiagramNotifier extends StateNotifier<Map<String, String>> {
  DiagramNotifier() : super({}) {
    _loadDiagrams();
  }

  Future<void> _loadDiagrams() async {
    //final prefs = await SharedPreferences.getInstance();
    //final diagrams = prefs.getStringMap('diagrams') ?? {};
    //state = diagrams;
  }

  Future<void> _saveDiagrams() async {
    //final prefs = await SharedPreferences.getInstance();
    //await prefs.setStringMap('diagrams', state);
  }

  Future<String> saveDiagram(String content) async {
    final id = const Uuid().v4();
    state = {...state, id: content};
    await _saveDiagrams();
    return id;
  }

  Future<void> updateDiagram(String id, String content) async {
    state = {...state, id: content};
    await _saveDiagrams();
  }

  Future<void> deleteDiagram(String id) async {
    final newState = Map<String, String>.from(state);
    newState.remove(id);
    state = newState;
    await _saveDiagrams();
  }
}
