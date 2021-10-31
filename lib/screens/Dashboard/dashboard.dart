import 'package:chef_gram/models/profile_model.dart';
import 'package:chef_gram/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';

import '../../authentication_service.dart';
import '../../database_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isLoading = true;
  List<Map<String, dynamic>> shopList = [];

  void getShopsToVisitToday() async {
    shopList = await context.read<DatabaseService>().getShopsToVisit();
    print(isLoading);
    if (shopList.length != 0) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    getShopsToVisitToday();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: Text("Dashboard"),
        actions: [
          ElevatedButton(onPressed: (){
          }, child: Text(isLoading.toString())),
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
      body: Consumer<Profile>(builder: (context, profile, child) {
        if (isLoading) {
          print('hello');
          // getShopsToVisitToday();
          return CircularProgressIndicator();
        }
        return Column(
          children: [
            Text(profile.name),
            Text('${profile.age}'),
            Text('${profile.city}'),
            Text(shopList[0]['shopName']),
          ],
        );
      }),
    );
  }
}
