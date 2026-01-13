import 'package:flutter/material.dart';
import '../../repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);
    try {
      await AuthRepository().signUp(
        _emailController.text, _passwordController.text, _nameController.text);
      if (mounted) Navigator.pop(context); // Quay lại trang login
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng Ký")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Họ Tên")),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Mật khẩu"), obscureText: true),
            const SizedBox(height: 20),
            _isLoading ? const CircularProgressIndicator() : 
            ElevatedButton(onPressed: _register, child: const Text("TẠO TÀI KHOẢN")),
          ],
        ),
      ),
    );
  }
}