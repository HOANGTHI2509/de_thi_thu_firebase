// lib/screens/reservation/my_reservations_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../repositories/reservation_repository.dart';
import '../../models/reservation_model.dart';
import '../../widgets/reservation_card.dart';
import './reservation_detail_screen.dart';
import './create_reservation_screen.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final ReservationRepository _repository = ReservationRepository();
  List<ReservationModel> _reservations = [];
  bool _isLoading = true;
  String? _customerId;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _customerId = prefs.getString('customerId');

      if (_customerId != null) {
        final reservations =
            await _repository.getReservationsByCustomer(_customerId!);
        setState(() {
          _reservations = reservations;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading reservations: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải đặt bàn: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _refresh() {
    _loadReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _customerId == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Vui lòng đăng nhập để xem đặt bàn',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : _reservations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có đặt bàn nào',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateReservationScreen(),
                                ),
                              ).then((_) => _refresh());
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Đặt bàn ngay'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.orange[50],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tổng số đặt bàn',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${_reservations.length}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Đang chờ xác nhận',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _reservations
                                        .where((r) => r.status == 'pending')
                                        .length
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Status filter
                        SizedBox(
                          height: 60,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            children: [
                              _buildStatusFilterChip('Tất cả', null),
                              _buildStatusFilterChip('Chờ xác nhận', 'pending'),
                              _buildStatusFilterChip(
                                  'Đã xác nhận', 'confirmed'),
                              _buildStatusFilterChip('Hoàn thành', 'completed'),
                              _buildStatusFilterChip('Đã hủy', 'cancelled'),
                            ],
                          ),
                        ),

                        // Reservations list
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadReservations,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _reservations.length,
                              itemBuilder: (context, index) {
                                final reservation = _reservations[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: ReservationCard(
                                    reservation: reservation,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ReservationDetailScreen(
                                            reservation: reservation,
                                          ),
                                        ),
                                      ).then((_) => _refresh());
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildStatusFilterChip(String label, String? status) {
    final isSelected = false; // Simplified for now
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Implement filter logic
        },
        selectedColor: Colors.orange,
        checkmarkColor: Colors.white,
      ),
    );
  }
}
