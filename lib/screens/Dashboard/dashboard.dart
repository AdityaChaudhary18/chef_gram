import 'package:chef_gram/models/profile_model.dart';
import 'package:chef_gram/screens/auth/login.dart';
import 'package:chef_gram/screens/user_profile/end_day.dart';
import 'package:chef_gram/screens/user_profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../authentication_service.dart';
import '../../database_service.dart';
import '../add_shop.dart';
import '../excuse-page.dart';
import '../takeOrder.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool loading = false;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
        desiredAccuracy: LocationAccuracy.high);
  }

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
        'orderSuccessful': shop['orderSuccessful'],
        'latitude': shopInfo[i]['latitude'],
        'longitude': shopInfo[i]['longitude'],
      });
    }
    return shopDetails;
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Warning",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(message)],
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
                  builder: (context) => ProfilePages(),
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
              PopupMenuItem<int>(
                value: 1,
                child: Text("End Day"),
              ),
              PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 2,
                child: Text("Log Out"),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        onPressed: () {
          if (!Provider.of<Profile>(context, listen: false).hasDayEnded) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddShop()),
            );
          } else {
            _showMessage("Sorry, your day has already ended!");
          }
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
        child: (Provider.of<Profile>(context, listen: false).hasDayEnded)
            ? Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Column(
                    children: [
                      Container(
                        height: 400,
                        width: 400,
                        child: Image.asset('images/dayDone.png'),
                      ),
                      Text(
                        "Relax for Today",
                        style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Text("You have already submitted the report for today.",
                          style: TextStyle(fontSize: 10.sp)),
                      SizedBox(
                        height: 5,
                      ),
                      Text("TIP: You can reset beat to place more orders!",
                          style: TextStyle(fontSize: 10.sp)),
                    ],
                  ),
                ),
              )
            : FutureBuilder(
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
                                    offset: Offset(
                                        0, 3), // changes position of shadow
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
                                            ? snapshot.data[index]
                                                    ["orderSuccessful"]
                                                ? Colors.green
                                                : Colors.deepPurple
                                            : Colors.red,
                                        child: Icon(snapshot.data[index]
                                                ['isVisited']
                                            ? snapshot.data[index]
                                                    ["orderSuccessful"]
                                                ? FontAwesomeIcons.checkDouble
                                                : Icons.check
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
                                      onTap: () async {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              "Checking Location. Please wait..."),
                                          backgroundColor: Colors.blue,
                                        ));
                                        await _determinePosition()
                                            .then((value) {
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                          if (Geolocator.distanceBetween(
                                                  value.latitude,
                                                  value.longitude,
                                                  snapshot.data[index]
                                                      ['latitude'],
                                                  snapshot.data[index]
                                                      ['longitude']) <
                                              100) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TakeOrder(
                                                          shopDetails: snapshot
                                                              .data[index])),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Get within 100 meter of location"),
                                              backgroundColor: Colors.red,
                                              duration:
                                                  Duration(milliseconds: 3000),
                                            ));
                                          }
                                        });
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
                                      onTap: () async {
                                        if (snapshot.data[index]["isVisited"]) {
                                          final snackBar = SnackBar(
                                            backgroundColor: Colors.lightBlue,
                                            duration: Duration(seconds: 2),
                                            content: Text(
                                              "Attendance Marked Successfully",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                "Checking Location. Please wait..."),
                                            backgroundColor: Colors.blue,
                                          ));
                                          await _determinePosition()
                                              .then((value) {
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar();
                                            if (Geolocator.distanceBetween(
                                                    value.latitude,
                                                    value.longitude,
                                                    snapshot.data[index]
                                                        ['latitude'],
                                                    snapshot.data[index]
                                                        ['longitude']) <
                                                100) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ExcusePage(
                                                              shopRef: snapshot
                                                                  .data[index][
                                                                      'shopRef']
                                                                  .toString())));
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Get within 100 meter of location"),
                                                backgroundColor: Colors.red,
                                                duration: Duration(
                                                    milliseconds: 3000),
                                              ));
                                            }
                                          });
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
      if (!Provider.of<Profile>(context, listen: false).hasDayEnded) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Warning",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Center(
                      child: Text(
                        "Are you sure you want to end your day?",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      "This action cannot be undone!",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text("Yes"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EndDay(),
                        ));
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Warning",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[Text("You already ended your Day!")],
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
      break;
    case 2:
      context.read<AuthenticationService>().signOut();
      break;
  }
}
