import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // REGISTER
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _auth.currentUser?.updateDisplayName(name);

      return null;
    } on FirebaseAuthException catch (e) {
      print("FIREBASE ERROR: ${e.code}");
      print("MESSAGE: ${e.message}");

      return e.message;
    } catch (e) {
      print("OTHER ERROR: $e");

      return e.toString();
    }
  }

  // LOGIN
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
      print("FIREBASE ERROR: ${e.code}");
      print("MESSAGE: ${e.message}");

      return e.message;
    } catch (e) {
      print("OTHER ERROR: $e");

      return e.toString();
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
