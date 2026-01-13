import 'package:flutter/material.dart';
import '../models/menu_item.dart';

class ItemDetailScreen extends StatelessWidget {
  final MenuItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      // XÓA 'const' Ở DÒNG DƯỚI ĐÂY ĐỂ HẾT LỖI
      body: SingleChildScrollView( 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị ảnh món ăn
            Image.network(
              item.imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                const SizedBox(height: 300, child: Icon(Icons.fastfood, size: 100)),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${item.price.toInt()} VNĐ",
                    style: const TextStyle(fontSize: 22, color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Mô tả món ăn:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Nguyên liệu chính:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Hiển thị danh sách nguyên liệu dạng Chip
                  Wrap(
                    spacing: 8,
                    children: item.ingredients.map((ingredient) => Chip(
                      label: Text(ingredient),
                      backgroundColor: Colors.orange.shade50,
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}