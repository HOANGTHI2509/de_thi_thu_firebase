import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/reservation_repository.dart';

class ReservationListScreen extends StatelessWidget {
  const ReservationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch Sử Đặt Bàn"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: ReservationRepository().getAllReservations(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservations = snapshot.data ?? [];
          if (reservations.isEmpty) {
            return const Center(child: Text("Chưa có lịch sử đặt bàn."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final res = reservations[index];
              final date = (res['reservationDate'] as Timestamp).toDate();
              
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.event_seat, color: Colors.orange, size: 40),
                  title: Text("Bàn cho ${res['numberOfGuests']} người", 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ngày: ${date.day}/${date.month}/${date.year}"),
                      if (res['specialRequest'] != null && res['specialRequest'].isNotEmpty)
                        Text("Ghi chú: ${res['specialRequest']}", 
                          style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: res['status'] == 'pending' ? Colors.blue.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      res['status'] == 'pending' ? "Chờ duyệt" : "Đã xong",
                      style: TextStyle(
                        fontSize: 10, 
                        color: res['status'] == 'pending' ? Colors.blue : Colors.green,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}