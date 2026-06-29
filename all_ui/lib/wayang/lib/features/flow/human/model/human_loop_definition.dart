import 'human_approval_option.dart';
import 'human_approval_status.dart';

class HumanInLoopNodeDefinition {
  final String id;
  final String name;
  final String description;
  final HumanApprovalType approvalType;
  final String prompt;
  final List<HumanApprovalOption> options;
  final Duration? timeout;
  final bool allowSkip;
  final String? skipLabel;
  final Map<String, dynamic> metadata;
  final List<String>? notificationEmails;
  final bool requireComment;
  final String? commentPrompt;

  HumanInLoopNodeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.approvalType,
    required this.prompt,
    this.options = const [],
    this.timeout,
    this.allowSkip = false,
    this.skipLabel,
    this.metadata = const {},
    this.notificationEmails,
    this.requireComment = false,
    this.commentPrompt,
  });

  List<String> getOutputPorts() {
    switch (approvalType) {
      case HumanApprovalType.binary:
        return ['approved', 'rejected', if (allowSkip) 'skipped', 'timeout'];
      case HumanApprovalType.choice:
      case HumanApprovalType.multiChoice:
        return [
          ...options.map((o) => o.id),
          if (allowSkip) 'skipped',
          'timeout',
        ];
      case HumanApprovalType.text:
        return ['completed', if (allowSkip) 'skipped', 'timeout'];
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'approvalType': approvalType.name,
    'prompt': prompt,
    'options': options.map((o) => o.toJson()).toList(),
    'timeout': timeout?.inSeconds,
    'allowSkip': allowSkip,
    'skipLabel': skipLabel,
    'metadata': metadata,
    'notificationEmails': notificationEmails,
    'requireComment': requireComment,
    'commentPrompt': commentPrompt,
  };

  factory HumanInLoopNodeDefinition.fromJson(Map<String, dynamic> json) =>
      HumanInLoopNodeDefinition(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        approvalType: HumanApprovalType.values.firstWhere(
          (e) => e.name == json['approvalType'],
        ),
        prompt: json['prompt'],
        options:
            (json['options'] as List?)
                ?.map((o) => HumanApprovalOption.fromJson(o))
                .toList() ??
            [],
        timeout: json['timeout'] != null
            ? Duration(seconds: json['timeout'])
            : null,
        allowSkip: json['allowSkip'] ?? false,
        skipLabel: json['skipLabel'],
        metadata: json['metadata'] ?? {},
        notificationEmails: (json['notificationEmails'] as List?)
            ?.cast<String>(),
        requireComment: json['requireComment'] ?? false,
        commentPrompt: json['commentPrompt'],
      );
}
