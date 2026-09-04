class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.selectedOptions = const [],
    this.notes,
  });
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final List<String> selectedOptions;
  final String? notes;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    productId: json['product_id'] as int,
    productName: json['product_name'] as String,
    quantity: json['quantity'] as int,
    unitPrice: (json['unit_price'] as num).toDouble(),
    selectedOptions: (json['selected_options'] as List<dynamic>? ?? [])
        .cast<String>(),
    notes: json['notes'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'product_name': productName,
    'quantity': quantity,
    'unit_price': unitPrice,
    'selected_options': selectedOptions,
    'notes': notes,
  };
}
