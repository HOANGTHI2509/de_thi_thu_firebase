import 'package:flutter/material.dart';
import '../../repositories/auth_repository.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      await AuthRepository().signIn(_emailController.text, _passwordController.text);
      // Khi đăng nhập thành công, main.dart sẽ tự chuyển hướng
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 80, color: Colors.orange),
            const Text("Restaurant Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Mật khẩu", border: OutlineInputBorder()), obscureText: true),
            const SizedBox(height: 25),
            _isLoading ? const CircularProgressIndicator() : 
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _login, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text("ĐĂNG NHẬP", style: TextStyle(color: Colors.white)))),
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())), child: const Text("Chưa có tài khoản? Đăng ký ngay")),
          ],
        ),
      ),
    );
  }
}