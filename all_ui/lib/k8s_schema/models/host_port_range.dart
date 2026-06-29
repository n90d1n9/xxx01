
class HostPortRange {final int min; final int max; HostPortRange({required this.min, required this.max}); factory HostPortRange.fromJson(Map<String, dynamic> json) {return HostPortRange(min: json['min'], max: json['max']);} Map<String, dynamic> toJson() {return {'min' : min, 'max' : max};}}
