import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yumquick/API/favorite_api.dart';
import '../../app_colors.dart';
import '../../models/MealBox_model.dart';
import '../../providers/cart_provider.dart';

class MealBoxDetailsScreen extends StatelessWidget {
  const MealBoxDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the MealBox object passed via Navigator
    final MealBox box = ModalRoute.of(context)?.settings.arguments as MealBox;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    final isBoxFav = favoriteProvider.isFavorite(box.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.buttonText,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.buttonText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('More details', style: TextStyle(color: AppColors.buttonText, )),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: box.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) {
          final item = box.items[i];
          return _itemCard(context, item, box.id);
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
           /* GestureDetector(
              onTap: () => favoriteProvider.toggleFavorite(box.id),
              child: Icon(
                isBoxFav ? Icons.favorite : Icons.favorite_border,
                color: isBoxFav ? AppColors.heart : AppColors.heartBorder,
                size: 28,
              ),
            ), */
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.buttonText,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  cartProvider.addToCart(box);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sample meal box added to cart')),
                  );
                },
                child: const Text('Order Sample'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.buttonText,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  cartProvider.addToCart(box);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart')),
                  );
                  Navigator.pushNamed(context, '/checkout'); // Assume /cart route exists
                },
                child: const Text('Add to cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemCard(BuildContext context, MealBoxItem item, String boxId) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    final isFav = favoriteProvider.isFavorite(item.id);
    final MealBox box = ModalRoute.of(context)?.settings.arguments as MealBox;


    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(context, '/mealbox_SubCat', arguments: box);
        },
       child: Card(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       elevation: 4,
       child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.image, size: 40, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.replaceAll('"', '').trim(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(item.description.replaceAll('"', '').trim()),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => favoriteProvider.toggleFavorite(item.id),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? AppColors.heart : AppColors.heartBorder,
                size: 28,
              ),
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }
}
