# Restaurant App - 1771020643

Một ứng dụng quản lý nhà hàng được xây dựng bằng Flutter, sử dụng Firebase cho authentication và database.

## 📋 Mô tả dự án

Ứng dụng này cho phép khách hàng:
- Đăng ký và đăng nhập tài khoản
- Xem thực đơn nhà hàng
- Đặt bàn và chọn món ăn
- Xem lịch sử đặt bàn
- Quản lý thông tin tài khoản và điểm tích lũy

## ✨ Tính năng chính

### 🔐 Authentication
- Đăng ký tài khoản mới
- Đăng nhập/Đăng xuất
- Quản lý trạng thái đăng nhập

### 🍽️ Quản lý thực đơn
- Xem danh sách món ăn
- Chi tiết món ăn với hình ảnh và mô tả
- Phân loại món ăn theo danh mục

### 📅 Đặt bàn
- Tạo đặt bàn mới
- Chọn ngày giờ
- Chọn món ăn với số lượng (+/-)
- Xem danh sách đặt bàn của tôi
- Chi tiết đặt bàn

### 👤 Tài khoản
- Xem thông tin cá nhân
- Quản lý điểm tích lũy
- Cập nhật thông tin

## 🛠️ Công nghệ sử dụng

- **Flutter**: Framework phát triển ứng dụng đa nền tảng
- **Firebase Authentication**: Xác thực người dùng
- **Cloud Firestore**: Cơ sở dữ liệu NoSQL
- **Shared Preferences**: Lưu trữ local
- **Provider**: Quản lý trạng thái

## 📋 Yêu cầu hệ thống

- Flutter SDK: 3.2.3+
- Dart SDK: 2.19.0+
- Android Studio / VS Code
- Firebase project đã được cấu hình

## 🚀 Cài đặt và chạy

### 1. Clone repository
```bash
git clone <repository-url>
cd flutter_app_1771020643
```

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Cấu hình Firebase
- Tạo Firebase project tại [Firebase Console](https://console.firebase.google.com/)
- Thêm ứng dụng Android/iOS vào project
- Download file cấu hình và đặt vào thư mục tương ứng:
  - Android: `android/app/google-services.json`
  - iOS: `ios/Runner/GoogleService-Info.plist`
- Bật Authentication và Firestore trong Firebase Console

### 4. Chạy ứng dụng
```bash
flutter run
```

## 📁 Cấu trúc dự án

```
lib/
├── main.dart                    # Entry point của ứng dụng
├── models/                      # Data models
│   ├── customer_model.dart      # Model khách hàng
│   ├── menu_item_model.dart     # Model món ăn
│   ├── reservation_model.dart   # Model đặt bàn
│   └── order_item_model.dart    # Model item đặt hàng
├── repositories/                # Data access layer
│   ├── customer_repository.dart
│   ├── menu_item_repository.dart
│   └── reservation_repository.dart
├── services/                    # Business logic
│   └── auth_service.dart        # Firebase Auth service
├── screens/                     # UI screens
│   ├── auth/                    # Authentication screens
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── menu/                    # Menu screens
│   ├── reservation/             # Reservation screens
│   ├── home_screen.dart         # Main screen
│   └── account_screen.dart      # Account screen
├── utils/                       # Utilities
│   ├── constants.dart           # App constants
│   ├── seed_data.dart           # Sample data
│   └── validators.dart          # Input validation
└── widgets/                     # Reusable widgets
    ├── menu_item_card.dart
    ├── preference_chips_widget.dart
    └── reservation_card.dart
```

## 🔧 Scripts hữu ích

```bash
# Kiểm tra code
flutter analyze

# Chạy tests
flutter test

# Build APK
flutter build apk

# Clean project
flutter clean
flutter pub get
```

## 📊 Database Schema

### Customers Collection
```json
{
  "customerId": "string",
  "email": "string",
  "fullName": "string",
  "phoneNumber": "string",
  "address": "string",
  "preferences": ["string"],
  "loyaltyPoints": number,
  "createdAt": timestamp,
  "isActive": boolean
}
```

### Menu Items Collection
```json
{
  "itemId": "string",
  "name": "string",
  "description": "string",
  "price": number,
  "category": "string",
  "imageUrl": "string",
  "isAvailable": boolean
}
```

### Reservations Collection
```json
{
  "reservationId": "string",
  "customerId": "string",
  "reservationDate": timestamp,
  "numberOfGuests": number,
  "status": "string",
  "totalAmount": number,
  "orderItems": [
    {
      "itemId": "string",
      "name": "string",
      "quantity": number,
      "price": number
    }
  ]
}
```

## 🤝 Đóng góp

1. Fork project
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📝 License

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.

## 👨‍💻 Tác giả

- **Tên**: Hoàng Văn Thi
- **Mã sinh viên**: 1771020643

---

*Được phát triển như một phần của dự án Flutter cho môn học Phát triển Ứng dụng Di động*
