import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:chef_gram/utils/RoundedButton.dart';

import '../../authentication_service.dart';
import '../../constants.dart';
import '../../main.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final phoneNoController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Column(
              children: [
                Text(
                  "Spice",
                  style: TextStyle(fontSize: 30.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                TextFormField(
                  decoration: authTextFieldDecoration,
                  controller: phoneNoController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(
                  height: 4.h,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: authTextFieldDecoration.copyWith(
                    labelText: "Password",
                    hintText: "Enter your Password",
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Align(
                  alignment: Alignment.center,
                  child: RoundedButton(
                    color: Color(0xFF004AAD),
                    onPressed: () {
                      context.read<AuthenticationService>().signIn(
                          number: phoneNoController.text.trim(),
                          password: passwordController.text.trim());
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => MyApp()));
                    },
                    text: "LOG IN",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
