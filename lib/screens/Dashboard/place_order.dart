import 'package:chef_gram/models/orderModel.dart';
import 'package:chef_gram/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../database_service.dart';
import 'beat_selector.dart';
import 'dashboard.dart';

class PlaceOrder extends StatefulWidget {
  final Order order;

  const PlaceOrder({Key? key, required this.order}) : super(key: key);

  @override
  _PlaceOrderState createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  Future<void> orderIsConfirmed() async {
    var doc = await FirebaseFirestore.instance
        .doc(
            'users/${Provider.of<DatabaseService>(context, listen: false).uid}')
        .get();
    List visits = doc.get('targetData.shopsToVisit');
    for (int i = 0; i < visits.length; i++) {
      if (visits[i]['shopRef'].toString() == widget.order.shopRef) {
        visits[i]["isVisited"] = true;
        visits[i]["orderSuccessful"] = true;
        visits[i]["comment"] = "Order Placed successfully";
        break;
      }
    }
    FirebaseFirestore.instance
        .doc(
            'users/${Provider.of<DatabaseService>(context, listen: false).uid}')
        .update({
      "targetData.shopsToVisit": visits,
      "targetData.todaySale":
          doc.get('targetData.todaySale') + widget.order.total
    });
  }

  Future<void> placeOrder() async {
    List<Map<String, dynamic>> items = [];
    widget.order.order.forEach((element) {
      if (element.itemsOrdered != 0) {
        items.add(element.toMap());
      }
    });
    var orderData = {
      'dateTime': widget.order.timeStamp.toLocal(),
      'customerName': widget.order.customerName,
      'address': widget.order.address,
      'shopName': widget.order.shopName,
      'orderTakenBy': widget.order.orderTakenBy,
      'total': widget.order.total,
      'items': items,
      'state':
          Provider.of<Profile>(context, listen: false).targetData!['state'],
      'city': Provider.of<Profile>(context, listen: false).targetData!['city'],
      'beat': Provider.of<Profile>(context, listen: false).targetData!['beat'],
      'shopId': widget.order.shopId
    };
    return orders.add(orderData).then((value) async {
      final snackBar = SnackBar(
        backgroundColor: Colors.lightBlue,
        duration: Duration(seconds: 8),
        content: Text(
          "Success! Order Placed!",
          style: TextStyle(color: Colors.white),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Loader.hide();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => BeatSelector(),
          ),
          (route) => false);
    }).catchError((error) {
      final snackBar = SnackBar(
        backgroundColor: Colors.lightBlue,
        duration: Duration(seconds: 8),
        content: Text(
          error,
          style: TextStyle(color: Colors.white),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  void dispose() {
    Loader.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Order Summary",
                  style:
                      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Employee name: ${widget.order.orderTakenBy}",
                ),
                SizedBox(
                  height: 4.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.order.shopName,
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.order.address,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ordering for,"),
                        Text(
                          "${widget.order.customerName}",
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                Text(
                  "Order List",
                  style: TextStyle(
                    fontSize: 20.sp,
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Container(
                  width: 100.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                  child: ListView.builder(
                      itemCount: widget.order.order.length,
                      itemBuilder: (BuildContext context, int index) {
                        return (widget.order.order[index].itemsOrdered == 0)
                            ? SizedBox(
                                height: 0,
                              )
                            : Padding(
                                padding: EdgeInsets.all(2.w),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.order.order[index].name,
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "${widget.order.order[index].quantity.toString()} g",
                                              style: TextStyle(fontSize: 12.sp),
                                            ),
                                            Text(
                                              "Rs.${widget.order.order[index].price.toString()}",
                                              style: TextStyle(fontSize: 12.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 4.w),
                                        child: Text(
                                          "*${widget.order.order[index].itemsOrdered.toString()}",
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                      }),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        " ₹ ${widget.order.total.toString()}",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.pop(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Dashboard()));
                            },
                            child: Icon(Icons.clear),
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                            ),
                            onPressed: () {
                              if (widget.order.total > 0) {
                                Loader.show(context);
                                placeOrder();
                                orderIsConfirmed();
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content:
                                      Text("You cannot place empty order."),
                                  backgroundColor: Colors.red,
                                  duration: Duration(milliseconds: 3000),
                                ));
                              }
                            },
                            child: Icon(Icons.check),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
