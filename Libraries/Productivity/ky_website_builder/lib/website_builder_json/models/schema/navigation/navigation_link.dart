import '../event/action.dart';

class NavigationLink {
  final String type; // internal, external, anchor, action
  final String? url;
  final String? pageId;
  final String? anchor;
  final Action? action;
  final bool openInNewTab;

  NavigationLink({
    required this.type,
    this.url,
    this.pageId,
    this.anchor,
    this.action,
    this.openInNewTab = false,
  });

  factory NavigationLink.fromJson(Map<String, dynamic> json) {
    return NavigationLink(
      type: json['type'] as String,
      url: json['url'] as String?,
      pageId: json['pageId'] as String?,
      anchor: json['anchor'] as String?,
      action:
          json['action'] != null
              ? Action.fromJson(json['action'] as Map<String, dynamic>)
              : null,
      openInNewTab: json['openInNewTab'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (url != null) 'url': url,
    if (pageId != null) 'pageId': pageId,
    if (anchor != null) 'anchor': anchor,
    if (action != null) 'action': action!.toJson(),
    'openInNewTab': openInNewTab,
  };
}
