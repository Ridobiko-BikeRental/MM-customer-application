import '../models/Review.dart';

class SubCategory {
  final int id;
  final String name;
  final String description;
  final int categoryId;
  final int vendorId;
  final int pricePerUnit;
  final int originalPricePerUnit;
  final int minQty;
  final String? imageUrl;
  final int discount;
  final String? discountStart;
  final String? discountEnd;
  //final List<Review> reviews;
  final bool available;
  final String priceType;
  final int quantity;
  final bool deliveryPriceEnabled;
  final int deliveryPrice;
  final int minDeliveryDays;
  final int maxDeliveryDays;
  //final String? createdAt;
  final String? stockStatus;

  SubCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.vendorId,
    required this.pricePerUnit,
    required this.originalPricePerUnit,
    this.imageUrl,
    this.discount = 0,
    this.discountStart,
    this.discountEnd,
    //this.reviews = const [],
    this.available = true,
    required this.minQty,
    required this.priceType,
    this.quantity = 0,
    this.deliveryPriceEnabled = false,
    this.deliveryPrice = 0,
    this.minDeliveryDays = 0,
    this.maxDeliveryDays = 0,
   // this.createdAt,
    this.stockStatus,
  });

  int get discountedPrice {
    if (discount > 0) {
      return (pricePerUnit * (100 - discount) ~/ 100);
    }
    return pricePerUnit;
  }

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    int _asInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    double _asDouble(dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    bool _asBool(dynamic v) {
      if (v is bool) return v;
      if (v is int) return v == 1;
      if (v is String) return v == '1' || v.toLowerCase() == 'true';
      return false;
    }

    return SubCategory(
      id: _asInt(json['id']),
      name: (json['name'] as String?)?.trim() ?? '',
      description: json['description'] ?? '',
      categoryId: _asInt(json['category_id']),
      vendorId: _asInt(json['vendor_id']),
      pricePerUnit: _asInt(json['pricePerUnit']),
      originalPricePerUnit: _asInt(json['originalPricePerUnit']),
      minQty: _asInt(json['minQty'] ?? json['quantity']), // fallback if minQty missing
      imageUrl: json['imageUrl'] ?? json['image_url'],
      discount: _asInt(json['discount']),
      discountStart: json['discountStart'] as String?,
      discountEnd: json['discountEnd'] as String?,
      //reviews: (json['reviews'] as List<dynamic>? ?? []).map((r) => Review.fromJson(r)).toList(),
      available: _asBool(json['available']),
      priceType: (json['priceType'] as String? ?? 'unit').toLowerCase(),
      quantity: _asInt(json['quantity']),
      deliveryPriceEnabled: _asBool(json['deliveryPriceEnabled']),
      deliveryPrice: _asInt(json['deliveryPrice']),
      minDeliveryDays: _asInt(json['minDeliveryDays']),
      maxDeliveryDays: _asInt(json['maxDeliveryDays']),
      //createdAt: json['created_at'] as String?,
      stockStatus: json['stock_status'] as String?,
    );
  }
}
