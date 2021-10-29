import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../../authentication_service.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            child: Text("Sign Out"),
            onPressed: () {
              context.read<AuthenticationService>().signOut();
            },
          ),
        ],
      ),
    );
  }
}
