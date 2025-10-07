import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../API/favorite_api.dart';
import '../../providers/cart_provider.dart';
import '../../models/MealBox_model.dart';
import '../../app_colors.dart';
import '../cart/cart_screen.dart';
import '../../providers/MealBox_provider.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/image_carousal.dart';

class MealBoxScreen extends StatefulWidget {
  const MealBoxScreen({super.key});

  @override
  State<MealBoxScreen> createState() => _MealBoxScreenState();
}

class _MealBoxScreenState extends State<MealBoxScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
      } catch (e) {
        print('Error fetching favorites: $e');
      }
      try {
        await Provider.of<MealboxProvider>(context, listen: false).fetchMealboxes();
      } catch (e) {
        print('Error fetching mealboxes: $e');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealboxProvider = Provider.of<MealboxProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    final allBoxes = mealboxProvider.Mealboxes;
    final filteredBoxes = (_searchQuery.isEmpty)
        ? allBoxes
        : allBoxes.where((box) {
            final title = box.title.toLowerCase();
            final desc = box.description.toLowerCase();
            final query = _searchQuery.toLowerCase();
            return title.contains(query) || desc.contains(query);
          }).toList();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Meal Boxes',
          style: TextStyle(color: AppColors.buttonText),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Material(
                  color: AppColors.background,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.pushNamed(context, '/checkout'),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.shopping_cart,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -3,
                  top: -4,
                  child: Consumer<CartProvider>(
                    builder: (_, cart, __) {
                      if (cart.totalItems == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: Text(
                          '${cart.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search meal boxes...',
                filled: true,
                fillColor: AppColors.background,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: mealboxProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : (mealboxProvider.errorMessage != null)
                    ? Center(
                        child: Text(
                          mealboxProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : filteredBoxes.isEmpty
                        ? const Center(child: Text("No meal boxes found"))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount: filteredBoxes.length,
                            itemBuilder: (_, index) {
                              final box = filteredBoxes[index];
                              return buildMealBoxCard(
                                context,
                                box,
                                favoriteProvider,
                                cartProvider,
                              );
                            },
                          ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavBar(currentIndex: 1),
    );
  }

  Widget buildMealBoxCard(
    BuildContext context,
    MealBox box,
    FavoriteProvider favProvider,
    CartProvider cartProvider,
  ) {
    final isFav = favProvider.isFavorite(box.id, isMealBox: true);

    List<String> images = [
      if (box.boxImage != null && box.boxImage?.isNotEmpty == true) box.boxImage!,
      if (box.actualImage != null && box.actualImage?.isNotEmpty == true) box.actualImage!,
    ];

    return Material(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(context, '/mealbox_SubCat', arguments: box);
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        MealBoxImageCarousel(
                          images: images,
                          height: 190,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        if (box.sampleAvailable)
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.amber, size: 16),
                                  const SizedBox(width: 5),
                                  const Text(
                                    "Sample Available",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      box.title.replaceAll('"', '').trim(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      box.description.replaceAll('"', '').trim(),
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                      maxLines: 3,
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Row(
                            children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/checkout');
                                    cartProvider.addToCart(box);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Added meal box to cart",
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 17,
                                      vertical: 7,
                                    ),
                                    
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.buttonText,
                                  ),
                                  child: const Text("Order",style: TextStyle(fontSize: 16),),
                                ),
                              const SizedBox(width: 3),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: AppColors.primary,
                            iconSize: 39,
                            onPressed: () {
                              cartProvider.addToCart(box);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Added meal box to cart"),
                                ),
                              );
                            },
                            padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                      maxWidth: 22,
                      maxHeight: 36,
                    ),
                          ),
                          
                        ],
                      ),
                        ]
                    ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 18,
                child: GestureDetector(
                  onTap: () async {
                    try {
                      await favProvider.toggleFavorite(box.id, isMealBox: true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update favorite'))
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
        ),
      ),
    );
  }
}
