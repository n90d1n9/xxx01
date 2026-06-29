
class IPBlock {final String cidr; final List<String>? except; IPBlock({required this.cidr, this.except}); factory IPBlock.fromJson(Map<String, dynamic> json) {return IPBlock(cidr: json['cidr'], except: json['except'] != null ? List<String>.from(json['except']) : null);} Map<String, dynamic> toJson() {return {'cidr' : cidr, if (except != null) 'except' : except};}}
