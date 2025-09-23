import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import '../app_colors.dart';

// List all your SVGs except the 'All' icon
const List<String> categoryIconAssets = [
  'assets/category_icon/10_20250818_175503_0000.png',
  'assets/category_icon/all.png',
  'assets/category_icon/12_20250818_175503_0002.png',
  'assets/category_icon/13_20250818_175503_0003.png',
  'assets/category_icon/14_20250818_175503_0004.png',
  'assets/category_icon/15_20250818_175503_0005.png',
  'assets/category_icon/16_20250818_175503_0006.png',
  'assets/category_icon/17_20250818_175503_0007.png',
];

// Returns a consistent icon for a category
String getIconForCategory(String categoryName) {
  if (categoryName.toLowerCase() == 'all') {
    return 'assets/category_icon/17_20250818_175503_0007.png'; // Path to your 'All' icon asset
  }
  final idx = categoryName.hashCode.abs() % categoryIconAssets.length;
  return categoryIconAssets[idx];
}

class CategoryChip extends StatelessWidget {
  final String iconAsset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    required this.iconAsset,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = selected ? AppColors.accent : Colors.white;
    final borderColor = selected ? AppColors.accent : Colors.grey.shade300;
    final txtColor = selected ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        padding: EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.accent.withOpacity(0.07), blurRadius: 6)]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconAsset,
              width: 34,
              height: 50,
              fit: BoxFit.cover,
              color: selected ? Colors.black : null,  // optional if you want to tint
            ),
            SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: txtColor,
                fontSize: 13,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryChipsRow extends StatelessWidget {
  final List<dynamic> categories; // e.g., provider.chipCategories
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryChipsRow({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CategoryChip(
            iconAsset: getIconForCategory('All'),
            label: 'All',
            selected: selectedCategory == 'All',
            onTap: () => onSelected('All'),
          ),
          SizedBox(width: 12),
          ...categories.map(
            (cat) => Padding(
              padding: EdgeInsets.only(right: 12),
              child: CategoryChip(
                iconAsset: getIconForCategory(cat.name.trim()),
                label: cat.name.trim(),
                selected: selectedCategory == cat.name.trim(),
                onTap: () => onSelected(cat.name.trim()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
