
class NodeAddress {final String type; final String address; NodeAddress({required this.type, required this.address}); factory NodeAddress.fromJson(Map<String, dynamic> json) {return NodeAddress(type: json['type'], address: json['address']);} Map<String, dynamic> toJson() {return {'type' : type, 'address' : address};}}
