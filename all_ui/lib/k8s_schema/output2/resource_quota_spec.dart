import 'scope_selector.dart';

class ResourceQuotaSpec {
  final Map<String, String>? hard;
  final List<String>? scopes;
  final ScopeSelector? scopeSelector;
  ResourceQuotaSpec({this.hard, this.scopes, this.scopeSelector});
  factory ResourceQuotaSpec.fromJson(Map<String, dynamic> json) {
    return ResourceQuotaSpec(
      hard:
          json['hard'] != null ? Map<String, String>.from(json['hard']) : null,
      scopes: json['scopes'] != null ? List<String>.from(json['scopes']) : null,
      scopeSelector:
          json['scopeSelector'] != null
              ? ScopeSelector.fromJson(json['scopeSelector'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (hard != null) 'hard': hard,
      if (scopes != null) 'scopes': scopes,
      if (scopeSelector != null) 'scopeSelector': scopeSelector!.toJson(),
    };
  }
}
