import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../database_service.dart';
import 'Dashboard/dashboard.dart';

class ExcusePage extends StatefulWidget {
  ExcusePage({Key? key, this.shopRef}) : super(key: key);
  var shopRef;

  @override
  State<ExcusePage> createState() => _ExcusePageState();
}

class _ExcusePageState extends State<ExcusePage> {
  List<String> location = [
    'Shop was closed',
    'Owner not available',
    'Are not Interested',
    'Bill outstanding',
    'Financial Issues',
    'Distribution Issues',
    "Others"
  ];
  var dropdownValue;
  Future<void> markAttendance() async {
    var doc = await FirebaseFirestore.instance
        .doc(
            'users/${Provider.of<DatabaseService>(context, listen: false).uid}')
        .get();
    List visits = doc.get('targetData.shopsToVisit');
    for (int i = 0; i < visits.length; i++) {
      if (visits[i]['shopRef'].toString() == widget.shopRef) {
        visits[i]["isVisited"] = true;
        visits[i]["comment"] = dropdownValue.toString();
        break;
      }
    }
    FirebaseFirestore.instance
        .doc(
            'users/${Provider.of<DatabaseService>(context, listen: false).uid}')
        .update({"targetData.shopsToVisit": visits});
    Navigator.pop(
        context, MaterialPageRoute(builder: (context) => Dashboard()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mark Attendance"),
      ),
      body: Container(
        width: 100.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButton<String>(
              hint: Text('Reasons'),
              value: dropdownValue,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: location.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              child: Text("Mark Attendance"),
              onPressed: () {
                if (dropdownValue != null)
                  markAttendance();
                else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Select a reason first!"),
                    backgroundColor: Colors.red,
                    duration: Duration(milliseconds: 3000),
                  ));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
