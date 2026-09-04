class CreateOrderItemRequest {
  CreateOrderItemRequest({
    required this.productId,
    required this.quantity,
    List<int> optionIds = const [],
    this.notes,
  }) : optionIds = List.unmodifiable(optionIds);

  final int productId;
  final int quantity;
  // Option IDs are unique in the catalog and retain their group membership there.
  final List<int> optionIds;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'option_ids': optionIds,
    if (notes != null) 'notes': notes,
  };
}
