import 'dart:convert';
import 'package:equatable/equatable.dart'; 

class Shipment extends Equatable{
    final int? id; 
    final DateTime? createdAt; 

    const Shipment({  
        this.id, 
        this.createdAt, 
    });

    factory Shipment.fromJson(Map<String, dynamic> json) =>  
        Shipment(id: json['id'], 
        createdAt: json['createdAt'], 
        
    );

    Map<String, dynamic> toJson() => 
        {"id": id,
        "createdAt": createdAt,
        
    };

    static List<Shipment> listFromString(String str) => List<Shipment>.from(json.decode(str).map((x) => Shipment.fromJson(x)));

    static List<Shipment> listFromJson(List<dynamic> data) {
        return data.map((post) => Shipment.fromJson(post)).toList();
    }

    static String listShipmentToJson(List<Shipment> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

    @override
    List<Object> get props => [
        id!, 
        createdAt!, 
    ];
}

class ShipmentList {
  final List<Shipment>? shipments;

  ShipmentList({
    this.shipments,
  });

  factory ShipmentList.fromJson(List<dynamic> json) {
    List<Shipment> shipments = [];
    shipments = json.map((post) => Shipment.fromJson(post)).toList();

    return ShipmentList(
      shipments: shipments,
    );
  }
}


