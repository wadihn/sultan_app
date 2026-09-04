class CategoryModel {
  const CategoryModel({required this.id, required this.name, this.imageUrl});
  final int id;
  final String name;
  final String? imageUrl;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'] as int,
    name: json['name'] as String,
    imageUrl: json['image_url'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image_url': imageUrl,
  };
}
