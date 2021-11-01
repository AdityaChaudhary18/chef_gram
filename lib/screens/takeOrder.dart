import 'package:chef_gram/database_service.dart';
import 'package:chef_gram/models/orderModel.dart';
import 'package:chef_gram/models/profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'Dashboard/place_order.dart';

class TakeOrder extends StatefulWidget {
  TakeOrder({Key? key, this.shopDetails}) : super(key: key);
var shopDetails;
  @override
  _TakeOrderState createState() => _TakeOrderState();
}

class _TakeOrderState extends State<TakeOrder> {
  late Order order;

  @override
  void initState() {
    order =  new Order(customerName: widget.shopDetails['shopOwner'],
        shopName: widget.shopDetails['shopName'], orderTakenBy: Provider.of<Profile>(context, listen: false).name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order From Catalog"),
        actions: [
          ElevatedButton(
            style: ButtonStyle(elevation: MaterialStateProperty.all(0.0)),
            child: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DatabaseService>(context, listen: false).catalog.clear();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          TakeOrder(shopDetails: widget.shopDetails)
                  )
              );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: Provider.of<DatabaseService>(context).getCatalog(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            var document = snapshot.data[index];
                            OrderItem item = OrderItem(
                              name: document['name'],
                              price: document['price'],
                              itemsOrdered: 0,
                              quantity: document['quantity'],
                            );
                            order.addToOrder(item);
                            return Row(
                              children: [
                                Image.network(
                                  document['image'],
                                  height: 20.h,
                                  width: 30.w,
                                  fit: BoxFit.cover,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        document['name'],
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      Text(
                                        "${document['quantity']} g",
                                        style: TextStyle(fontSize: 16.sp),
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      Text(
                                        "₹ ${document['price']}",
                                        style: TextStyle(fontSize: 16.sp),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 6.h,
                                  width: 8.w,
                                  child: TextFormField(
                                    decoration: InputDecoration(hintText: "0"),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    onChanged: (value) {
                                      item.itemsOrdered = int.parse(value);
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    order.viewOrder();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PlaceOrder(order: order);
                        },
                      ),
                    );
                  },
                  child: Text(
                    'Give Order',
                    style:
                        TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
