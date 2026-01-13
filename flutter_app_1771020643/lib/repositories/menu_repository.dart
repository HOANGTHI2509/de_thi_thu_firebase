import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';
import '../services/database_service.dart';

class MenuRepository {
  // Lấy tham chiếu collection từ DatabaseService
  final CollectionReference _menuCollection = DatabaseService().menuRef;

  // 1. Lấy toàn bộ danh sách món ăn (Sửa lỗi undefined_method)
  Stream<List<MenuItem>> getAllMenuItems() {
    return _menuCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MenuItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 2. Thêm món ăn mới (Dành cho phần quản trị nếu cần)
  Future<void> addMenuItem(MenuItem item) async {
    await _menuCollection.doc(item.itemId).set(item.toMap());
  }

  // 3. Cập nhật trạng thái còn món/hết món
  Future<void> updateAvailability(String itemId, bool isAvailable) async {
    await _menuCollection.doc(itemId).update({'isAvailable': isAvailable});
  }
}