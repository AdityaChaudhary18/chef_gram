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

  final formGlobalKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneNoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Form(
              key: formGlobalKey,
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
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      return null;
                    },
                    maxLength: 10,
                    decoration: authTextFieldDecoration,
                    controller: phoneNoController,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
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
                      onPressed: () async {
                        if (formGlobalKey.currentState!.validate()) {
                          formGlobalKey.currentState!.save();

                          await context
                              .read<AuthenticationService>()
                              .signIn(
                                  number: phoneNoController.text.trim(),
                                  password: passwordController.text.trim())
                              .then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(value),
                              backgroundColor: Colors.blue,
                              duration: Duration(milliseconds: 4000),
                            ));
                            if (value == 'Signed In Successfully') {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyApp()));
                            }
                          });
                        }
                      },
                      text: "LOG IN",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
