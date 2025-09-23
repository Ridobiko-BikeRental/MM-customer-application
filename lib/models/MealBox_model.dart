class MealBoxItem {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String vendorId;

  //constructor
  MealBoxItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.vendorId
  });

  // from json (for Api response)
  factory MealBoxItem.fromJson(Map<String, dynamic> json) {
    return MealBoxItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      vendorId: json['vendor'] ?? '',
    );
  }
}


class MealBox {
  final String id;
  final String title;
  final String description;
  final int minQty;
  final int price;
  final DateTime deliveryDate;
  final bool sampleAvailable;
  final String boxImage;
  final String actualImage;
  final List<MealBoxItem> items;
  final String packagingDetails;

  MealBox({
    required this.id,
    required this.title,
    required this.description,
    required this.minQty,
    required this.price,
    required this.deliveryDate,
    required this.sampleAvailable,
    required this.boxImage,
    required this.actualImage,
    required this.items,
    required this.packagingDetails,
  });

  factory MealBox.fromJson(Map<String,dynamic> json){
    return MealBox(
      id: json['_id'] ?? '',
      title: (json['title'] ?? '').toString().replaceAll(r'\"', '').trim(),
      description: (json['description'] ?? '').toString().replaceAll(r'\"', '').trim(),
      minQty: json['minQty'] ?? 0,
      price: json['price'] ?? 0,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : DateTime.now(),
      sampleAvailable: json['sampleAvailable'] ?? false,
      boxImage: json['boxImage'] ?? '',
      actualImage: json['actualImage'] ?? '',
      items: (json['items'] as List<dynamic> ?? [] )
      .map((item) => MealBoxItem.fromJson(item as Map<String,dynamic>)).toList(),
      packagingDetails: (json['packagingDetails'] ?? '').toString().replaceAll(r'\"', '').trim(),
    );
  }
}