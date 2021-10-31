import 'package:chef_gram/models/profile_model.dart';
import 'package:chef_gram/screens/auth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
        in Provider.of<DatabaseService>(context, listen: true).shopsToVisit) {
      await FirebaseFirestore.instance.doc(shop["shopRef"].path).get().then(
            (value) => shopDetails.add({
              "shopName": value["shopName"],
              "shopOwner": value["shopOwner"],
              'isVisited': shop['isVisited']
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
        centerTitle: true,
        elevation: 10,
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
      body: Container(
        child: FutureBuilder(
          future: getShops(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
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
                            onTap: () {},
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
                            onTap: () {},
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
