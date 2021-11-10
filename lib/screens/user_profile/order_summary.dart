import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:chef_gram/models/orderModel.dart';

class OrderSummary extends StatelessWidget {
  final order;
  const OrderSummary({Key? key, required this.order}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                "Order Summary",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(
              height: 3.h,
            ),
            Text(
              "Employee name: ${order["orderTakenBy"]}",
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
            Text(
              "Ordered By: ${order["customerName"]}",
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
            Text(
              "Shop Name: ${order["shopName"]}",
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
            Text(
              "Address: ${order["address"]}",
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
            SizedBox(
              height: 3.h,
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
                itemCount: (order['items'].length),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['items'][index]["name"],
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${order['items'][index]["quantity"]} g",
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                                Text(
                                  "₹ ${order['items'][index]["price"]}",
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 4.w),
                            child: Text(
                              "*${order['items'][index]["boxes"]}",
                              style: TextStyle(
                                fontSize: 20.sp,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Total price: ₹ ${order['total']}",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
