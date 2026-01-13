import 'package:flutter/material.dart';
import '../repositories/menu_repository.dart';
import '../models/menu_item.dart';
import 'item_detail_screen.dart';
import 'reservation_screen.dart';
import 'reservation_list_screen.dart'; // Import màn hình danh sách đặt bàn

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Nhà Hàng - 1771020643"), // Mã SV của bạn
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          // 1. Nút xem Lịch sử đặt bàn (Phần 4.5 - 7 điểm)
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Lịch sử đặt bàn",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReservationListScreen()),
              );
            },
          ),
          // 2. Nút Đặt bàn mới (Phần 4.4 - 15 điểm)
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: "Đặt bàn mới",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReservationScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<MenuItem>>(
        // Lấy dữ liệu Real-time từ Firestore
        stream: MenuRepository().getAllMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          final menuItems = snapshot.data ?? [];
          if (menuItems.isEmpty) {
            return const Center(child: Text("Thực đơn hiện đang trống."));
          }

          // Hiển thị GridView 2 cột (Phần 4.2 - 8 điểm)
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,           // Hiển thị 2 cột
              childAspectRatio: 0.72,      // Tỉ lệ cân đối cho ảnh và chữ
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return InkWell(
                // Sự kiện nhấn để xem chi tiết (Phần 4.3 - 10 điểm)
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailScreen(item: item),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh món ăn lấy từ URL trong Firestore
                      Expanded(
                        child: Image.network(
                          item.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, e, s) => 
                            const Center(child: Icon(Icons.fastfood, size: 50, color: Colors.grey)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item.price.toInt()} VNĐ",
                              style: const TextStyle(
                                color: Colors.deepOrange, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Hiển thị trạng thái món ăn
                            Row(
                              children: [
                                Icon(
                                  item.isAvailable ? Icons.check_circle : Icons.cancel,
                                  size: 14,
                                  color: item.isAvailable ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.isAvailable ? "Còn món" : "Hết món",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: item.isAvailable ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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