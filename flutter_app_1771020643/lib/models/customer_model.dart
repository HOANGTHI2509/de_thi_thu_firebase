// lib/models/customer_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String customerId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String address;
  final List<String> preferences;
  final int loyaltyPoints;
  final Timestamp createdAt;
  final bool isActive;

  CustomerModel({
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

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'preferences': preferences,
      'loyaltyPoints': loyaltyPoints,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: json['customerId'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      preferences: List<String>.from(json['preferences'] ?? []),
      loyaltyPoints: (json['loyaltyPoints'] ?? 0) as int,
      createdAt: json['createdAt'] ?? Timestamp.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  CustomerModel copyWith({
    String? customerId,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? address,
    List<String>? preferences,
    int? loyaltyPoints,
    Timestamp? createdAt,
    bool? isActive,
  }) {
    return CustomerModel(
      customerId: customerId ?? this.customerId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      preferences: preferences ?? this.preferences,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'CustomerModel(customerId: $customerId, fullName: $fullName, email: $email, loyaltyPoints: $loyaltyPoints)';
  }
}