// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CustomerRepository _customerRepository = CustomerRepository();

  // Stream để lắng nghe trạng thái đăng nhập
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  // Đăng ký
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? address,
    List<String>? preferences,
  }) async {
    try {
      // Tạo tài khoản Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Tạo customer record trong Firestore
      final customer = CustomerModel(
        customerId: userCredential.user!.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address ?? '',
        preferences: preferences ?? [],
        loyaltyPoints: 0,
        createdAt: Timestamp.now(),
        isActive: true,
      );

      await _customerRepository.addCustomer(customer);

      // Lưu thông tin vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('customerId', customer.customerId);
      await prefs.setString('customerEmail', customer.email);
      await prefs.setString('customerName', customer.fullName);

      return userCredential;
    } catch (e) {
      throw Exception('Đăng ký thất bại: $e');
    }
  }

  // Đăng nhập
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy thông tin customer từ Firestore
      final customer =
          await _customerRepository.getCustomerById(userCredential.user!.uid);
      if (customer != null) {
        // Lưu thông tin vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('customerId', customer.customerId);
        await prefs.setString('customerEmail', customer.email);
        await prefs.setString('customerName', customer.fullName);
      }

      return userCredential;
    } catch (e) {
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await _auth.signOut();

      // Xóa thông tin từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('customerId');
      await prefs.remove('customerEmail');
      await prefs.remove('customerName');
    } catch (e) {
      throw Exception('Đăng xuất thất bại: $e');
    }
  }

  // Kiểm tra trạng thái đăng nhập
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');
    return customerId != null &&
        customerId.isNotEmpty &&
        _auth.currentUser != null;
  }

  // Lấy thông tin customer hiện tại
  Future<CustomerModel?> getCurrentCustomer() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _customerRepository.getCustomerById(user.uid);
    }
    return null;
  }

  // Cập nhật thông tin customer
  Future<void> updateCustomerProfile({
    required String customerId,
    String? fullName,
    String? phoneNumber,
    String? address,
    List<String>? preferences,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['fullName'] = fullName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (address != null) updates['address'] = address;
      if (preferences != null) updates['preferences'] = preferences;

      await _firestore.collection('customers').doc(customerId).update(updates);

      // Cập nhật SharedPreferences nếu cần
      final prefs = await SharedPreferences.getInstance();
      if (fullName != null) await prefs.setString('customerName', fullName);
    } catch (e) {
      throw Exception('Cập nhật thông tin thất bại: $e');
    }
  }
}
