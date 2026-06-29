
class NamespaceSpec {final List<String>? finalizers; NamespaceSpec({this.finalizers}); factory NamespaceSpec.fromJson(Map<String, dynamic> json) {return NamespaceSpec(finalizers: json['finalizers'] != null ? List<String>.from(json['finalizers']) : null);} Map<String, dynamic> toJson() {return {if (finalizers != null) 'finalizers' : finalizers};}}
