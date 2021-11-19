import 'package:chef_gram/models/profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../database_service.dart';

class EndDay extends StatefulWidget {
  const EndDay({Key? key}) : super(key: key);

  @override
  _EndDayState createState() => _EndDayState();
}

class _EndDayState extends State<EndDay> {
  Future<List> getShopInfo() async {
    return await Provider.of<DatabaseService>(context, listen: false)
        .getShopInfo(
            Provider.of<Profile>(context, listen: false).targetData!['beat']);
  }

  Future<List> getShops() async {
    List shopInfo = await getShopInfo();
    List shopDetails = [];
    for (int i = 0; i < shopInfo.length; i++) {
      var shop =
          Provider.of<DatabaseService>(context, listen: false).shopsToVisit[i];
      shopDetails.add({
        "shopName": shopInfo[i]["shopName"],
        "shopOwner": shopInfo[i]["shopOwner"],
        'isVisited': shop['isVisited'],
        'shopRef': shop['shopRef'],
        'address': shopInfo[i]["address"],
        'phoneNo': shopInfo[i]["phoneNo"],
        "email": shopInfo[i]["email"],
        "comment": shop['comment'],
        'orderSuccessful': shop['orderSuccessful'],
      });
    }
    return shopDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: Text("End Day"),
      ),
      body: Container(
        child: FutureBuilder(
          future: getShops(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.h),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: snapshot.data[index]
                                        ['isVisited']
                                    ? snapshot.data[index]["orderSuccessful"]
                                        ? Colors.green
                                        : Colors.deepPurple
                                    : Colors.red,
                                child: Icon(snapshot.data[index]['isVisited']
                                    ? snapshot.data[index]["orderSuccessful"]
                                        ? FontAwesomeIcons.checkDouble
                                        : Icons.check
                                    : Icons.clear),
                                foregroundColor: Colors.white,
                              ),
                              title: Text(
                                snapshot.data[index]['shopName'],
                                style: TextStyle(fontSize: 18.sp),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data[index]['shopOwner'],
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  Text(
                                    snapshot.data[index]['comment'],
                                    style: TextStyle(fontSize: 10.sp),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
