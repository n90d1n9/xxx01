import 'package:flutter_riverpod/legacy.dart';

import '../model/command.dart';

class CommandPaletteNotifier extends StateNotifier<CommandPaletteState> {
  CommandPaletteNotifier() : super(CommandPaletteState());

  final List<Command> _allCommands = [];

  void registerCommands(List<Command> commands) {
    _allCommands.addAll(commands);
  }

  void show() {
    state = state.copyWith(isVisible: true, filteredCommands: _allCommands);
  }

  void hide() {
    state = CommandPaletteState();
  }

  void search(String query) {
    if (query.isEmpty) {
      state = state.copyWith(
        searchQuery: query,
        filteredCommands: _allCommands,
        selectedIndex: 0,
      );
      return;
    }

    final filtered = _allCommands.where((cmd) => cmd.matches(query)).toList();
    state = state.copyWith(
      searchQuery: query,
      filteredCommands: filtered,
      selectedIndex: 0,
    );
  }

  void selectNext() {
    if (state.filteredCommands.isEmpty) return;
    state = state.copyWith(
      selectedIndex: (state.selectedIndex + 1) % state.filteredCommands.length,
    );
  }

  void selectPrevious() {
    if (state.filteredCommands.isEmpty) return;
    state = state.copyWith(
      selectedIndex:
          (state.selectedIndex - 1 + state.filteredCommands.length) %
          state.filteredCommands.length,
    );
  }

  void executeSelected() {
    if (state.filteredCommands.isEmpty) return;
    final command = state.filteredCommands[state.selectedIndex];
    command.action();
    hide();
  }
}

final commandPaletteProvider =
    StateNotifierProvider<CommandPaletteNotifier, CommandPaletteState>(
      (ref) => CommandPaletteNotifier(),
    );

class CommandPaletteState {
  final bool isVisible;
  final String searchQuery;
  final List<Command> filteredCommands;
  final int selectedIndex;

  CommandPaletteState({
    this.isVisible = false,
    this.searchQuery = '',
    this.filteredCommands = const [],
    this.selectedIndex = 0,
  });

  CommandPaletteState copyWith({
    bool? isVisible,
    String? searchQuery,
    List<Command>? filteredCommands,
    int? selectedIndex,
  }) {
    return CommandPaletteState(
      isVisible: isVisible ?? this.isVisible,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredCommands: filteredCommands ?? this.filteredCommands,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
