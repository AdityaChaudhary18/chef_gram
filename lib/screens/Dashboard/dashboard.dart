import 'package:chef_gram/models/profile_model.dart';
import 'package:chef_gram/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';

import '../../authentication_service.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: Consumer<Profile>(builder: (context, profile, child) {
        return Column(
          children: [
            Text(profile.name),
            Text('${profile.age}'),
            Text('${profile.city}'),
          ],
        );
      }),
    );
  }
}
