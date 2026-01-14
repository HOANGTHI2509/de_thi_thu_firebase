// lib/repositories/menu_item_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

class MenuItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Thêm MenuItem
  Future<void> addMenuItem(MenuItemModel menuItem) async {
    try {
      await _firestore
          .collection('menu_items')
          .doc(menuItem.itemId)
          .set(menuItem.toJson());
    } catch (e) {
      throw Exception('Lỗi thêm món ăn: $e');
    }
  }

  // 2. Lấy MenuItem theo ID
  Future<MenuItemModel?> getMenuItemById(String itemId) async {
    try {
      final doc = await _firestore.collection('menu_items').doc(itemId).get();
      if (doc.exists) {
        return MenuItemModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi lấy món ăn: $e');
    }
  }

  // 3. Lấy tất cả MenuItems
  Future<List<MenuItemModel>> getAllMenuItems() async {
    try {
      final snapshot = await _firestore.collection('menu_items').get();
      return snapshot.docs
          .map((doc) => MenuItemModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách món ăn: $e');
    }
  }

  // 4. Tìm kiếm MenuItems - CHUẨN ĐỀ: Tìm trong name, description, ingredients
  Future<List<MenuItemModel>> searchMenuItems(String query) async {
    try {
      final snapshot = await _firestore.collection('menu_items').get();

      return snapshot.docs
          .map((doc) => MenuItemModel.fromJson(doc.data()))
          .where((item) {
        // Tìm trong name (không phân biệt hoa thường)
        final nameMatch = item.name.toLowerCase().contains(query.toLowerCase());

        // Tìm trong description
        final descMatch =
            item.description.toLowerCase().contains(query.toLowerCase());

        // Tìm trong ingredients
        final ingredientsMatch = item.ingredients.any((ingredient) =>
            ingredient.toLowerCase().contains(query.toLowerCase()));

        return nameMatch || descMatch || ingredientsMatch;
      }).toList();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm món ăn: $e');
    }
  }

  // 5. Lọc MenuItems - CHUẨN ĐỀ: Theo category, isVegetarian, isSpicy
  Future<List<MenuItemModel>> filterMenuItems({
    String? category,
    bool? isVegetarian,
    bool? isSpicy,
  }) async {
    try {
      Query query = _firestore.collection('menu_items');

      // Áp dụng các bộ lọc
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (isVegetarian != null) {
        query = query.where('isVegetarian', isEqualTo: isVegetarian);
      }

      if (isSpicy != null) {
        query = query.where('isSpicy', isEqualTo: isSpicy);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              MenuItemModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lọc món ăn: $e');
    }
  }

  // 6. Lấy MenuItems theo category
  Future<List<MenuItemModel>> getMenuItemsByCategory(String category) async {
    try {
      final query = await _firestore
          .collection('menu_items')
          .where('category', isEqualTo: category)
          .where('isAvailable', isEqualTo: true)
          .get();

      return query.docs
          .map((doc) => MenuItemModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy món ăn theo danh mục: $e');
    }
  }

  // 7. Stream tất cả MenuItems (real-time)
  Stream<List<MenuItemModel>> getAllMenuItemsStream() {
    return _firestore
        .collection('menu_items')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItemModel.fromJson(doc.data()))
            .toList());
  }

  // 8. Lấy các categories duy nhất
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('menu_items').get();
      final categories = <String>{};

      for (final doc in snapshot.docs) {
        final category = doc.data()['category'];
        if (category != null) {
          categories.add(category.toString());
        }
      }

      return categories.toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh mục: $e');
    }
  }
}
