import 'package:chef_gram/models/profile_model.dart';
import 'package:chef_gram/screens/Dashboard/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../database_service.dart';
import '../../main.dart';

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

  List<String> beats = [];
  List<String> stateList = [];
  List<String> cityList = [];

  void getStates() async {
    List<String> _stateList = [];
    var statesRef = await stateCollection.get();
    statesRef.docs.forEach((state) {
      _stateList.add(state.get('stateName'));
    });
    setState(() {
      stateList = _stateList;
    });
  }

  Future<void> getCities() async {
    List<String> _cityList = [];
    var cityCollection = await FirebaseFirestore.instance
        .collection('states/${state}/cities')
        .get();
    for (var city in cityCollection.docs) {
      _cityList.add(city['cityName']);
    }
    setState(() {
      cityList = _cityList;
    });
  }

  Future<void> getBeat() async {
    var beatCollection = await FirebaseFirestore.instance
        .collection('states/${state}/cities')
        .where('cityName', isEqualTo: city)
        .get();
    List<String> _beats = [];
    beatCollection.docs.first.get('beats').forEach((beat) {
      _beats.add(beat);
    });
    setState(() {
      beats = _beats;
    });
  }

  @override
  void initState() {
    getStates();

    super.initState();
  }

  var now = new DateTime.now();

  @override
  Widget build(BuildContext context) {
    if (Provider.of<Profile>(context, listen: true)
                .timeTargetUpdated
                ?.toDate()
                .day ==
            DateTime.now().day &&
        Provider.of<Profile>(context, listen: true)
                .timeTargetUpdated
                ?.toDate()
                .month ==
            DateTime.now().month &&
        Provider.of<Profile>(context, listen: true)
                .timeTargetUpdated
                ?.toDate()
                .year ==
            DateTime.now().year) {
      return Dashboard();
    } else
      return FirebaseAuth.instance.currentUser!.uid !=
              Provider.of<DatabaseService>(context, listen: false).uid
          ? MyApp()
          : SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  title: Text("Daily Target Selector"),
                  centerTitle: true,
                ),
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Logged in as,"),
                              Text(
                                Provider.of<Profile>(context).name,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Set Target for,",
                                style: TextStyle(fontSize: 10.sp),
                              ),
                              Text(
                                "${now.day}-${now.month}-${now.year}",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: 100.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 6.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Select State:",
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  DropdownButton<String>(
                                    value: state,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    iconSize: 28,
                                    elevation: 20,
                                    onChanged: (String? newval) {
                                      setState(() {
                                        state = newval;
                                        city = null;
                                        beat = null;
                                        cityList.clear();
                                        beats.clear();
                                      });
                                      getCities();
                                    },
                                    items: stateList
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Select City:",
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  DropdownButton<String>(
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
                                    items: cityList
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Select Beat:",
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  DropdownButton<String>(
                                    value: beat,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    iconSize: 28,
                                    elevation: 20,
                                    onChanged: (String? newval) {
                                      setState(() {
                                        beat = newval;
                                      });
                                    },
                                    items: beats.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 4.h,
                            ),
                            ElevatedButton(
                              child: Text("Set Target"),
                              onPressed: () {
                                if (state != null &&
                                    city != null &&
                                    beat != null) {
                                  context
                                      .read<DatabaseService>()
                                      .updateTodayTarget(state, city, beat);
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text("Select all fields first!"),
                                    backgroundColor: Colors.blue,
                                    duration: Duration(seconds: 3),
                                  ));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
  }
}
