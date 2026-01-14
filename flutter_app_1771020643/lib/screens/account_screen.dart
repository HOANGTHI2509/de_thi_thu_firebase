// lib/screens/account_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/customer_model.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  CustomerModel? _currentCustomer;

  @override
  void initState() {
    super.initState();
    _loadCurrentCustomer();
  }

  Future<void> _loadCurrentCustomer() async {
    final authService = AuthService();
    final customer = await authService.getCurrentCustomer();
    setState(() {
      _currentCustomer = customer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: _currentCustomer == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.orange, Colors.white],
                  stops: [0.0, 0.3],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Avatar section
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentCustomer!.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Info card
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Text(
                                'Thông tin tài khoản',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ListTile(
                                leading: const Icon(Icons.email,
                                    color: Colors.orange),
                                title: const Text('Email'),
                                subtitle: Text(_currentCustomer!.email),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.phone,
                                    color: Colors.orange),
                                title: const Text('Số điện thoại'),
                                subtitle: Text(_currentCustomer!.phoneNumber),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.location_on,
                                    color: Colors.orange),
                                title: const Text('Địa chỉ'),
                                subtitle: Text(_currentCustomer!.address),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.loyalty,
                                    color: Colors.orange),
                                title: const Text('Điểm tích lũy'),
                                subtitle: Text(
                                    '${_currentCustomer!.loyaltyPoints} điểm'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final authService = AuthService();
                            await authService.signOut();
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Đăng xuất'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
