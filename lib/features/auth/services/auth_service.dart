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

      // mở Hive của user
      await HiveService.instance.openUserBoxes();

      // tạo document user trên Firestore
      await FirestoreService.instance.createUser(email: email, name: name);

      // upload dữ liệu local (lần đầu gần như rỗng)
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

  // LOGIN
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // mở đúng Hive của user
      await HiveService.instance.openUserBoxes();

      // Đồng bộ từ cloud (prioritize cloud data)
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

  // LOGOUT
  Future<void> logout() async {
    await HiveService.instance.closeUserBoxes();
    await _auth.signOut();
  }
}
