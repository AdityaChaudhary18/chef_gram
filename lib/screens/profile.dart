import 'package:chef_gram/models/profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var lastMidnight = DateTime(now.year, now.month, now.day);
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('orderTakenBy',
                  isEqualTo: Provider.of<Profile>(context, listen: false)
                      .name
                      .toString())
              .orderBy('dateTime', descending: true)
              .where("dateTime", isGreaterThan: lastMidnight)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            snapshot.data!.docs.forEach((element) {
              print(element["customerName"]);
            });
            return Column(
              children: [Text("hi")],
            );
          },
        ),
      ),
    );
  }
}
