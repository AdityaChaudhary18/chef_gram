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
  String state = 'none';

  String city = 'none';

  String beat = 'none';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            ElevatedButton(
              child: Text("Done"),
              onPressed: () {
                print(state);
                print(city);
                print(beat);

                if (state != "none" && city != "none" && beat != "none") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const Dashboard(),
                    ),
                  );
                }
              },
            ),
            dropDown(
              hint: "State",
              items: <String>[
                'UP',
                'Bihar',
              ],
            ),
            dropDown(
              hint: "City",
              items: <String>[
                'City1',
                'City2',
              ],
            ),
            dropDown(
              hint: "Beat",
              items: <String>[
                'Nagar1',
                'Nagar2',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding dropDown({required String hint, required List items}) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: DropdownButton<String>(
        icon: const Icon(Icons.arrow_drop_down),
        hint: Text(hint),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        underline: Container(
          height: 2,
          color: Colors.blueGrey,
        ),
        onChanged: (String? newValue) {
          setState(() {
            if (hint == "State") state = newValue!;
            if (hint == "City") city = newValue!;
            if (hint == "Beat") beat = newValue!;
          });
        },
        items: items.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
