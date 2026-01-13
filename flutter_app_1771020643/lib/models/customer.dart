import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String customerId; // ID duy nhất
  final String email;
  final String fullName;
  final String phoneNumber;
  final String address;
  final List<String> preferences; // Mảng sở thích ăn uống
  final int loyaltyPoints; // Điểm tích lũy (mặc định 0)
  final DateTime createdAt;
  final bool isActive;

  Customer({
    required this.customerId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.preferences,
    this.loyaltyPoints = 0,
    required this.createdAt,
    this.isActive = true,
  });

  // Chuyển Object sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'preferences': preferences,
      'loyaltyPoints': loyaltyPoints,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  // Chuyển dữ liệu từ Firestore (Map) về Object Customer
  factory Customer.fromMap(Map<String, dynamic> map, String id) {
    return Customer(
      customerId: id,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      // Xử lý mảng preferences an toàn
      preferences: List<String>.from(map['preferences'] ?? []),
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
      // Chuyển đổi Timestamp thành DateTime
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }
}