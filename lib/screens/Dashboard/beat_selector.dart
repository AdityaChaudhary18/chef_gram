import 'dart:ffi';

import 'package:chef_gram/models/profile_model.dart';
import 'package:chef_gram/screens/Dashboard/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../database_service.dart';

class BeatSelector extends StatefulWidget {
  const BeatSelector({Key? key}) : super(key: key);

  @override
  State<BeatSelector> createState() => _BeatSelectorState();
}

class _BeatSelectorState extends State<BeatSelector> {
  static CollectionReference stateCollection =
      FirebaseFirestore.instance.collection('states');
  var state;
  var city;
  var beat;

  Map<String, dynamic> stateMap = {};
  Map<String, dynamic> cityMap = {};
  List<String> beats = [];

  void getStates() async {
    Map<String, dynamic> _stateMap = {};
    var statesRef = await stateCollection.get();
    statesRef.docs.forEach((state) {
      _stateMap[state.get('stateName')] = state.get('cities');
    });
    setState(() {
      stateMap = _stateMap;
    });
  }

  Future<void> getCities() async {
    cityMap.clear();
    Map<String, dynamic> _cityMap = {};
    List cityList = stateMap[state];
    for (DocumentReference city in cityList) {
      var cityDoc = await FirebaseFirestore.instance.doc(city.path).get();
      _cityMap[cityDoc.get('cityName')] = cityDoc.get('beats');
    }
    setState(() {
      cityMap = _cityMap;
    });
  }

  Future<void> getBeat() async {
    beats.clear();
    List<String> _beats = [];
    List beatList = cityMap[city];
    for (DocumentReference beat in beatList) {
      var beatDoc = await FirebaseFirestore.instance.doc(beat.path).get();
      _beats.add(beatDoc.get('beatName'));
    }
    setState(() {
      beats = _beats;
    });
  }

  @override
  void initState() {
    getStates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<Profile>(builder: (context, profile, child) {
          if (profile.state != '' &&
              profile.city != '' &&
              profile.beat != '' &&
              profile.timeTargetUpdated?.toDate().day == DateTime.now().day) {
            return Dashboard();
          } else
            return Column(
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
                        city = null;
                        beat = null;
                      });
                      getCities();
                    },
                    items: stateMap.keys
                        .toList()
                        .map<DropdownMenuItem<String>>((String value) {
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
                        beat = null;
                      });
                      getBeat();
                    },
                    items: cityMap.keys
                        .toList()
                        .map<DropdownMenuItem<String>>((String value) {
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
                    if (state != null && city != null && beat != null) {
                      context
                          .read<DatabaseService>()
                          .updateTodayTarget(state, city, beat);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => Dashboard(),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
        }),
      ),
    );
  }
}
