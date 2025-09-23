import 'package:flutter/material.dart';
import '../../models/MealBox_model.dart';
import '../../app_colors.dart';
//const String kDefaultSubcatImage = "https://via.placeholder.com/300x180.png?text=No+Image";

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MealBox box = ModalRoute.of(context)!.settings.arguments as MealBox;
    final data = box.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EF),
      appBar: AppBar(
        title: const Text("Items"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.buttonText,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: data.isEmpty
            ? const Center(child: Text("No subcategories available."))
            : ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (ctx, idx) {
                  final mealItem = data[idx];
                  return SubCatCardStyled(item: mealItem);
                },
              ),
      ),
    );
  }
}

class SubCatCardStyled extends StatelessWidget {
  final MealBoxItem item;
  const SubCatCardStyled({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    //final double rating = 4.5; // Static for demo

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rounded corners
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                    ? item.imageUrl!
                    : "https://via.placeholder.com/300x180.png?text=No+Image",
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    item.name.trim(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.black,
                    ),
                  ),
                ),
                
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.description.trim(),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}