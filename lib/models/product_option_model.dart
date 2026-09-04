class ProductOptionModel {
  const ProductOptionModel({
    required this.id,
    required this.name,
    required this.price,
  });
  final int id;
  final String name;
  final double price;

  factory ProductOptionModel.fromJson(Map<String, dynamic> json) =>
      ProductOptionModel(
        id: json['id'] as int,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
      );
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};
}
