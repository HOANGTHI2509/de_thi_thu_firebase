// lib/utils/seed_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/customer_model.dart';
import '../models/menu_item_model.dart';
import '../repositories/customer_repository.dart';
import '../repositories/menu_item_repository.dart';

class SeedData {
  final Uuid _uuid = const Uuid();

  Future<void> seedAllData() async {
    print('🌱 Bắt đầu tạo dữ liệu mẫu...');

    try {
      await seedCustomers();
      await seedMenuItems();

      print('✅ Đã tạo dữ liệu mẫu thành công');
    } catch (e) {
      print('❌ Lỗi tạo dữ liệu mẫu: $e');
    }
  }

  Future<void> seedCustomers() async {
    final customers = [
      CustomerModel(
        customerId: _uuid.v4(),
        email: 'customer1@gmail.com',
        fullName: 'Nguyễn Văn A',
        phoneNumber: '0912345678',
        address: '123 Đường ABC, Quận 1, TP.HCM',
        preferences: ['vegetarian'],
        loyaltyPoints: 500,
        createdAt: Timestamp.now(),
        isActive: true,
      ),
      CustomerModel(
        customerId: _uuid.v4(),
        email: 'customer2@gmail.com',
        fullName: 'Trần Thị B',
        phoneNumber: '0923456789',
        address: '456 Đường XYZ, Quận 3, TP.HCM',
        preferences: ['spicy', 'seafood'],
        loyaltyPoints: 1200,
        createdAt: Timestamp.now(),
        isActive: true,
      ),
      CustomerModel(
        customerId: _uuid.v4(),
        email: 'customer3@gmail.com',
        fullName: 'Lê Văn C',
        phoneNumber: '0934567890',
        address: '789 Đường DEF, Quận 5, TP.HCM',
        preferences: [],
        loyaltyPoints: 250,
        createdAt: Timestamp.now(),
        isActive: true,
      ),
      CustomerModel(
        customerId: _uuid.v4(),
        email: 'customer4@gmail.com',
        fullName: 'Phạm Thị D',
        phoneNumber: '0945678901',
        address: '321 Đường GHI, Quận 7, TP.HCM',
        preferences: ['vegetarian', 'seafood'],
        loyaltyPoints: 800,
        createdAt: Timestamp.now(),
        isActive: true,
      ),
      CustomerModel(
        customerId: _uuid.v4(),
        email: 'customer5@gmail.com',
        fullName: 'Hoàng Văn E',
        phoneNumber: '0956789012',
        address: '654 Đường JKL, Quận 10, TP.HCM',
        preferences: ['spicy'],
        loyaltyPoints: 1500,
        createdAt: Timestamp.now(),
        isActive: true,
      ),
    ];

    for (final customer in customers) {
      await CustomerRepository().addCustomer(customer);
    }
  }

