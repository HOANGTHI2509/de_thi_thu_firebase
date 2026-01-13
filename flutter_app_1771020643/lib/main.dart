import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/menu_screen.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  // Đảm bảo Flutter framework đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase với thông số cấu hình của bạn
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBlTHyP_aaH0r8X3daGpCcOhqVCRkceRtE",
      appId: "1:1010463851616:web:297aeb362a0acb8b64af05",
      messagingSenderId: "1010463851616",
      projectId: "hoang-thi-9f055",
      storageBucket: "hoang-thi-9f055.firebasestorage.app",
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant App - 1771020643', // Mã SV của bạn
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      // SỬ DỤNG STREAMBUILDER ĐỂ KIỂM TRA TRẠNG THÁI ĐĂNG NHẬP
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Nếu đang kiểm tra (ví dụ mạng chậm)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // 2. Nếu đã đăng nhập thành công (có dữ liệu User)
          if (snapshot.hasData) {
            return const MenuScreen();
          }
          
          // 3. Nếu chưa đăng nhập hoặc đã đăng xuất
          return const LoginScreen();
        },
      ),
    );
  }
}