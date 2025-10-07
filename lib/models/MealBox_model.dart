class MealBoxItem {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final double cost;
  final String? image;
  final String createdAt;
  final String? imageUrl;

  MealBoxItem({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.cost,
    required this.image,
    required this.createdAt,
    required this.imageUrl,
  });

  factory MealBoxItem.fromJson(Map<String, dynamic> json) {
    return MealBoxItem(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendor_id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      cost: double.tryParse(json['cost'].toString()) ?? 0,
      image: json['image'],
      createdAt: json['created_at'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}



class MealBox {
  final String id;
  final String vendorId;
  final String title;
  final String description;
  final int minQty;
  final int price;
  final int? minPrepareOrderDays;
  final int? maxPrepareOrderDays;
  final bool sampleAvailable;
  final String? boxImage;
  final String? actualImage;
  final List<MealBoxItem> items;
  final String packagingDetails;
  final int discount;
  final int originalPricePerUnit;
  final String discountStart;
  final String discountEnd;
  final String stockStatus;
  final String boxImageUrl;
  final String actualImageUrl;
  final bool available;
  final String createdAt; // Consider DateTime, but input is String format
  final List<dynamic> favoritedBy;

  MealBox({
    required this.id,
    required this.vendorId,
    required this.title,
    required this.description,
    required this.minQty,
    required this.price,
    this.minPrepareOrderDays,
    this.maxPrepareOrderDays,
    required this.sampleAvailable,
    required this.boxImage,
    required this.actualImage,
    required this.items,
    required this.packagingDetails,
    required this.discount,
    required this.originalPricePerUnit,
    required this.discountStart,
    required this.discountEnd,
    required this.stockStatus,
    required this.boxImageUrl,
    required this.actualImageUrl,
    required this.available,
    required this.createdAt,
    required this.favoritedBy,
  });

  factory MealBox.fromJson(Map<String, dynamic> json) {
    return MealBox(
      id: json['id'].toString(),
      vendorId: json['vendor_id'].toString(),
      title: (json['title'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
      minQty: json['minQty'] ?? 0,
      price: int.tryParse(json['price'].toString()) ?? 0,
      minPrepareOrderDays: json['minPrepareOrderDays'],
      maxPrepareOrderDays: json['maxPrepareOrderDays'],
      sampleAvailable: (json['sampleAvailable'] == 1 || json['sampleAvailable'] == true),
      boxImage: json['boxImage'],
      actualImage: json['actualImage'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => MealBoxItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      packagingDetails: (json['packagingDetails'] ?? '').toString().trim(),
      discount: int.tryParse(json['discount'].toString()) ?? 0,
      originalPricePerUnit: json['originalPricePerUnit'] is int
          ? json['originalPricePerUnit']
          : int.tryParse(json['originalPricePerUnit'].toString()) ?? 0,
      discountStart: json['discountStart'] ?? '',
      discountEnd: json['discountEnd'] ?? '',
      stockStatus: json['stock_status'] ?? '',
      boxImageUrl: json['boxImage_url'] ?? '',
      actualImageUrl: json['actualImage_url'] ?? '',
      available: json['available'] == 1 || json['available'] == true,
      createdAt: json['created_at'] ?? '',
      favoritedBy: json['favoritedBy'] ?? [],
    );
  }
}
