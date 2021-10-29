import 'package:chef_gram/models/employee_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class AuthenticationService with ChangeNotifier {
  Employee _employee = Employee(name: '', age: 0);
  Employee get employee => _employee;
  final FirebaseAuth _firebaseAuth;
  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
  Future<String> signIn(
      {required String name, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: "$name@spice.com", password: password);
      print(_firebaseAuth.currentUser!.uid);
      return "Signed In Successfully";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "error";
    }
  }
}