  Future<void> seedMenuItems() async {
    final menuItems = [
      // Appetizers
      MenuItemModel(
        itemId: _uuid.v4(),
        name: 'Gỏi Cuốn Tôm Thịt',
        description: 'Gỏi cuốn truyền thống với tôm, thịt và rau sống',
        category: 'Appetizer',
        price: 35000,
        imageUrl:
            'https://images.unsplash.com/photo-1586190848861-99aa4a171e90',
        ingredients: ['Tôm', 'Thịt heo', 'Bánh tráng', 'Rau sống', 'Bún'],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 10,
        isAvailable: true,
        rating: 4.5,
        createdAt: Timestamp.now(),
      ),
      MenuItemModel(
        itemId: _uuid.v4(),
        name: 'Chả Giò',
        description: 'Chả giò giòn rụm với nhân thịt heo và rau củ',
        category: 'Appetizer',
        price: 40000,
        imageUrl:
            'https://images.unsplash.com/photo-1563379091339-03246963d9d6',
        ingredients: [
          'Thịt heo',
          'Cà rốt',
          'Mộc nhĩ',
          'Bánh tráng',
          'Rau sống'
        ],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 15,
        isAvailable: true,
        rating: 4.7,
        createdAt: Timestamp.now(),
      ),
      // Main Courses
      MenuItemModel(
        itemId: _uuid.v4(),
        name: 'Phở Bò',
        description: 'Phở bò truyền thống Hà Nội',
        category: 'Main Course',
        price: 55000,
        imageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d',
        ingredients: ['Bò', 'Bánh phở', 'Hành', 'Rau thơm', 'Nước dùng'],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 20,
        isAvailable: true,
        rating: 4.8,
        createdAt: Timestamp.now(),
      ),
      MenuItemModel(
        itemId: _uuid.v4(),
        name: 'Cơm Tấm Sườn Bì Chả',
        description: 'Cơm tấm đặc biệt Sài Gòn',
        category: 'Main Course',
        price: 65000,
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        ingredients: ['Sườn', 'Bì', 'Chả trứng', 'Cơm tấm', 'Đồ chua'],
        isVegetarian: false,
        isSpicy: true,
        preparationTime: 25,
        isAvailable: true,
        rating: 4.6,
        createdAt: Timestamp.now(),
      ),
      MenuItemModel(
        itemId: _uuid.v4(),
        name: 'Bún Chả Hà Nội',
        description: 'Bún chả đặc sản Hà Nội',
        category: 'Main Course',
        price: 50000,
        imageUrl: 'https://images.unsplash.com/photo-1556911220-bff31c812dba',
        ingredients: ['Thịt nướng', 'Bún', 'Rau sống', 'Nước mắm pha'],
        isVegetarian: false,
        isSpicy: true,
        preparationTime: 20,
        isAvailable: true,
        rating: 4.9,
        createdAt: Timestamp.now(),
      ),
      MenuItemModel(
        itemId: _uuid.v4(),
        name: 'Cơm Chay',
        description: 'Cơm chay đầy đủ dinh dưỡng',
        category: 'Main Course',
        price: 45000,
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
        ingredients: ['Đậu hũ', 'Nấm', 'Rau củ', 'Cơm trắng'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 15,
        isAvailable: true,
        rating: 4.4,
        createdAt: Timestamp.now(),
      ),
      // Desserts
      MenuItemModel(
        itemId: _uuid.v4(),
        name: 'Bánh Flan',
        description: 'Bánh flan caramel thơm ngon',
        category: 'Dessert',
        price: 25000,
        imageUrl:
            'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e',
        ingredients: ['Trứng', 'Sữa', 'Caramel', 'Vanilla'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 5,
        isAvailable: true,
        rating: 4.3,
        createdAt: Timestamp.now(),
      ),
      MenuItemModel(
        itemId: _uuid.v4(),
        name: 'Chè Khúc Bạch',
        description: 'Chè khúc bạch mát lạnh',
        category: 'Dessert',
        price: 30000,
        imageUrl:
            'https://images.unsplash.com/photo-1565958011703-44f9829ba187',
        ingredients: ['Sữa', 'Trân châu', 'Thạch', 'Đường'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 8,
        isAvailable: true,
        rating: 4.5,
        createdAt: Timestamp.now(),
      ),
      // Beverages
      MenuItemModel(
        itemId: _uuid.v4(),
        name: 'Coca Cola',
        description: 'Nước ngọt có ga',
        category: 'Beverage',
        price: 20000,
        imageUrl:
            'https://images.unsplash.com/photo-1622483767028-3f66f32aef97',
        ingredients: ['Nước ngọt', 'Đường', 'Gas'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 2,
        isAvailable: true,
        rating: 4.0,
        createdAt: Timestamp.now(),
      ),
      MenuItemModel(
        itemId: _uuid.v4(),
        name: 'Trà Đào',
        description: 'Trà đào mát lạnh',
        category: 'Beverage',
        price: 35000,
        imageUrl: 'https://images.unsplash.com/photo-1561047029-3000c68339ca',
        ingredients: ['Trà', 'Đào', 'Đá', 'Đường'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 5,
        isAvailable: true,
        rating: 4.7,
        createdAt: Timestamp.now(),
      ),
      // Soups
      MenuItemModel(
        itemId: _uuid.v4(),
        name: 'Súp Cua',
        description: 'Súp cua thơm ngon',
        category: 'Soup',
        price: 40000,
        imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd',
        ingredients: ['Thịt cua', 'Trứng', 'Nấm', 'Bột năng'],
        isVegetarian: false,
        isSpicy: false,
        preparationTime: 15,
        isAvailable: true,
        rating: 4.6,
        createdAt: Timestamp.now(),
      ),
      MenuItemModel(
        itemId: _uuid.v4(),
        name: 'Súp Bí Đỏ',
        description: 'Súp bí đỏ bổ dưỡng',
        category: 'Soup',
        price: 35000,
        imageUrl:
            'https://images.unsplash.com/photo-1476124369491-e7addf5db371',
        ingredients: ['Bí đỏ', 'Sữa', 'Hành tây', 'Gia vị'],
        isVegetarian: true,
        isSpicy: false,
        preparationTime: 12,
        isAvailable: true,
        rating: 4.4,
        createdAt: Timestamp.now(),
      ),
    ];

    for (final item in menuItems) {
      await MenuItemRepository().addMenuItem(item);
    }
  }
}
