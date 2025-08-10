import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

    //get current user and uid
  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUID() => _auth.currentUser!.uid;

  //login
  Future<UserCredential> loginEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw Exception(e.message);
    }
  }

  //register
  Future<UserCredential> registerEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred;
    } on FirebaseAuthException catch (e) {
      throw e.message.toString();
    }
  }

  //logout
  Future<void> logout() async {
    await _auth.signOut();
  }
  
}
