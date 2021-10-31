import 'package:chef_gram/models/profile_model.dart';
import 'package:chef_gram/screens/auth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';

import '../../authentication_service.dart';
import '../../database_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  Future<List> getShops() async {
    List<Map<String, dynamic>> shopDetails = [];
    shopDetails.clear();
    for (var shop
        in Provider.of<DatabaseService>(context).shopsToVisit) {
      await FirebaseFirestore.instance.doc(shop["shopRef"].path).get().then(
            (value) => shopDetails.add({
              "shopName": value["shopName"],
              "shopOwner": value["shopOwner"]
            }),
          );
    }
    return shopDetails;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        leading: ElevatedButton(
          style: ButtonStyle(elevation: MaterialStateProperty.all(0.0)),
          child: Icon(Icons.refresh),
          onPressed: () {
            getShops();
          },
        ),
        title: Text("Dashboard"),
        actions: [
          ElevatedButton(
            style: ButtonStyle(elevation: MaterialStateProperty.all(0.0)),
            child: Icon(Icons.logout),
            onPressed: () {
              context.read<AuthenticationService>().signOut();
              MaterialPageRoute<void>(
                builder: (context) => LogInPage(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            child: FutureBuilder(
              future: getShops(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    children: [
                      Text('No DATA'),
                    ],
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                          child: Padding(
                            padding:
                            EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data[index]['shopName'],
                                  style: TextStyle(fontSize: 18.sp),
                                ),
                                Text(snapshot.data[index]['shopOwner']),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


