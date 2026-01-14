// lib/models/order_item_model.dart
class OrderItemModel {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String? specialInstructions;
  final double total;

  OrderItemModel({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.specialInstructions,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'total': total,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      menuItemId: json['menuItemId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: (json['quantity'] ?? 1) as int,
      specialInstructions: json['specialInstructions'],
      total: (json['total'] ?? 0.0).toDouble(),
    );
  }

  OrderItemModel copyWith({
    String? menuItemId,
    String? name,
    double? price,
    int? quantity,
    String? specialInstructions,
    double? total,
  }) {
    return OrderItemModel(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      total: total ?? this.total,
    );
  }

  @override
  String toString() {
    return 'OrderItemModel(name: $name, quantity: $quantity, total: $total)';
  }
}
