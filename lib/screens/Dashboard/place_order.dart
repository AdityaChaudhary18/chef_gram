import 'package:chef_gram/models/orderModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';

import '../../constants.dart';

class PlaceOrder extends StatefulWidget {
  final Order order;

  const PlaceOrder({Key? key, required this.order}) : super(key: key);

  @override
  _PlaceOrderState createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  final customerNameController = TextEditingController();
  final addressController = TextEditingController();
  final shopNameController = TextEditingController();
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  var user =
      FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid);

  Future<void> placeOrder() async {
    List<Map<String, dynamic>> items = [];
    widget.order.order.forEach((element) {
      items.add(element.toMap());
    });
    var orderData = {
      'dateTime': widget.order.timeStamp.toLocal(),
      'customerName': customerNameController.value.text,
      'address': addressController.value.text,
      'shopName': shopNameController.value.text,
      'orderTakenBy': widget.order.orderTakenBy,
      'total': widget.order.total,
      'items': items
    };
    return orders.add(orderData).then((value) async {
      // await OrderSpreadSheet.init(orderData);
      final snackBar = SnackBar(
        backgroundColor: Colors.lightBlue,
        duration: Duration(seconds: 8),
        content: Text(
          "Success! Order Placed!",
          style: TextStyle(color: Colors.white),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pushReplacementNamed(context, '/dashboard');
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder(
          stream: user.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            widget.order.orderTakenBy = snapshot.data!.get('name');
            widget.order.viewOrder();

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Order Summary",
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Employee name: ${widget.order.orderTakenBy}",
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    TextFormField(
                      controller: customerNameController,
                      textAlign: TextAlign.center,
                      decoration: authTextFieldDecoration.copyWith(
                        labelText: "Customer Name",
                        hintText: "Enter Customer's Full Name",
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    TextFormField(
                      controller: shopNameController,
                      textAlign: TextAlign.center,
                      decoration: authTextFieldDecoration.copyWith(
                        labelText: "Shop Name",
                        hintText: "Enter Shop's Name",
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    TextFormField(
                      controller: addressController,
                      textAlign: TextAlign.center,
                      decoration: authTextFieldDecoration.copyWith(
                        labelText: "Address",
                        hintText: "Enter Shop Address",
                      ),
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
                            return Padding(
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
                                  Navigator.pushReplacementNamed(
                                      context, '/dashboard');
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
                                onPressed: placeOrder,
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
            );
          },
        ),
      ),
    );
  }
}
