import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class UpdateApp extends StatelessWidget {
  const UpdateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update App"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(height: 70.h, child: Image.asset('images/update_app.png')),
          Container(
            height: 10.h,
            child: Text(
              "Use the latest version of app to continue!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
