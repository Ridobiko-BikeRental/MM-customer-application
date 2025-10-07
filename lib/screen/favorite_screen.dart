import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_colors.dart';
import '../../models/MealBox_model.dart';
import '../../models/subcategory.dart';
import '../../providers/MealBox_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/category_provider.dart';
import '../../API/favorite_api.dart';
import '../../widgets/navigation_bar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  

  @override
Widget build(BuildContext context) {
  final categories = Provider.of<CategoryProvider>(context).categories ?? [];
  final mealboxes = Provider.of<MealboxProvider>(context).Mealboxes;
  final favoriteProvider = context.watch<FavoriteProvider>();
  final cartProvider = Provider.of<CartProvider>(context, listen: false);

  // Flatten all subcategories
  final allSubs = categories.expand((cat) => cat.subCategories ?? []).toList();
  final allBoxes = mealboxes;

  final favoriteSubs = allSubs.where(
    (sub) => favoriteProvider.subCategoryFavoriteIds.contains(sub.id),
  ).toList();

  final favoriteMealBoxes = allBoxes.where(
    (box) => favoriteProvider.mealBoxFavoriteIds.contains(box.id),
  ).toList();

  bool noFavorites = favoriteSubs.isEmpty && favoriteMealBoxes.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: AppColors.buttonText,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: noFavorites
            ? Center(
                child: Text(
                  "No favorite items yet!",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (favoriteSubs.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Favorite Dishes',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: favoriteSubs.length,
                        itemBuilder: (context, index) {
                          final subCat = favoriteSubs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _favoriteDishCard(
                              context: context,
                              subCat: subCat,
                              cartProvider: cartProvider,
                            ),
                          );
                        },
                      ),
                    ],
                    if (favoriteMealBoxes.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:16, vertical: 16),
                        child: Text('Favorite MealBoxes',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: favoriteMealBoxes.length,
                        itemBuilder: (context, index) {
                          final box = favoriteMealBoxes[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _favoriteMealBoxCard(
                              context,
                              box,
                              Provider.of<FavoriteProvider>(context),
                              cartProvider,
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: MainNavBar(currentIndex: 2),
    );
  }

  Widget _favoriteDishCard({
    required BuildContext context,
    required SubCategory subCat,
    required CartProvider cartProvider,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.secondary,
                    image: (subCat.imageUrl != null && subCat.imageUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(subCat.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  ),
                  child: (subCat.imageUrl == null || subCat.imageUrl!.isEmpty)
                    ? Center(
                        child: Icon(
                          Icons.restaurant_menu,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Consumer<FavoriteProvider>(
                    builder: (context, favProvider, _) {
                      final isFav = favProvider.isFavorite((subCat.id).toString());
                      return GestureDetector(
                        onTap: () => favProvider.toggleFavorite(subCat.id.toString()),
                        child: Material(
                          color: Colors.transparent,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white.withOpacity(0.7),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subCat.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subCat.description,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹ ${subCat.pricePerUnit}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    cartProvider.addToCart(subCat);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Added to cart")),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.buttonText,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Order', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _favoriteMealBoxCard(
      BuildContext context,
      MealBox box,
      FavoriteProvider favProvider,
      CartProvider cartProvider,
      ) {
    final isFav = favProvider.isFavorite(box.id, isMealBox: true);


    List<String> images = [
      if (box.boxImage != null && box.boxImage!.isNotEmpty) box.boxImage!,
      if (box.actualImage != null && box.actualImage!.isNotEmpty) box.actualImage!,
    ];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 110,
                  child: PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          images[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  box.title.replaceAll('"', '').trim(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  box.description.replaceAll('"', '').trim(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (box.minQty != 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      "Minimum Quantity: ${box.minQty}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                Text(
                  "Packaging: ${box.packagingDetails.replaceAll('"', '').trim()}",
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${box.price}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Row(
                        children: [
                          if (box.sampleAvailable)
                            ElevatedButton(
                              onPressed: () {
                                cartProvider.addToCart(box);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Added sample meal box to cart",
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.buttonText,
                              ),
                              child: const Text("Order Sample"),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: AppColors.primary,
                            iconSize: 22,
                            onPressed: () {
                              cartProvider.addToCart(box);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Added meal box to cart"),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // The heart icon in top right corner overlaid with Positioned in Stack
          Positioned(
            top: 12,
            right: 18,
            child: GestureDetector(
              onTap: () async {
                try {
                  await favProvider.toggleFavorite(box.id, isMealBox: true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update favorite')),
                  );
                }
              },
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white,
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
