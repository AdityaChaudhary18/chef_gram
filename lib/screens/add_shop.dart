import 'package:chef_gram/models/profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../constants.dart';

class AddShop extends StatefulWidget {
  const AddShop({Key? key}) : super(key: key);

  @override
  _AddShopState createState() => _AddShopState();
}

class _AddShopState extends State<AddShop> {
  final shopNameController = TextEditingController();
  final addressController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneNoController = TextEditingController();
  final emailController = TextEditingController();
  final pinCodeController = TextEditingController();

  void addShop() {
    Map<String, dynamic> data = {
      "address": addressController.value.text,
      "email": emailController.value.text,
      "beat": Provider.of<Profile>(context, listen: false).targetData!['beat'],
      "phoneNo": phoneNoController.value.text,
      "shopName": shopNameController.value.text,
      "shopOwner": ownerNameController.value.text,
      "employeeName": Provider.of<Profile>(context, listen: false).name
    };

    CollectionReference shops = FirebaseFirestore.instance.collection('shopPermission');
    shops.add(data);
    Navigator.pop(context);
  }

  void dispose() {
    shopNameController.dispose();
    ownerNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    pinCodeController.dispose();
    phoneNoController.dispose();
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
            ),
            SizedBox(
              height: 2.h,
            ),
            TextFormField(
              controller: ownerNameController,
              decoration: authTextFieldDecoration.copyWith(
                labelText: "Owner Name",
                hintText: "Enter Owner's Name",
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: phoneNoController,
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
              controller: addressController,
              decoration: authTextFieldDecoration.copyWith(
                labelText: "Address",
                hintText: "Enter shop Address",
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            TextFormField(
              controller: pinCodeController,
              decoration: authTextFieldDecoration.copyWith(
                labelText: "Pin Code",
                hintText: "Enter shop pin code",
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            ElevatedButton(
              child: Text("Add Shop"),
              onPressed: () {
                addShop();
              },
            ),
            Text(
              "This will get updated only after Admin Approves your request",
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
