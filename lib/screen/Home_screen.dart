import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../providers/category_provider.dart';
import '../models/subcategory.dart';
import '../API/auth_api.dart';
import 'cart/cart_screen.dart';
import '../providers/cart_provider.dart';
import '../widgets/categories_chip.dart';
import '../API/favorite_api.dart';
import '../widgets/navigation_bar.dart';
import 'package:badges/badges.dart' as badges;
import '../models/Review.dart';

class Home_screen extends StatefulWidget {
  const Home_screen({super.key});

  @override
  State<Home_screen> createState() => _Home_screenState();
}

class _Home_screenState extends State<Home_screen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      categoryProvider.loadCategoriesWithSubcategories();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = query;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteIds = context
        .watch<FavoriteProvider>()
        .subCategoryFavoriteIds;
    final provider = Provider.of<CategoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

    // Get all items and apply filtering based on search query
    final allItems = provider.subCategoriesForSelected;
    final filteredItems = _searchQuery.isEmpty
        ? allItems
        : allItems.where((item) {
            final title = item.name.toLowerCase();
            final desc = item.description.toLowerCase();
            final query = _searchQuery.toLowerCase();
            return title.contains(query) || desc.contains(query);
          }).toList();
    // print("Total products for selection: ${filteredItems.length}");
    //log("Total products for selection: ${filteredItems.length}");
    // print("Building HomeScreen with selected category: ${provider.selectedCategory}");
    //print("Total categories available: ${provider.categories.length}");
    //print("Total chip categories: ${provider.chipCategories.length}");
    //print("Total subcategories for selected: ${provider.subCategoriesForSelected.length}");

    return Scaffold(
      key: scaffoldKey,
      drawer: ProfileDrawer(context),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Munch Box', style: TextStyle(color: AppColors.buttonText)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: AppColors.buttonText),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Material(
                  color: AppColors.background,
                  shape: CircleBorder(),
                  child: InkWell(
                    customBorder: CircleBorder(),
                    onTap: () {
                      Navigator.pushNamed(context, '/checkout');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.shopping_cart,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -3,
                  top: -8,
                  child: Consumer<CartProvider>(
                    builder: (_, cartProvider, __) {
                      if (cartProvider.totalItems == 0) {
                        return SizedBox.shrink();
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${cartProvider.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search meals...',
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

                  // Categories section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        CategoryChipsRow(
                          categories: provider.chipCategories,
                          selectedCategory: provider.selectedCategory,
                          onSelected: (catName) =>
                              provider.selectCategory(catName),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Products Grid w/ filtered list
                  _subcategoryComboSection(filteredItems),
                ],
              ),
            ),
      bottomNavigationBar: MainNavBar(currentIndex: 0),
    );
  }

  Widget _subcategoryComboSection(List<SubCategory> subCategories) {
    if (subCategories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No products found for this selection.'),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Products',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: Icon(Icons.tune, color: AppColors.primary),
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/filter_screen',
                  );
                  if (result != null && result is Map<String, dynamic>) {
                    final category = result['category'] as String?;
                    final rating = result['rating'] as double?;
                    final price = result['price'] as double?;

                    // Apply these filters in your home screen provider/state
                    Provider.of<CategoryProvider>(
                      context,
                      listen: false,
                    ).applyFilters(
                      category: category,
                      rating: rating,
                      price: price,
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          itemCount: subCategories.length,
          itemBuilder: (context, i) {
            return _subCategoryCard(subCategories[i]);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  double getAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    int total = reviews.fold(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  // Subcategory card widget
  Widget _subCategoryCard(SubCategory subCat) {
    final favoriteIds = Provider.of<FavoriteProvider>(
      context,
    ).subCategoryFavoriteIds;
    final isFav = favoriteIds.contains(subCat.id);
    //final avgRating = getAverageRating(subCat.reviews);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                badges.Badge(
                  showBadge: subCat.discount > 0,
                  badgeContent: Text(
                    '${subCat.discount}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: Colors.red,
                    shape: badges.BadgeShape.instagram,
                    borderRadius: BorderRadius.circular(8),
                    elevation: 5,
                    padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  ),
                  position: badges.BadgePosition.topStart(top: 8, start: 5),
                  child: Container(
                    height: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.secondary,
                      image:
                          (subCat.imageUrl != null &&
                              subCat.imageUrl!.isNotEmpty)
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
                ),

                // Heart badge
                Positioned(
                  top: 6,
                  right: 6,
                  child: Consumer<FavoriteProvider>(
                    builder: (context, favProvider, _) {
                      final isFav = favProvider.isFavorite((subCat.id).toString());
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          // await Provider.of<FavoriteProvider>(context, listen: false).toggleFavorite(subCat.id);
                          await favProvider.toggleFavorite((subCat.id).toString());
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border_sharp,
                              color: isFav ? Colors.red : AppColors.background,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Rating block
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/SeeReviews',
                              arguments: subCat,
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellowAccent,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              /* Text(
                                avgRating > 0
                                    ? avgRating.toStringAsFixed(1)
                                    : 'No rating',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ), */
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                       /* Text(
                          '(${subCat.reviews.length})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ), */
                      ],
                    ),
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
            SizedBox(height: 6),
            Text(
              subCat.description,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6),
            Text(
              'MinQyt: ${subCat.minQty.toString()}',
              style: const TextStyle(fontSize: 12, color: Colors.black),
              //maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.5),

            //Reviews
            /* Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/SeeReviews',
                      arguments: subCat,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 18),
                      SizedBox(width: 4),
                      Text(
                        avgRating > 0
                            ? avgRating.toStringAsFixed(1)
                            : 'No rating',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${subCat.reviews.length})',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ), */
            //const Spacer(),
            _controlsRow(subCat),
          ],
        ),
      ),
    );
  }

  // Controls row showing price and buttons
  Widget _controlsRow(dynamic subCat) {
    final bool isOutOfStock = !(subCat.available ?? true);
    String priceTypeLabel = subCat.priceType.toLowerCase() == 'gram'
        ? 'gram'
        : 'unit';
    String explainText = subCat.priceType.toLowerCase() == 'gram'
        ? '1 unit = 100gm'
        : '1 unit = N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            subCat.discount > 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${subCat.pricePerUnit}/${priceTypeLabel}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 24, // try larger, e.g., 24 or 28
                        ),
                      ),
                      Text(
                        '₹${subCat.discountedPrice}/${priceTypeLabel}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                          fontSize: 28, // try larger, e.g., 28
                        ),
                      ),
                      SizedBox(height: 2.5),
                      Text(
                        explainText,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${subCat.pricePerUnit}/${priceTypeLabel}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        explainText,
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
            if (isOutOfStock)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Out of Stock',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )
            else
              Row(
                children: [
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).addToCart(subCat);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Added to cart")),
                      );
                      Navigator.pushNamed(context, '/checkout');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                    ),
                    child: const Text('Order', style: TextStyle(fontSize: 16)),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: AppColors.primary,
                      size: 39,
                    ),
                    onPressed: () {
                      Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).addToCart(subCat);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Added to cart")),
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
          ],
        ),
      ],
    );
  }

  // cart drawer
  /* void showCartSideDrawer(BuildContext context) {
    showGeneralDialog(
      barrierLabel: "Cart",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      context: context,
      pageBuilder: (ctx, anim1, anim2) {
        // Empty widget, real widget in transitionBuilder
        return const SizedBox.shrink();
      },
      transitionBuilder: (ctx, anim, secAnim, child) {
        final screenWidth = MediaQuery.of(ctx).size.width;
        final drawerWidth = screenWidth * 0.85; // 85% width for cart

        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                color: Colors.transparent, // Dims the background
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1, 0),
                  end: Offset(0, 0),
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: SizedBox(
                  width: drawerWidth,
                  height: MediaQuery.of(ctx).size.height,
                  child: CartScreen(), // Your cart widget
                ),
              ),
            ),
          ],
        );
      },
      transitionDuration: Duration(milliseconds: 350),
    );
  } */

  // Drawer widget
  Widget ProfileDrawer(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            accountName: Text(authProvider.userFullName ?? '...'),
            accountEmail: Text(authProvider.userEmail ?? '...'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, color: AppColors.primary, size: 40),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('My Profile'),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.pushNamed(context, '/profile_screen');
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('My Orders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/orders_screen');
            },
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Delivery Address'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/address_screen');
            },
          ),
          /* ListTile(
            leading: Icon(Icons.payment),
            title: Text('Payment Methods'),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.pushNamed(context, '/payment_screen');
            },
          ), */
          ListTile(
            leading: Icon(Icons.call),
            title: Text('contact Us'),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.pushNamed(context, '/contactUs_screen');
            },
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('Help & FAQs'),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.pushNamed(context, '/help_screen');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.pushNamed(context, '/settings_screen');
            },
          ),
          //const Spacer(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context); // close drawer first
              final success = await authProvider.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Logout successful' : 'Logout failed',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
              // Optionally: Navigate to login screen or root
              if (success) {
                final favProvider = Provider.of<FavoriteProvider>(
                  context,
                  listen: false,
                );
                await favProvider.clearFavorites();

                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
