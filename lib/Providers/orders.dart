import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shop_app/Providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.datetime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get order {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    const url =
        "https://shopapp-e0fa1-default-rtdb.firebaseio.com/orders.json";
    final response = await http.get(Uri.parse(url));

    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) == null
        ? {}
        : json.decode(response.body) as Map<String, dynamic>;
    if (extractedData.length <= 0) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData["amount"],
          products: (orderData["products"] as List<dynamic>)
              .map((e) => CartItem(
                    id: e["id"],
                    title: e["title"],
                    quantity: e["quantity"],
                    price: e["price"],
                  ))
              .toList(),
          datetime: DateTime.parse(orderData["dateTime"])));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url =
        "https://experiments-344b6-default-rtdb.firebaseio.com/orders.json";

    final timeStamp = DateTime.now();

    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        "amount": total,
        "dateTime": timeStamp.toIso8601String(),
        "products": cartProducts
            .map((e) => {
                  "id": e.id,
                  "title": e.title,
                  "quantity": e.quantity,
                  "price": e.price
                })
            .toList()
      }),
    );
    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)["name"],
            amount: total,
            products: cartProducts,
            datetime: DateTime.now()));
  }

  notifyListeners();
}