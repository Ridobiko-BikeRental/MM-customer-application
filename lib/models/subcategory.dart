import '../models/Review.dart';

class SubCategory {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String vendor;
  final int pricePerUnit;
  final String? imageUrl;
  final int discount;  
  final List<Review> reviews;
  final bool available;

  SubCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.vendor,
    required this.pricePerUnit,
    this.imageUrl,
    this.discount = 0, // Default to 0 if missing 
    this.reviews = const [],
    this.available = true,
  });

  int get discountedPrice {
    if (discount > 0) {
      return (pricePerUnit * (100 - discount) ~/ 100);
    }
    return pricePerUnit;
  }

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['category'],
      vendor: json['vendor'] ?? '',
      pricePerUnit: json['pricePerUnit'] ?? 0,
      imageUrl: json['imageUrl'],
      discount: json['discount'] ?? 0,
      reviews: ((json['reviews'] ?? []) as List)
          .map((r) => Review.fromJson(r))
          .toList(),
      available: json['available'] ?? true,
    );
  }
}

