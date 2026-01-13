import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';
import '../models/customer.dart';

class DataSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedData() async {
    // 1. Tạo 5 Customers
    for (int i = 1; i <= 5; i++) {
      String id = "customer_0$i";
      Customer c = Customer(
        customerId: id,
        email: "khach$i@gmail.com",
        fullName: "Khách Hàng $i",
        phoneNumber: "090123456$i",
        address: "Hà Nội",
        preferences: ["vegetarian"],
        createdAt: DateTime.now(),
      );
      await _db.collection('customers').doc(id).set(c.toMap());
    }

    // 2. Tạo 20 Menu Items
    for (int i = 1; i <= 20; i++) {
      MenuItem item = MenuItem(
        itemId: "", 
        name: "Món ngon số $i",
        description: "Mô tả món ăn hấp dẫn số $i",
        category: "Main Course",
        price: (i * 15000).toDouble(),
        imageUrl: "https://placehold.co/600x400",
        ingredients: ["Thịt", "Rau"],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 15,
        createdAt: DateTime.now(),
        rating: 4.5,
      );
      await _db.collection('menu_items').add(item.toMap());
    }
    
    // 3. Tạo 1 Reservation mẫu
    await _db.collection('reservations').add({
        'customerId': 'customer_01',
        'reservationDate': Timestamp.now(),
        'numberOfGuests': 2,
        'status': 'pending',
        'subtotal': 100000,
        'serviceCharge': 10000,
        'total': 110000,
        'createdAt': Timestamp.now(),
    });
  }
}