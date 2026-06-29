
class EndpointHints {final List<ForZone>? forZones; EndpointHints({this.forZones}); factory EndpointHints.fromJson(Map<String, dynamic> json) {return EndpointHints(forZones: json['forZones'] != null ? (json['forZones'] as List).map((e) => ForZone.fromJson(e)).toList() : null);} Map<String, dynamic> toJson() {return {if (forZones != null) 'forZones' : forZones!.map((e) => e.toJson()).toList()};}}
