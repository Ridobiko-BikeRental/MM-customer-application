import 'subcategory.dart';

class Category {
  final int id;
  final String name;
  final String? image;
  final int vendorId;
  final List<SubCategory> subCategories; // Use only if present in that API's response

  Category({
    required this.id,
    required this.name,
    this.image,
    required this.vendorId,
    this.subCategories = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // Flexible: parse subCategories if present (for future extensibility)
    var subCats = <SubCategory>[];
    if (json['subCategories'] != null) {
      subCats = (json['subCategories'] as List)
          .map((x) => SubCategory.fromJson(x))
          .toList();
    } else if (json['subcategories'] != null) { // support PHP snake_case
      subCats = (json['subcategories'] as List)
          .map((x) => SubCategory.fromJson(x))
          .toList();
    }
    return Category(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
      vendorId: json['vendor_id'] is int
          ? json['vendor_id']
          : int.tryParse(json['vendor_id']?.toString() ?? '') ?? 0,
      subCategories: subCats,
    );
  }
}
