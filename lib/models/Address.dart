class UserAddress {
  final String id;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final String label;

  UserAddress({
    required this.id,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.label,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
        id: json['_id'] ?? '',
        addressLine: json['addressLine'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        pincode: json['pincode'] ?? '',
        label: json['label'] ?? '',
      );
}
