import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
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
          email: name, password: password);
      return "Signed In Successfully";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "error";
    }
  }
}
