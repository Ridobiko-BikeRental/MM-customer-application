/* import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../models/subcategory.dart';
import '../models/Review.dart';

//fetch username from user id

class SeeReview_screen extends StatefulWidget {
  const SeeReview_screen({super.key});

  @override
  State<SeeReview_screen> createState() => _SeeReview_screenState();
}

class _SeeReview_screenState extends State<SeeReview_screen> {
  @override
  Widget build(BuildContext context) {
    final SubCategory subCat =
        ModalRoute.of(context)!.settings.arguments as SubCategory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Reviews',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: subCat.reviews.isEmpty
          ? Center(
              child: Text(
                "No reviews",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: subCat.reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final review = subCat.reviews[index];
                return _buildReviewCard(review);
              },
            ),
    );
  }

  Widget _buildReviewCard(Review review) {
    String displayUser = review.userId.length > 6
        ? 'User-${review.userId.substring(0, 6)}'
        : review.userId;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Placeholder circle avatar for user
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person,
                size: 28,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayUser,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(review.comment),
                ],
              ),
            ),
            // Optionally, a heart icon to favorite the review or user (not functional here)
            Icon(Icons.favorite_border, color: Colors.grey),
          ],
        ),
      ),
    );
  }
} */
