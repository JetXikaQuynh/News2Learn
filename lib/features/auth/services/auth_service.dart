import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/hive_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/sync_service.dart';

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

      await HiveService.instance.openUserBoxes();

      await FirestoreService.instance.createUser(email: email, name: name);

      await FirestoreService.instance.uploadAll();

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

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      await HiveService.instance.openUserBoxes();

      await SyncService.instance.syncFromCloud();

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

  Future<void> logout() async {
    await HiveService.instance.closeUserBoxes();
    await _auth.signOut();
  }
}
