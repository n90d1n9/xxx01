import '../models/collaborator.dart';

class CollaborationManager {
  static final CollaborationManager _instance =
      CollaborationManager._internal();
  factory CollaborationManager() => _instance;
  CollaborationManager._internal();

  final List<Collaborator> _collaborators = [];
  final Map<String, String> _cursors = {};

  void addCollaborator(Collaborator collaborator) {
    _collaborators.add(collaborator);
  }

  void removeCollaborator(String id) {
    _collaborators.removeWhere((c) => c.id == id);
    _cursors.remove(id);
  }

  void updateCursor(String userId, String componentId) {
    _cursors[userId] = componentId;
  }

  List<Collaborator> get activeCollaborators => _collaborators;
  Map<String, String> get cursors => _cursors;
}
