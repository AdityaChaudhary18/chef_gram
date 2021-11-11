import 'package:chef_gram/models/profile_model.dart';
import 'package:chef_gram/screens/auth/login.dart';
import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../authentication_service.dart';
import '../../database_service.dart';
import '../add_shop.dart';
import '../excuse-page.dart';
import '../profile.dart';
import '../takeOrder.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isExtended = false;
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
        'phoneNo': shopInfo[i]["phoneNo"]
      });
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
        leading: ElevatedButton(
          style: ButtonStyle(elevation: MaterialStateProperty.all(0.0)),
          child: Icon(Icons.account_circle),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ));
          },
        ),
        centerTitle: true,
        elevation: 10,
        title: Text("Dashboard"),
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Text("Reset Beat"),
              ),
              PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 1,
                child: Text("Log Out"),
              )
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddShop()),
          );
        },
        label: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(Icons.add),
            ),
            Text("Add Shop")
          ],
        ),
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
                      Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: Container(
                          color: Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: snapshot.data[index]['isVisited']
                                  ? Colors.indigoAccent
                                  : Colors.red,
                              child: Icon(snapshot.data[index]['isVisited']
                                  ? Icons.check
                                  : Icons.clear),
                              foregroundColor: Colors.white,
                            ),
                            title: Text(
                              snapshot.data[index]['shopName'],
                              style: TextStyle(fontSize: 18.sp),
                            ),
                            subtitle: Text(
                              snapshot.data[index]['shopOwner'],
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                        ),
                        secondaryActions: [
                          IconSlideAction(
                            caption: 'Take Order',
                            color: Colors.blue,
                            icon: Icons.add,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TakeOrder(
                                        shopDetails: snapshot.data[index])),
                              );
                            },
                          ),
                          IconSlideAction(
                            caption: 'Get Details',
                            color: Colors.deepPurple,
                            icon: Icons.info_outline,
                            onTap: () {},
                          ),
                          IconSlideAction(
                            caption: 'Mark Entry',
                            color: Colors.green,
                            icon: Icons.check,
                            onTap: () {
                              if (snapshot.data[index]["isVisited"]) {
                                final snackBar = SnackBar(
                                  backgroundColor: Colors.lightBlue,
                                  duration: Duration(seconds: 2),
                                  content: Text(
                                    "Attendance Marked Successfully",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ExcusePage(
                                            shopRef: snapshot.data[index]
                                                    ['shopRef']
                                                .toString())));
                              }
                            },
                          ),
                        ],
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

void onSelected(BuildContext context, int item) {
  switch (item) {
    case 0:
      Provider.of<DatabaseService>(context, listen: false).resetBeatDate();
      break;
    case 1:
      context.read<AuthenticationService>().signOut();
      MaterialPageRoute<void>(
        builder: (context) => LogInPage(),
      );
      break;
  }
}
