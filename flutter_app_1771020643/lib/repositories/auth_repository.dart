import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Đăng ký tài khoản mới
  Future<User?> signUp(String email, String password, String fullName) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = result.user;

    if (user != null) {
      // Lưu thông tin bổ sung vào Firestore collection 'customers'
      await _db.collection('customers').doc(user.uid).set({
        'customerId': user.uid,
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return user;
  }

  // Đăng nhập
  Future<User?> signIn(String email, String password) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  // Đăng xuất
  Future<void> signOut() async => await _auth.signOut();
}