import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String itemId;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final List<String> ingredients;
  final bool isVegetarian;
  final bool isSpicy;
  final int preparationTime;
  final bool isAvailable;
  final double rating;
  final DateTime createdAt;

  MenuItem({
    required this.itemId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.ingredients,
    required this.isVegetarian,
    required this.isSpicy,
    required this.preparationTime,
    this.isAvailable = true,
    this.rating = 0.0,
    required this.createdAt,
  });

  // Chuyển từ Object sang Map để đẩy lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'isVegetarian': isVegetarian,
      'isSpicy': isSpicy,
      'preparationTime': preparationTime,
      'isAvailable': isAvailable,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // 👇 ĐÂY LÀ HÀM QUAN TRỌNG NHẤT ĐỂ SỬA LỖI BƯỚC 2
  factory MenuItem.fromMap(Map<String, dynamic> map, String id) {
    return MenuItem(
      itemId: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      // Ép kiểu double an toàn để tránh lỗi kiểu dữ liệu
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      // Chuyển đổi danh sách nguyên liệu từ Dynamic sang String
      ingredients: List<String>.from(map['ingredients'] ?? []),
      isVegetarian: map['isVegetarian'] ?? false,
      isSpicy: map['isSpicy'] ?? false,
      preparationTime: map['preparationTime'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      rating: (map['rating'] ?? 0).toDouble(),
      // Chuyển đổi Timestamp của Firebase sang DateTime của Dart
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
}