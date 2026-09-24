class CartItem {
  final String id;
  final String name;
  final String description;
  final int unitPrice;
  final int quantity;

  const CartItem({
    required this.id,
    required this.name,
    required this.description,
    required this.unitPrice,
    this.quantity = 1,
  });

  int get totalPrice => unitPrice * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      description: description,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      unitPrice: json['unitPrice'] ?? 0,
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'unitPrice': unitPrice,
    'quantity': quantity,
  };
}
