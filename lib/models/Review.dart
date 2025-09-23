class Review {
  final String id;
  final String userId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'],
      userId: json['user'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

