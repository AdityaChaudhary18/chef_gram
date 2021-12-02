import 'package:chef_gram/models/profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../constants.dart';
import '../database_service.dart';
import '../main.dart';

class AddShop extends StatefulWidget {
  const AddShop({Key? key}) : super(key: key);

  @override
  _AddShopState createState() => _AddShopState();
}

class _AddShopState extends State<AddShop> {
  final formGlobalKey = GlobalKey<FormState>();
  late var location;
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Loader.hide();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Attention Required",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('You will be redirected to location settings'),
                  Text('Allow location services to use app')
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text("OK"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Geolocator.openLocationSettings();
                },
              ),
            ],
          );
        },
      );
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      Loader.hide();
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Loader.hide();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Attention Required",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Enable location permission to use app'),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text("OK"),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await Geolocator.openAppSettings();
                  },
                ),
              ],
            );
          },
        );
        await Geolocator.requestPermission();
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Loader.hide();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Attention Required",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('You will be redirected to settings app'),
                  Text(
                      'Allow location permission in app settings to "Allow while using App"')
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text("OK"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Geolocator.openAppSettings();
                },
              ),
            ],
          );
        },
      );

      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  final shopNameController = TextEditingController();
  final addressController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneNoController = TextEditingController();
  final emailController = TextEditingController();

  void addShop() async {
    Map<String, dynamic> data = {
      "state":
          Provider.of<Profile>(context, listen: false).targetData!['state'],
      "city": Provider.of<Profile>(context, listen: false).targetData!['city'],
      "address": addressController.value.text,
      "email": emailController.value.text,
      "beat": Provider.of<Profile>(context, listen: false).targetData!['beat'],
      "phoneNo": double.parse(phoneNoController.value.text).toInt(),
      "shopName": shopNameController.value.text,
      "shopOwner": ownerNameController.value.text,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'isLocationMandatory': true,
    };
    var id = '';
    CollectionReference shops = FirebaseFirestore.instance.collection('shops');
    shops.add(data).then((value) async {
      id = value.id;
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(Provider.of<DatabaseService>(context, listen: false).uid)
          .get();
      List shopsToVisit = doc.get('targetData.shopsToVisit');
      shopsToVisit.add({
        'comment': "Not Visited",
        'isVisited': false,
        'orderSuccessful': false,
        'shopRef': 'shops/${id}'
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(Provider.of<DatabaseService>(context, listen: false).uid)
          .update({'targetData.shopsToVisit': shopsToVisit});
      Provider.of<DatabaseService>(context, listen: false).clearShopsToVisit();
      Loader.hide();
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyApp()));
    });
  }

  void dispose() {
    shopNameController.dispose();
    ownerNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    phoneNoController.dispose();
    Loader.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String beat =
        Provider.of<Profile>(context, listen: false).targetData!['beat'];
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Shop to $beat"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formGlobalKey,
          child: Column(
            children: [
              SizedBox(
                height: 10.h,
              ),
              TextFormField(
                controller: shopNameController,
                decoration: authTextFieldDecoration.copyWith(
                  labelText: "Shop Name",
                  hintText: "Enter Shop's Name",
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 2.h,
              ),
              TextFormField(
                controller: ownerNameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                decoration: authTextFieldDecoration.copyWith(
                  labelText: "Owner Name",
                  hintText: "Enter Owner's Name",
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              TextFormField(
                maxLength: 10,
                keyboardType: TextInputType.number,
                controller: phoneNoController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
                decoration: authTextFieldDecoration.copyWith(
                  labelText: "Phone Number",
                  hintText: "Enter Shop Owner's Phone Number",
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                decoration: authTextFieldDecoration.copyWith(
                  labelText: "Email",
                  hintText: "Enter Email Address",
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
                controller: addressController,
                decoration: authTextFieldDecoration.copyWith(
                  labelText: "Address",
                  hintText: "Enter shop Address",
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              ElevatedButton(
                child: Text("Add Shop"),
                onPressed: () async {
                  if (formGlobalKey.currentState!.validate()) {
                    formGlobalKey.currentState!.save();
                    Loader.show(context);
                    location = await _determinePosition();
                    addShop();
                  }
                },
              ),
              Text(
                "Add shop only when you are at the location.",
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
