import 'subcategory.dart';

class Category {
  final String id;
  final String name;
  final String shortDescription;
  final int quantity;
  final String? imageUrl;
  final String? vendor;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.quantity,
    this.imageUrl,
    required this.vendor,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var subCats = <SubCategory>[];
  if (json['subCategories'] != null) {
    subCats = (json['subCategories'] as List)
        .map((x) => SubCategory.fromJson(x))
        .toList();
  }
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'],
      vendor: json['vendor']?? '',
      subCategories: subCats,
    );
  }
}
