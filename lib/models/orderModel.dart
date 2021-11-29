import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

CollectionReference users = FirebaseFirestore.instance.collection('users');
FirebaseAuth auth = FirebaseAuth.instance;

class Order {
  Order(
      {required this.orderTakenBy,
      required this.shopName,
      required this.customerName,
      required this.shopRef,
      required this.address});

  List<OrderItem> order = [];
  DateTime timeStamp = DateTime.now();
  int total = 0;
  String orderTakenBy = "USER";
  String customerName = "Customer";
  String shopName = 'unknown';
  String address = 'unknown';
  String shopRef = 'unknown';
  Function? addToOrder(OrderItem item) {
    this.order.add(item);
  }

  Function? viewOrder() {
    int totalMoney = 0;
    this.order.removeWhere((element) => element.itemsOrdered <= 0);
    this.order.forEach(
      (element) {
        totalMoney += element.itemsOrdered * element.price;
      },
    );
    this.total = totalMoney;
  }
}

class OrderItem {
  String name;
  int price;
  int quantity;
  int itemsOrdered;

  OrderItem(
      {required this.itemsOrdered,
      required this.name,
      required this.price,
      required this.quantity});

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'price': this.price,
        'quantity': this.quantity,
        'boxes': this.itemsOrdered
      };
}
