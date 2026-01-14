// lib/screens/reservation/reservation_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reservation_model.dart';
import '../../repositories/reservation_repository.dart';
import '../../repositories/customer_repository.dart';

class ReservationDetailScreen extends StatefulWidget {
  final ReservationModel reservation;

  const ReservationDetailScreen({
    super.key,
    required this.reservation,
  });

  @override
  State<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  bool _isLoading = false;
  int? _customerLoyaltyPoints;

  @override
  void initState() {
    super.initState();
    _loadCustomerLoyaltyPoints();
  }

  Future<void> _loadCustomerLoyaltyPoints() async {
    try {
      final customer = await CustomerRepository()
          .getCustomerById(widget.reservation.customerId);

      if (customer != null) {
        setState(() {
          _customerLoyaltyPoints = customer.loyaltyPoints;
        });
      }
    } catch (e) {
      print('Error loading loyalty points: $e');
    }
  }

  Future<void> _cancelReservation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn có chắc chắn muốn hủy đặt bàn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Có, hủy đặt bàn'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ReservationRepository()
          .cancelReservation(widget.reservation.reservationId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy đặt bàn thành công'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi hủy đặt bàn: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _payReservation() async {
    if (_customerLoyaltyPoints == null) return;

    final paymentMethod = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn phương thức thanh toán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.money, color: Colors.green),
              title: const Text('Tiền mặt'),
              onTap: () => Navigator.pop(context, 'cash'),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.blue),
              title: const Text('Thẻ ngân hàng'),
              onTap: () => Navigator.pop(context, 'card'),
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.purple),
              title: const Text('Online'),
              onTap: () => Navigator.pop(context, 'online'),
            ),
          ],
        ),
      ),
    );

    if (paymentMethod == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ReservationRepository().payReservation(
        reservationId: widget.reservation.reservationId,
        paymentMethod: paymentMethod,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanh toán thành công'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi thanh toán: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'seated':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'seated':
        return 'Đã vào bàn';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      case 'no_show':
        return 'Không đến';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservationDate = widget.reservation.reservationDate.toDate();
    final formattedDate = DateFormat('dd/MM/yyyy').format(reservationDate);
    final formattedTime = DateFormat('HH:mm').format(reservationDate);

    final canCancel = widget.reservation.status == 'pending' ||
        widget.reservation.status == 'confirmed';

    final canPay = widget.reservation.status == 'seated' &&
        widget.reservation.paymentStatus == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đặt bàn'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.reservation.status)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(widget.reservation.status),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(widget.reservation.status),
                          color: _getStatusColor(widget.reservation.status),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStatusText(widget.reservation.status),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(
                                      widget.reservation.status),
                                ),
                              ),
                              if (widget.reservation.tableNumber != null)
                                Text(
                                  'Bàn số: ${widget.reservation.tableNumber}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                        if (widget.reservation.paymentStatus == 'paid')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Đã thanh toán',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Basic Info
                  const Text(
                    'Thông tin đặt bàn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                      'Mã đặt bàn:', widget.reservation.reservationId),
                  _buildInfoRow('Ngày:', formattedDate),
                  _buildInfoRow('Giờ:', formattedTime),
                  _buildInfoRow('Số lượng khách:',
                      '${widget.reservation.numberOfGuests} người'),
                  if (widget.reservation.specialRequests != null)
                    _buildInfoRow('Yêu cầu đặc biệt:',
                        widget.reservation.specialRequests!),

                  const SizedBox(height: 24),

                  // Order Items
                  if (widget.reservation.orderItems.isNotEmpty) ...[
                    const Text(
                      'Món đã đặt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.reservation.orderItems.map((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: const Icon(Icons.restaurant,
                              color: Colors.orange),
                          title: Text(item['name'] ?? ''),
                          subtitle: Text(
                              '${item['price']?.toStringAsFixed(0) ?? '0'} VNĐ x ${item['quantity'] ?? 1}'),
                          trailing: Text(
                            '${(item['total'] ?? 0).toStringAsFixed(0)} VNĐ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],

                  const SizedBox(height: 24),

                  // Payment Summary
                  const Text(
                    'Thông tin thanh toán',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildPaymentRow(
                              'Tạm tính:', widget.reservation.subtotal),
                          _buildPaymentRow('Phí phục vụ (10%):',
                              widget.reservation.serviceCharge),
                          if (widget.reservation.discount > 0)
                            _buildPaymentRow(
                                'Giảm giá:', -widget.reservation.discount,
                                isDiscount: true),
                          const Divider(height: 24),
                          _buildPaymentRow(
                              'Tổng cộng:', widget.reservation.total,
                              isTotal: true),
                          if (_customerLoyaltyPoints != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Điểm tích lũy hiện có: $_customerLoyaltyPoints điểm',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (widget.reservation.paymentMethod != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Phương thức thanh toán: ${widget.reservation.paymentMethod!}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  if (canCancel || canPay)
                    Column(
                      children: [
                        if (canCancel)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: _cancelReservation,
                              icon: const Icon(Icons.cancel),
                              label: const Text('Hủy đặt bàn'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        if (canCancel && canPay) const SizedBox(height: 12),
                        if (canPay)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _payReservation,
                              icon: const Icon(Icons.payment),
                              label: const Text('Thanh toán'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                  const SizedBox(height: 16),
                ],
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
            width: 120,
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

  Widget _buildPaymentRow(String label, double amount,
      {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}${amount.toStringAsFixed(0)} VNĐ',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
              color: isTotal
                  ? Colors.orange
                  : (isDiscount ? Colors.green : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle;
      case 'seated':
        return Icons.chair;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'no_show':
        return Icons.no_accounts;
      default:
        return Icons.info;
    }
  }
}
