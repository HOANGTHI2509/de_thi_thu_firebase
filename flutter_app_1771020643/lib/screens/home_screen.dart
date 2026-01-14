// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../repositories/customer_repository.dart';
import '../models/customer_model.dart';
import './menu/menu_screen.dart';
import './reservation/my_reservations_screen.dart';
import './reservation/create_reservation_screen.dart';
import './account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
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

  Future<void> _logout() async {
    final authService = AuthService();
    await authService.signOut();

    Navigator.pushReplacementNamed(context, '/login');
  }

  static const List<Widget> _widgetOptions = <Widget>[
    MenuScreen(),
    MyReservationsScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant App - 1771020643'), // Mã SV trên AppBar
        centerTitle: true,
        actions: [
          if (_currentCustomer != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.loyalty, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${_currentCustomer!.loyaltyPoints}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton:
          _selectedIndex == 1 // Chỉ hiển thị ở màn hình đặt bàn
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateReservationScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Thực đơn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Đặt bàn của tôi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
    );
  }
}
