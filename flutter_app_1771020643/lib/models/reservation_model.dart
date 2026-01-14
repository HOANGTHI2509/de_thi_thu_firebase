// lib/models/reservation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String reservationId;
  final String customerId;
  final Timestamp reservationDate;
  final int numberOfGuests;
  final String? tableNumber;
  final String status;
  final String? specialRequests;
  final List<Map<String, dynamic>> orderItems;
  final double subtotal;
  final double serviceCharge;
  final double discount;
  final double total;
  final String? paymentMethod;
  final String paymentStatus;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ReservationModel({
    required this.reservationId,
    required this.customerId,
    required this.reservationDate,
    required this.numberOfGuests,
    this.tableNumber,
    required this.status,
    this.specialRequests,
    required this.orderItems,
    required this.subtotal,
    required this.serviceCharge,
    required this.discount,
    required this.total,
    this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'reservationId': reservationId,
      'customerId': customerId,
      'reservationDate': reservationDate,
      'numberOfGuests': numberOfGuests,
      'tableNumber': tableNumber,
      'status': status,
      'specialRequests': specialRequests,
      'orderItems': orderItems,
      'subtotal': subtotal,
      'serviceCharge': serviceCharge,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      reservationId: json['reservationId'] ?? '',
      customerId: json['customerId'] ?? '',
      reservationDate: json['reservationDate'] ?? Timestamp.now(),
      numberOfGuests: (json['numberOfGuests'] ?? 1) as int,
      tableNumber: json['tableNumber'],
      status: json['status'] ?? 'pending',
      specialRequests: json['specialRequests'],
      orderItems: List<Map<String, dynamic>>.from(json['orderItems'] ?? []),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      serviceCharge: (json['serviceCharge'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'] ?? 'pending',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
    );
  }

  ReservationModel copyWith({
    String? reservationId,
    String? customerId,
    Timestamp? reservationDate,
    int? numberOfGuests,
    String? tableNumber,
    String? status,
    String? specialRequests,
    List<Map<String, dynamic>>? orderItems,
    double? subtotal,
    double? serviceCharge,
    double? discount,
    double? total,
    String? paymentMethod,
    String? paymentStatus,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ReservationModel(
      reservationId: reservationId ?? this.reservationId,
      customerId: customerId ?? this.customerId,
      reservationDate: reservationDate ?? this.reservationDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      specialRequests: specialRequests ?? this.specialRequests,
      orderItems: orderItems ?? this.orderItems,
      subtotal: subtotal ?? this.subtotal,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReservationModel(reservationId: $reservationId, customerId: $customerId, status: $status, total: $total)';
  }
}