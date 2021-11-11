import 'package:chef_gram/models/profile_model.dart';
import 'package:chef_gram/screens/user_profile/order_summary.dart';
import 'package:chef_gram/screens/user_profile/stats_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();

    var lastMidnight = DateTime(now.year, now.month, now.day);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text("Profile"),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('orderTakenBy',
                  isEqualTo: Provider.of<Profile>(context, listen: false)
                      .name
                      .toString())
              .orderBy('dateTime', descending: true)
              .where("dateTime", isGreaterThan: lastMidnight)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            var todaySale = 0.0;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome,",
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  Text(Provider.of<Profile>(context).name,
                      style: TextStyle(fontSize: 14.sp)),
                  SizedBox(
                    height: 2.h,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Order History for ${now.day}-${now.month}-${now.year}",
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Container(
                    height: 50.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black54,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    child: (snapshot.data!.docs.length == 0)
                        ? Center(
                            child: Text(
                            "No orders Placed Today",
                            style: TextStyle(
                                fontSize: 15.sp, fontWeight: FontWeight.bold),
                          ))
                        : ListView(
                            children: <Widget>[
                              ...snapshot.data!.docs.map((order) {
                                todaySale += order.get('total');
                                return SingleOrderWidget(order: order);
                              })
                            ],
                          ),
                  ),
                  SizedBox(height: 2.h),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Total Sale For Today: $todaySale",
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      child: Text("See History For past 5 days"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StatsPage()),
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class SingleOrderWidget extends StatelessWidget {
  SingleOrderWidget({required this.order});
  var order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return OrderSummary(order: order);
            },
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Container(
          width: 100.w,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Customer Name : ${order.get('customerName')}",
                          style: TextStyle(
                              fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "By: ${order.get('orderTakenBy')}",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        Text(
                          "Shop : ${order.get('shopName')}",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "₹ ${order.get('total')}",
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
