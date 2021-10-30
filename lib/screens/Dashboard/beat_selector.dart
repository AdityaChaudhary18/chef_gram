import 'dart:ffi';

import 'package:chef_gram/screens/Dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BeatSelector extends StatefulWidget {
  const BeatSelector({Key? key}) : super(key: key);

  @override
  State<BeatSelector> createState() => _BeatSelectorState();
}

class _BeatSelectorState extends State<BeatSelector> {
  var state;
  var city;
  var beat;

  List<String> states = <String>[
    "UP",
    "Bihar",
  ];
  List<String> cities = <String>[
    "C1",
    "C2",
  ];
  List<String> beats = <String>[
    "B1",
    "B2",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 2.w),
              child: DropdownButton<String>(
                value: state,
                icon: Icon(Icons.keyboard_arrow_down),
                iconSize: 28,
                elevation: 20,
                onChanged: (String? newval) {
                  setState(() {
                    state = newval;
                  });
                },
                items: states.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 2.w),
              child: DropdownButton<String>(
                value: city,
                icon: Icon(Icons.keyboard_arrow_down),
                iconSize: 28,
                elevation: 20,
                onChanged: (String? newval) {
                  setState(() {
                    city = newval;
                  });
                },
                items: cities.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 2.w),
              child: DropdownButton<String>(
                value: beat,
                icon: Icon(Icons.keyboard_arrow_down),
                iconSize: 28,
                elevation: 20,
                onChanged: (String? newval) {
                  setState(() {
                    beat = newval;
                  });
                },
                items: beats.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              child: Text("Done"),
              onPressed: () {
                print(state);
                print(city);
                print(beat);
                if (state!=null && city!=null && beat!=null)
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => Dashboard(),
                    ),
                  );
              },
            ),
          ],
        ),
      ),
    );
  }
}
