import 'package:chef_gram/models/profile_model.dart';
import 'package:chef_gram/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../authentication_service.dart';
import '../../database_service.dart';
import '../add_shop.dart';
import '../excuse-page.dart';
import '../user_profile/profile.dart';
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
        'phoneNo': shopInfo[i]["phoneNo"],
        "email": shopInfo[i]["email"],
      });
    }
    return shopDetails;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    void _showDialog(String shopName, String shopOwner, String address,
        String PhoneNo, String email) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              shopName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("Owner Name: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(shopOwner),
                  Text(""),
                  Text("Email: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(email),
                  Text(""),
                  Text("Shop Address: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    address,
                  ),
                  Text(""),
                  Text("Phone Number: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  GestureDetector(
                    child: Text(
                      PhoneNo,
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () => setState(() {
                      _makePhoneCall('tel:+91$PhoneNo');
                    }),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        leading: ElevatedButton(
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(0.0),
              backgroundColor: MaterialStateProperty.all(Colors.indigo)),
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
        backgroundColor: Colors.indigo,
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
                          child: Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: snapshot.data[index]
                                          ['isVisited']
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
                                onTap: () {
                                  _showDialog(
                                    snapshot.data[index]['shopName'],
                                    snapshot.data[index]['shopOwner'],
                                    snapshot.data[index]['address'],
                                    snapshot.data[index]['phoneNo'],
                                    snapshot.data[index]['email'],
                                  );
                                },
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
