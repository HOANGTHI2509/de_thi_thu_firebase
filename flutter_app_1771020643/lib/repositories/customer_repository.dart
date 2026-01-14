// lib/repositories/customer_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Thêm Customer
  Future<void> addCustomer(CustomerModel customer) async {
    try {
      await _firestore
          .collection('customers')
          .doc(customer.customerId)
          .set(customer.toJson());
    } catch (e) {
      throw Exception('Lỗi thêm khách hàng: $e');
    }
  }

  // 2. Lấy Customer theo ID
  Future<CustomerModel?> getCustomerById(String customerId) async {
    try {
      final doc =
          await _firestore.collection('customers').doc(customerId).get();
      if (doc.exists) {
        return CustomerModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi lấy khách hàng: $e');
    }
  }

  // 3. Lấy tất cả Customers
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      final snapshot = await _firestore.collection('customers').get();
      return snapshot.docs
          .map((doc) => CustomerModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách khách hàng: $e');
    }
  }

  // 4. Cập nhật Customer
  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _firestore
          .collection('customers')
          .doc(customer.customerId)
          .update(customer.toJson());
    } catch (e) {
      throw Exception('Lỗi cập nhật khách hàng: $e');
    }
  }

  // 5. Cập nhật Loyalty Points - CHUẨN ĐỀ
  Future<void> updateLoyaltyPoints(String customerId, int points) async {
    try {
      await _firestore.collection('customers').doc(customerId).update({
        'loyaltyPoints': FieldValue.increment(points),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật điểm tích lũy: $e');
    }
  }

  // 6. Lấy Customer theo email (cho đăng nhập)
  Future<CustomerModel?> getCustomerByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('customers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return CustomerModel.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi tìm khách hàng theo email: $e');
    }
  }

  // 7. Stream tất cả Customers (real-time)
  Stream<List<CustomerModel>> getAllCustomersStream() {
    return _firestore
        .collection('customers')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerModel.fromJson(doc.data()))
            .toList());
  }
}