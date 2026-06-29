import 'dart:convert';
import 'package:equatable/equatable.dart'; 
import 'package:syirkah/modules/product/model/product.dart'; 


class OrderLine extends Equatable{
    final int? id; 
    final DateTime? createdAt; 
    final Product? product; 
    final Product? orderItem; 

    const OrderLine({  
        this.id, 
        this.createdAt, 
        this.product, 
        this.orderItem, 
    });

    factory OrderLine.fromJson(Map<String, dynamic> json) =>  
        OrderLine(id: json['id'], 
        createdAt: json['createdAt'], 
        product: json['product'], 
        orderItem: json['orderItem'], 
        
    );

    Map<String, dynamic> toJson() => 
        {"id": id,
        "createdAt": createdAt,
        "product": product,
        "orderItem": orderItem,
        
    };

    static List<OrderLine> listFromString(String str) => List<OrderLine>.from(json.decode(str).map((x) => OrderLine.fromJson(x)));

    static List<OrderLine> listFromJson(List<dynamic> data) {
        return data.map((post) => OrderLine.fromJson(post)).toList();
    }

    static String listOrderLineToJson(List<OrderLine> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

    @override
    List<Object> get props => [
        id!, 
        createdAt!, 
        product!, 
        orderItem!, 
    ];
}

class OrderLineList {
  final List<OrderLine>? orderLines;

  OrderLineList({
    this.orderLines,
  });

  factory OrderLineList.fromJson(List<dynamic> json) {
    List<OrderLine> orderLines = [];
    orderLines = json.map((post) => OrderLine.fromJson(post)).toList();

    return OrderLineList(
      orderLines: orderLines,
    );
  }
}


