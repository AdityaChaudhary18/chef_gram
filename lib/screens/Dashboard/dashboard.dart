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
  @override
  void initState() {
    context.read<DatabaseService>().getShopsToVisit(Provider.of<Profile>(context, listen: false).shopsToVisit??[]);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<Profile>(
        builder: (context, profile, child) {
          return Column(
            children: [
              ElevatedButton(
                child: Text("Sign Out"),
                onPressed: () {
                  context.read<AuthenticationService>().signOut();
                  MaterialPageRoute<void>(
                    builder: (context) => LogInPage(),
                  );
                },
              ),
              Text(profile.name),
              Text('${profile.age}'),
              Text('${profile.city}'),
            ],
          );
        }
      ),
    );
  }
}
