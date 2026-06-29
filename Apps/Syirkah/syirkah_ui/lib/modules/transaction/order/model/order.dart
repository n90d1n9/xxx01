import 'dart:convert';
import 'package:equatable/equatable.dart'; 

class Order extends Equatable{
    final int? id; 
    final DateTime? createdAt; 

    const Order({  
        this.id, 
        this.createdAt, 
    });

    factory Order.fromJson(Map<String, dynamic> json) =>  
        Order(id: json['id'], 
        createdAt: json['createdAt'], 
        
    );

    Map<String, dynamic> toJson() => 
        {"id": id,
        "createdAt": createdAt,
        
    };

    static List<Order> listFromString(String str) => List<Order>.from(json.decode(str).map((x) => Order.fromJson(x)));

    static List<Order> listFromJson(List<dynamic> data) {
        return data.map((post) => Order.fromJson(post)).toList();
    }

    static String listOrderToJson(List<Order> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

    @override
    List<Object> get props => [
        id!, 
        createdAt!, 
    ];
}

class OrderList {
  final List<Order>? orders;

  OrderList({
    this.orders,
  });

  factory OrderList.fromJson(List<dynamic> json) {
    List<Order> orders = [];
    orders = json.map((post) => Order.fromJson(post)).toList();

    return OrderList(
      orders: orders,
    );
  }
}


