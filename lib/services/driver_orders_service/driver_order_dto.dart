class DriverNewOrderDto {
  final String orderId;
  final int orderNumber;
  final String? customerAddress;
  final String? customerPhone; // Added phone field
  final double total;
  final String? notes;

  DriverNewOrderDto({
    required this.orderId,
    required this.orderNumber,
    this.customerAddress,
    this.customerPhone,
    required this.total,
    this.notes,
  });

  factory DriverNewOrderDto.fromJson(Map<String, dynamic> json) {
    return DriverNewOrderDto(
      orderId: json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? 0,
      customerAddress: json['customerAddress'],
      customerPhone:
          json['customerPhone'] ??
          json['phone'], // Adjust key if backend uses a different name
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
    );
  }
}

class DriverOrderMineDto {
  final String orderId;
  final int orderNumber;
  final int stage;
  final String? customerAddress;
  final String? customerPhone; // Added phone field
  final double total;

  DriverOrderMineDto({
    required this.orderId,
    required this.orderNumber,
    required this.stage,
    this.customerAddress,
    this.customerPhone,
    required this.total,
  });

  factory DriverOrderMineDto.fromJson(Map<String, dynamic> json) {
    return DriverOrderMineDto(
      orderId: json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? 0,
      stage: json['stage'] ?? 0,
      customerAddress: json['customerAddress'],
      customerPhone: json['customerPhone'],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
