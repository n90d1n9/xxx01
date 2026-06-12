import 'package:flutter/widgets.dart';

import '../models/project_form_draft.dart';

class ProjectFormDraftTextControllers {
  ProjectFormDraftTextControllers({
    required this.name,
    required this.client,
    required this.owner,
    required this.sponsor,
    required this.summary,
  });

  factory ProjectFormDraftTextControllers.fromDraft(ProjectFormDraft draft) {
    return ProjectFormDraftTextControllers(
      name: TextEditingController(text: draft.name),
      client: TextEditingController(text: draft.client),
      owner: TextEditingController(text: draft.owner),
      sponsor: TextEditingController(text: draft.sponsor),
      summary: TextEditingController(text: draft.summary),
    );
  }

  final TextEditingController name;
  final TextEditingController client;
  final TextEditingController owner;
  final TextEditingController sponsor;
  final TextEditingController summary;

  void applyDraft(ProjectFormDraft draft) {
    _setTextIfChanged(name, draft.name);
    _setTextIfChanged(client, draft.client);
    _setTextIfChanged(owner, draft.owner);
    _setTextIfChanged(sponsor, draft.sponsor);
    _setTextIfChanged(summary, draft.summary);
  }

  void dispose() {
    name.dispose();
    client.dispose();
    owner.dispose();
    sponsor.dispose();
    summary.dispose();
  }

  void _setTextIfChanged(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}
