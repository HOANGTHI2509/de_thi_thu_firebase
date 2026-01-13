import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

class ReservationRepository {
  final CollectionReference _reservationRef = DatabaseService().reservationRef;

  // Hàm tạo đơn đặt bàn mới (Phần 4.4)
  Future<void> createReservation(String customerId, DateTime date, int numberOfGuests, String specialRequest) async {
    final docRef = _reservationRef.doc();
    await docRef.set({
      'reservationId': docRef.id,
      'customerId': customerId,
      'reservationDate': Timestamp.fromDate(date),
      'numberOfGuests': numberOfGuests,
      'specialRequest': specialRequest,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ĐÂY LÀ HÀM MỚI CHO PHẦN 4.5
  Stream<List<Map<String, dynamic>>> getAllReservations() {
    return _reservationRef
        .orderBy('createdAt', descending: true) // Hiện đơn mới nhất lên đầu
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }
}