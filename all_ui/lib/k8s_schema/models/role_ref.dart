
class RoleRef {final String apiGroup; final String kind; final String name; RoleRef({required this.apiGroup, required this.kind, required this.name}); factory RoleRef.fromJson(Map<String, dynamic> json) {return RoleRef(apiGroup: json['apiGroup'], kind: json['kind'], name: json['name']);} Map<String, dynamic> toJson() {return {'apiGroup' : apiGroup, 'kind' : kind, 'name' : name};}}
