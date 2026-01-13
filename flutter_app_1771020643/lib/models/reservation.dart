import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String reservationId;
  final String customerId;
  final DateTime reservationDate;
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
  final DateTime createdAt;

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
    this.discount = 0.0,
    required this.total,
    this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'reservationDate': Timestamp.fromDate(reservationDate),
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
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}