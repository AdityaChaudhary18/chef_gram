import 'package:chef_gram/database_service.dart';
import 'package:chef_gram/models/profile_model.dart';
import 'package:chef_gram/screens/user_profile/order_summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String employeeName = '';
  var employeeAge = 0;
  var monthlyTarget = 0;
  var monthlySales = 0.0;
  var dailySales = 0.0;
  var dailyTarget = 0;
  var totalSales = 0.0;

  void calculateSales(snapshot) async {
    monthlySales = 0.0;
    dailySales = 0.0;
    totalSales = 0.0;
    for (var order in snapshot.data.docs) {
      Timestamp time = order.get('dateTime');
      totalSales += order.get('total');
      if (time.toDate().year == DateTime.now().year) {
        if (time.toDate().month == DateTime.now().month) {
          monthlySales += order.get('total');
          if (time.toDate().day == DateTime.now().day) {
            dailySales += order.get('total');
          }
        }
      }
    }
  }

  void getEmployeeData() async {
    var document = await users
        .doc(Provider.of<DatabaseService>(context, listen: false).uid)
        .get();
    setState(() {
      employeeName = document['name'];
      employeeAge = document['age'];
      monthlyTarget = document['monthlyTarget'];
      dailyTarget = document['targetData.todayTarget'];
    });
  }

  @override
  initState() {
    getEmployeeData();
    super.initState();
  }

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
            if (snapshot.hasData) {
              calculateSales(snapshot);
            }

            final List<_ChartData> chartData = <_ChartData>[
              _ChartData(
                  'Daily Sale',
                  (dailySales / dailyTarget) * 100,
                  const Color.fromRGBO(235, 97, 143, 1),
                  "${((dailySales / dailyTarget) * 100).toStringAsFixed(2)} %"),
              _ChartData(
                  'Monthly Sale',
                  (monthlySales / monthlyTarget) * 100,
                  const Color.fromRGBO(145, 132, 202, 1),
                  "${((monthlySales / monthlyTarget) * 100).toStringAsFixed(2)} %"),
            ];
            var todaySale = 0.0;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Welcome,",
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    Text(Provider.of<Profile>(context).name,
                        style: TextStyle(fontSize: 14.sp)),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      height: 65.h,
                      child: SfCircularChart(
                          title: ChartTitle(
                              text: "Completion Target (In %)",
                              textStyle:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          legend: Legend(
                              isVisible: true,
                              iconHeight: 5.h,
                              iconWidth: 10.w,
                              textStyle: TextStyle(fontSize: 14.sp),
                              overflowMode: LegendItemOverflowMode.wrap),
                          series: <CircularSeries<_ChartData, String>>[
                            RadialBarSeries<_ChartData, String>(
                                maximumValue: 100,
                                radius: '100%',
                                gap: '3%',
                                dataSource: chartData,
                                cornerStyle: CornerStyle.bothCurve,
                                xValueMapper: (_ChartData data, _) =>
                                    data.xData,
                                yValueMapper: (_ChartData data, _) =>
                                    data.yData,
                                dataLabelSettings: DataLabelSettings(
                                    isVisible: true,
                                    textStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                dataLabelMapper: (_ChartData data, _) =>
                                    data.text,
                                pointColorMapper: (_ChartData data, _) =>
                                    data.color),
                          ]),
                    ),
                    Text(
                      "Total Sales: ${totalSales.toString()}",
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "Monthly Sales: ${monthlySales.toString()}",
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "Daily Sales: ${dailySales.toString()}",
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 4.h,
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

class _ChartData {
  _ChartData(this.xData, this.yData, this.color, this.text);

  final String xData;
  final num yData;
  final Color color;
  final String text;
}
