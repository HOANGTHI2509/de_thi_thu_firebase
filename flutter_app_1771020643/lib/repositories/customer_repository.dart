import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';
import '../services/database_service.dart';

class CustomerRepository {
  // Lấy tham chiếu collection từ DatabaseService đã thiết lập ở Phần 1
  final CollectionReference _custCollection = DatabaseService().customersRef;

  // 1. Thêm Customer (3 điểm)
  Future<void> addCustomer(Customer customer) async {
    await _custCollection.doc(customer.customerId).set(customer.toMap());
  }

  // 2. Lấy Customer theo ID (2 điểm)
  Future<Customer?> getCustomerById(String id) async {
    DocumentSnapshot doc = await _custCollection.doc(id).get();
    if (doc.exists) {
      return Customer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // 3. Lấy tất cả Customers (2 điểm)
  Stream<List<Customer>> getAllCustomers() {
    return _custCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Customer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 4. Cập nhật thông tin Customer (3 điểm)
  Future<void> updateCustomer(String id, Map<String, dynamic> data) async {
    await _custCollection.doc(id).update(data);
  }

  // 5. Cập nhật Loyalty Points (2 điểm)
  // Sử dụng FieldValue.increment để cộng dồn điểm trực tiếp trên Server
  Future<void> updateLoyaltyPoints(String customerId, int points) async {
    await _custCollection.doc(customerId).update({
      'loyaltyPoints': FieldValue.increment(points),
    });
  }
}