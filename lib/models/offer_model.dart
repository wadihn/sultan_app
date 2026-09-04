class OfferModel {
  const OfferModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
  });
  final int id;
  final String title;
  final String description;
  final String? imageUrl;

  factory OfferModel.fromJson(Map<String, dynamic> json) => OfferModel(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    imageUrl: json['image_url'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'image_url': imageUrl,
  };
}
