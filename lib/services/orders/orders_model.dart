class LocalizedText {
  final String ar;
  final String en;

  LocalizedText({required this.ar, required this.en});

  Map<String, dynamic> toJson() => {'ar': ar, 'en': en};

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(ar: json['ar'] ?? '', en: json['en'] ?? '');
  }
}

class OrderItemPayload {
  final int menuItemId;
  final int quantity;
  final LocalizedText customName;
  final LocalizedText customDescription;
  final double unitPrice;

  OrderItemPayload({
    required this.menuItemId,
    required this.quantity,
    required this.customName,
    required this.customDescription,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
    'menuItemId': menuItemId,
    'quantity': quantity,
    'customName': customName.toJson(),
    'customDescription': customDescription.toJson(),
    'unitPrice': unitPrice,
  };
}

class CreateOrderRequest {
  final int branchId;
  final List<OrderItemPayload> items;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String notes;
  final String paymentMethod;
  final String customerId;
  final String idempotencyKey;

  CreateOrderRequest({
    required this.branchId,
    required this.items,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.notes,
    required this.paymentMethod,
    required this.customerId,
    required this.idempotencyKey,
  });

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'items': items.map((i) => i.toJson()).toList(),
    'customerName': customerName,
    'customerPhone': customerPhone,
    'deliveryAddress': deliveryAddress,
    'notes': notes,
    'paymentMethod': paymentMethod,
    'customerId': customerId,
    'idempotencyKey': idempotencyKey,
  };
}

class PaymentInfo {
  final String method;
  final String status;

  PaymentInfo({required this.method, required this.status});

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      method: json['method'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class OrderCreatedResponse {
  final String orderId;
  final int orderNumber;
  final int stage;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final PaymentInfo payment;
  final String createdAt;

  OrderCreatedResponse({
    required this.orderId,
    required this.orderNumber,
    required this.stage,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.payment,
    required this.createdAt,
  });

  factory OrderCreatedResponse.fromJson(Map<String, dynamic> json) {
    return OrderCreatedResponse(
      orderId: json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? 0,
      stage: json['stage'] ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      payment: PaymentInfo.fromJson(json['payment'] ?? {}),
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class OrderSummaryItem {
  final String orderId;
  final int orderNumber;
  final String branchNameAr;
  final int stage;
  final double total;
  final String? customerReceivedAt;
  final bool hasReview;

  OrderSummaryItem({
    required this.orderId,
    required this.orderNumber,
    required this.branchNameAr,
    required this.stage,
    required this.total,
    this.customerReceivedAt,
    required this.hasReview,
  });

  factory OrderSummaryItem.fromJson(Map<String, dynamic> json) {
    return OrderSummaryItem(
      orderId: json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? 0,
      branchNameAr: json['branchNameAr'] ?? '',
      stage: json['stage'] ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      customerReceivedAt: json['customerReceivedAt'],
      hasReview: json['hasReview'] ?? false,
    );
  }
}

class PaginatedOrdersResponse {
  final List<OrderSummaryItem> items;
  final int page;
  final int pageSize;
  final int totalCount;

  PaginatedOrdersResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  factory PaginatedOrdersResponse.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    List<OrderSummaryItem> parsedItems = rawItems
        .map((i) => OrderSummaryItem.fromJson(i))
        .toList();

    return PaginatedOrdersResponse(
      items: parsedItems,
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
    );
  }
}
