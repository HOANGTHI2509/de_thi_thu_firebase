// lib/screens/reservation/create_reservation_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/reservation_repository.dart';
import '../../repositories/menu_item_repository.dart';
import '../../models/menu_item_model.dart';
import '../../models/order_item_model.dart';

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  State<CreateReservationScreen> createState() =>
      _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _guestsController =
      TextEditingController(text: '2');
  final TextEditingController _requestsController = TextEditingController();

  final MenuItemRepository _menuRepository = MenuItemRepository();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  bool _isLoading = false;
  List<MenuItemModel> _availableMenuItems = [];
  List<OrderItemModel> _selectedOrderItems = [];
  bool _showOrderSection = false;

  @override
  void initState() {
    super.initState();
    // Initialize date controller without context
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    // Update time controller after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDateTimeControllers();
      _loadMenuItems();
    });
  }

  void _updateDateTimeControllers() {
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    _timeController.text = _selectedTime.format(context);
  }

  Future<void> _loadMenuItems() async {
    try {
      final menuItems = await _menuRepository.getAllMenuItems();
      setState(() {
        _availableMenuItems =
            menuItems.where((item) => item.isAvailable).toList();
      });
    } catch (e) {
      // Handle error silently for now
      print('Error loading menu items: $e');
    }
  }

  void _addMenuItem(MenuItemModel menuItem) {
    final existingIndex = _selectedOrderItems.indexWhere(
      (item) => item.menuItemId == menuItem.itemId,
    );

    if (existingIndex >= 0) {
      // Increase quantity
      final existingItem = _selectedOrderItems[existingIndex];
      _updateQuantity(existingIndex, existingItem.quantity + 1);
    } else {
      // Add new item
      final orderItem = OrderItemModel(
        menuItemId: menuItem.itemId,
        name: menuItem.name,
        price: menuItem.price,
        quantity: 1,
        total: menuItem.price,
      );
      setState(() {
        _selectedOrderItems.add(orderItem);
      });
    }
  }

  void _removeMenuItem(String menuItemId) {
    setState(() {
      _selectedOrderItems.removeWhere((item) => item.menuItemId == menuItemId);
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _selectedOrderItems.removeAt(index);
    } else {
      final item = _selectedOrderItems[index];
      final updatedItem = item.copyWith(
        quantity: newQuantity,
        total: item.price * newQuantity,
      );
      _selectedOrderItems[index] = updatedItem;
    }
    setState(() {});
  }

  double _calculateSubtotal() {
    return _selectedOrderItems.fold(0.0, (sum, item) => sum + item.total);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.orange,
            colorScheme: const ColorScheme.light(primary: Colors.orange),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateDateTimeControllers();
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.orange,
            colorScheme: const ColorScheme.light(primary: Colors.orange),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _updateDateTimeControllers();
      });
    }
  }

  Future<void> _createReservation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }
      final customerId = currentUser.uid;

      // Kết hợp date và time
      final reservationDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Kiểm tra thời gian không quá khứ
      if (reservationDateTime.isBefore(DateTime.now())) {
        throw Exception('Không thể đặt bàn trong quá khứ');
      }

      final numberOfGuests = int.tryParse(_guestsController.text) ?? 2;

      if (numberOfGuests < 1 || numberOfGuests > 20) {
        throw Exception('Số lượng khách phải từ 1-20 người');
      }

      await ReservationRepository().createReservation(
        customerId: customerId,
        reservationDate: Timestamp.fromDate(reservationDateTime),
        numberOfGuests: numberOfGuests,
        specialRequests: _requestsController.text.trim().isEmpty
            ? null
            : _requestsController.text.trim(),
        orderItems: _selectedOrderItems.map((item) => item.toJson()).toList(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt bàn thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt bàn mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Icon(
                  Icons.table_restaurant,
                  size: 64,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Đặt bàn nhà hàng',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Ngày
              const Text(
                'Ngày đặt bàn *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Chọn ngày',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: _selectDate,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn ngày';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Giờ
              const Text(
                'Giờ đặt bàn *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Chọn giờ',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.schedule),
                    onPressed: _selectTime,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn giờ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Số lượng khách
              const Text(
                'Số lượng khách *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _guestsController,
                decoration: InputDecoration(
                  hintText: 'Nhập số lượng khách',
                  prefixIcon: const Icon(Icons.people),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số lượng khách';
                  }
                  final guests = int.tryParse(value);
                  if (guests == null || guests < 1 || guests > 20) {
                    return 'Số lượng khách phải từ 1-20 người';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Yêu cầu đặc biệt
              const Text(
                'Yêu cầu đặc biệt',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _requestsController,
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Bàn gần cửa sổ, không đồ cay...',
                  prefixIcon: const Icon(Icons.edit_note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Thông tin summary
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin đặt bàn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Ngày:', _dateController.text),
                      _buildInfoRow('Giờ:', _timeController.text),
                      _buildInfoRow(
                          'Số khách:', '${_guestsController.text} người'),
                      if (_selectedOrderItems.isNotEmpty) ...[
                        _buildInfoRow(
                            'Số món:', '${_selectedOrderItems.length} món'),
                        _buildInfoRow('Tổng tiền:',
                            '${_calculateSubtotal().toStringAsFixed(0)} VND'),
                      ],
                      if (_requestsController.text.isNotEmpty)
                        _buildInfoRow('Yêu cầu:', _requestsController.text),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section chọn món ăn
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chọn món ăn',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showOrderSection = !_showOrderSection;
                              });
                            },
                            icon: Icon(_showOrderSection
                                ? Icons.expand_less
                                : Icons.expand_more),
                            label: Text(_showOrderSection ? 'Ẩn' : 'Hiện'),
                          ),
                        ],
                      ),
                      if (_showOrderSection) ...[
                        const SizedBox(height: 16),
                        // Danh sách món ăn có sẵn
                        const Text(
                          'Menu nhà hàng:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: _availableMenuItems.isEmpty
                              ? const Center(child: Text('Đang tải menu...'))
                              : ListView.builder(
                                  itemCount: _availableMenuItems.length,
                                  itemBuilder: (context, index) {
                                    final menuItem = _availableMenuItems[index];
                                    return ListTile(
                                      title: Text(menuItem.name),
                                      subtitle: Text(
                                          '${menuItem.price.toStringAsFixed(0)} VND'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.add_circle,
                                            color: Colors.orange),
                                        onPressed: () => _addMenuItem(menuItem),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 16),
                        // Danh sách món đã chọn
                        if (_selectedOrderItems.isNotEmpty) ...[
                          const Text(
                            'Món đã chọn:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._selectedOrderItems.map((orderItem) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              orderItem.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              '${orderItem.price.toStringAsFixed(0)} VND x ${orderItem.quantity}',
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove,
                                                color: Colors.red),
                                            onPressed: () => _updateQuantity(
                                              _selectedOrderItems
                                                  .indexOf(orderItem),
                                              orderItem.quantity - 1,
                                            ),
                                          ),
                                          Text(
                                            '${orderItem.quantity}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add,
                                                color: Colors.green),
                                            onPressed: () => _updateQuantity(
                                              _selectedOrderItems
                                                  .indexOf(orderItem),
                                              orderItem.quantity + 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _removeMenuItem(
                                            orderItem.menuItemId),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          const SizedBox(height: 8),
                          Text(
                            'Tổng tiền: ${_calculateSubtotal().toStringAsFixed(0)} VND',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _createReservation,
                        icon: const Icon(Icons.table_restaurant),
                        label: const Text(
                          'Đặt bàn',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _guestsController.dispose();
    _requestsController.dispose();
    super.dispose();
  }
}
