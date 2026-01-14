// lib/repositories/reservation_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation_model.dart';
import '../models/menu_item_model.dart';
import 'menu_item_repository.dart';
import 'customer_repository.dart';

class ReservationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MenuItemRepository _menuItemRepository = MenuItemRepository();
  final CustomerRepository _customerRepository = CustomerRepository();

  // 1. Đặt Bàn - CHUẨN ĐỀ
  Future<void> createReservation({
    required String customerId,
    required Timestamp reservationDate,
    required int numberOfGuests,
    String? specialRequests,
    List<Map<String, dynamic>>? orderItems,
  }) async {
    try {
      // Tính toán tổng tiền
      final items = orderItems ?? [];
      final subtotal =
          items.fold<double>(0.0, (sum, item) => sum + (item['total'] ?? 0.0));
      final serviceCharge = subtotal * 0.1; // 10% service charge
      final discount = 0.0; // Có thể thêm logic giảm giá sau
      final total = subtotal + serviceCharge - discount;

      // Tạo reservation mới
      final reservationId = _firestore.collection('reservations').doc().id;

      final reservation = ReservationModel(
        reservationId: reservationId,
        customerId: customerId,
        reservationDate: reservationDate,
        numberOfGuests: numberOfGuests,
        status: 'pending',
        specialRequests: specialRequests,
        orderItems: items,
        subtotal: subtotal,
        serviceCharge: serviceCharge,
        discount: discount,
        total: total,
        paymentStatus: 'pending',
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await _firestore
          .collection('reservations')
          .doc(reservationId)
          .set(reservation.toJson());
    } catch (e) {
      throw Exception('Lỗi đặt bàn: $e');
    }
  }

  // 2. Thêm Món vào Đơn - CHUẨN ĐỀ
  Future<void> addItemToReservation({
    required String reservationId,
    required String itemId,
    required int quantity,
  }) async {
    try {
      // Lấy thông tin reservation
      final reservationDoc =
          await _firestore.collection('reservations').doc(reservationId).get();

      if (!reservationDoc.exists) {
        throw Exception('Đặt bàn không tồn tại');
      }

      final reservation = ReservationModel.fromJson(reservationDoc.data()!);

      // Kiểm tra trạng thái
      if (reservation.status != 'pending' &&
          reservation.status != 'confirmed') {
        throw Exception('Không thể thêm món vào đơn đặt bàn này');
      }

      // Lấy thông tin món ăn
      final menuItem = await _menuItemRepository.getMenuItemById(itemId);
      if (menuItem == null) {
        throw Exception('Món ăn không tồn tại');
      }

      if (!menuItem.isAvailable) {
        throw Exception('Món ăn tạm hết');
      }

      // Kiểm tra món đã có trong đơn chưa
      final existingItemIndex = reservation.orderItems.indexWhere(
        (item) => item['itemId'] == itemId,
      );

      List<Map<String, dynamic>> newOrderItems = [...reservation.orderItems];

      if (existingItemIndex != -1) {
        // Cập nhật số lượng nếu đã có
        final newQuantity =
            (newOrderItems[existingItemIndex]['quantity'] ?? 0) + quantity;
        newOrderItems[existingItemIndex]['quantity'] = newQuantity;
        newOrderItems[existingItemIndex]['subtotal'] =
            menuItem.price * newQuantity;
      } else {
        // Thêm món mới
        newOrderItems.add({
          'itemId': itemId,
          'itemName': menuItem.name,
          'quantity': quantity,
          'price': menuItem.price,
          'subtotal': menuItem.price * quantity,
        });
      }

      // Tính toán lại các giá trị
      final newSubtotal = _calculateSubtotal(newOrderItems);
      final newServiceCharge = newSubtotal * 0.1; // 10% service charge
      final newTotal = newSubtotal + newServiceCharge - reservation.discount;

      // Cập nhật reservation
      await _firestore.collection('reservations').doc(reservationId).update({
        'orderItems': newOrderItems,
        'subtotal': newSubtotal,
        'serviceCharge': newServiceCharge,
        'total': newTotal,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Lỗi thêm món vào đơn: $e');
    }
  }

  // 3. Xác nhận Đặt Bàn - CHUẨN ĐỀ
  Future<void> confirmReservation({
    required String reservationId,
    required String tableNumber,
  }) async {
    try {
      await _firestore.collection('reservations').doc(reservationId).update({
        'status': 'confirmed',
        'tableNumber': tableNumber,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Lỗi xác nhận đặt bàn: $e');
    }
  }

  // 4. Thanh toán - CHUẨN ĐỀ (Tính toán phức tạp)
  Future<void> payReservation({
    required String reservationId,
    required String paymentMethod,
  }) async {
    try {
      // Lấy thông tin reservation
      final reservationDoc =
          await _firestore.collection('reservations').doc(reservationId).get();

      if (!reservationDoc.exists) {
        throw Exception('Đặt bàn không tồn tại');
      }

      final reservation = ReservationModel.fromJson(reservationDoc.data()!);

      // Kiểm tra trạng thái
      if (reservation.status != 'seated') {
        throw Exception('Chỉ có thể thanh toán khi khách đã ngồi vào bàn');
      }

      // Lấy thông tin customer để tính loyalty points
      final customer =
          await _customerRepository.getCustomerById(reservation.customerId);
      if (customer == null) {
        throw Exception('Khách hàng không tồn tại');
      }

      // Tính discount từ loyaltyPoints (1 point = 1000đ, tối đa 50% total)
      final maxDiscount = reservation.total * 0.5;
      final discountFromPoints = (customer.loyaltyPoints * 1000).toDouble();
      final finalDiscount =
          discountFromPoints > maxDiscount ? maxDiscount : discountFromPoints;

      // Tính total sau discount
      final totalAfterDiscount = reservation.total - finalDiscount;

      // Cập nhật reservation
      await _firestore.collection('reservations').doc(reservationId).update({
        'status': 'completed',
        'paymentMethod': paymentMethod,
        'paymentStatus': 'paid',
        'discount': finalDiscount,
        'total': totalAfterDiscount,
        'updatedAt': Timestamp.now(),
      });

      // Tính loyalty points mới (1% total) và trừ points đã dùng
      final earnedPoints = (totalAfterDiscount * 0.01).toInt(); // 1% total
      final usedPoints =
          (finalDiscount / 1000).toInt(); // points đã dùng cho discount
      final netPoints = earnedPoints - usedPoints;

      if (netPoints != 0) {
        await _customerRepository.updateLoyaltyPoints(
          reservation.customerId,
          netPoints,
        );
      }
    } catch (e) {
      throw Exception('Lỗi thanh toán: $e');
    }
  }

  // 5. Lấy Đặt Bàn theo Customer - CHUẨN ĐỀ
  Future<List<ReservationModel>> getReservationsByCustomer(
      String customerId) async {
    try {
      final query = await _firestore
          .collection('reservations')
          .where('customerId', isEqualTo: customerId)
          .get();

      final reservations = query.docs
          .map((doc) => ReservationModel.fromJson(doc.data()))
          .toList();

      // Sort by reservation date descending in Dart
      reservations
          .sort((a, b) => b.reservationDate.compareTo(a.reservationDate));

      return reservations;
    } catch (e) {
      throw Exception('Lỗi lấy đặt bàn theo khách hàng: $e');
    }
  }

  // 6. Lấy Đặt Bàn theo Ngày - CHUẨN ĐỀ
  Future<List<ReservationModel>> getReservationsByDate(DateTime date) async {
    try {
      final startOfDay = Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, 0, 0, 0),
      );
      final endOfDay = Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, 23, 59, 59),
      );

      final query = await _firestore
          .collection('reservations')
          .where('reservationDate', isGreaterThanOrEqualTo: startOfDay)
          .where('reservationDate', isLessThanOrEqualTo: endOfDay)
          .orderBy('reservationDate')
          .get();

      return query.docs
          .map((doc) => ReservationModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy đặt bàn theo ngày: $e');
    }
  }

  // 7. Lấy Reservation theo ID
  Future<ReservationModel?> getReservationById(String reservationId) async {
    try {
      final doc =
          await _firestore.collection('reservations').doc(reservationId).get();

      if (doc.exists) {
        return ReservationModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi lấy đặt bàn: $e');
    }
  }

  // 8. Hủy Reservation
  Future<void> cancelReservation(String reservationId) async {
    try {
      await _firestore.collection('reservations').doc(reservationId).update({
        'status': 'cancelled',
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Lỗi hủy đặt bàn: $e');
    }
  }

  // 9. Stream Reservations theo Customer (real-time)
  Stream<List<ReservationModel>> getReservationsByCustomerStream(
      String customerId) {
    return _firestore
        .collection('reservations')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      final reservations = snapshot.docs
          .map((doc) => ReservationModel.fromJson(doc.data()))
          .toList();
      // Sort by reservation date descending
      reservations
          .sort((a, b) => b.reservationDate.compareTo(a.reservationDate));
      return reservations;
    });
  }

  // Helper method: Tính subtotal từ orderItems
  double _calculateSubtotal(List<Map<String, dynamic>> orderItems) {
    return orderItems.fold(0.0, (sum, item) {
      return sum + (item['subtotal'] ?? 0.0);
    });
  }
}
