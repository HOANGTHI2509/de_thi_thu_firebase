import 'package:flutter/material.dart';
import '../repositories/reservation_repository.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestsController = TextEditingController();
  final _requestController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _repository = ReservationRepository();

  // Xử lý khi nhấn nút Xác nhận
  void _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Thực hiện lưu vào Firebase
        await _repository.createReservation(
          "customer_01", // Giả định ID khách mẫu
          _selectedDate,
          int.parse(_guestsController.text),
          _requestController.text,
        );

        // KIỂM TRA MOUNTED: Sửa lỗi dùng context sau async
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Đặt bàn thành công!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Quay lại Menu
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đặt Bàn Mới"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Thông tin đặt chỗ", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Ô nhập số khách
              TextFormField(
                controller: _guestsController,
                decoration: const InputDecoration(
                  labelText: "Số lượng khách",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? "Vui lòng nhập số khách" : null,
              ),
              const SizedBox(height: 20),

              // Chọn ngày
              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                title: Text("Ngày đặt: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                trailing: const Icon(Icons.calendar_today, color: Colors.orange),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2027),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 20),

              // Yêu cầu đặc biệt
              TextFormField(
                controller: _requestController,
                decoration: const InputDecoration(
                  labelText: "Yêu cầu đặc biệt (Ghi chú)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _submitReservation,
                child: const Text("XÁC NHẬN ĐẶT BÀN", 
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}