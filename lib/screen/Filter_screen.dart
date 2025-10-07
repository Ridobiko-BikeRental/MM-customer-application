import 'package:flutter/material.dart';
import '../app_colors.dart';


// Hard-coded category icons (adjust as per your Home screen)
const filterCategories = [
  {'label': "All", 'icon': Icons.fastfood},
  {'label': "Daal", 'icon': Icons.restaurant},
  {'label': "Snacks", 'icon': Icons.eco},
  {'label': "Ice Cream", 'icon': Icons.icecream},
  {'label': "Rice", 'icon': Icons.local_drink},
];

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});
  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String selectedCategory = filterCategories[0]['label'].toString();
  double selectedRating = 0;
  double priceRange = 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Adjust to your app background
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true, 
          title: Text(
            "Filter",
            style: TextStyle(
                color: AppColors.buttonText, fontSize: 24),
          ),
        leading: BackButton(color: AppColors.buttonText),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories
            Text("Categories",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown[900])),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filterCategories.map((cat) {
                  final isSelected = cat['label'] == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0), // Add space between chips
                    child: GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat['label'].toString()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.secondary : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.grey.shade300,
                            width: 1.9,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(cat['icon'] as IconData,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.brown.shade200),
                            SizedBox(height: 3),
                            Text(
                              cat['label'].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected ? Colors.white : Colors.brown[300],
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            // Sort by
            Text("Sort by",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown[900])),
            SizedBox(height: 4),
            Row(
              children: List.generate(
                5,
                (index) => IconButton(
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.deepOrange,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedRating = index + 1.0;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ),
            ),
            SizedBox(height: 14),
            // Price slider
            Text("Price",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown[900])),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("₹0",
                    style: TextStyle(
                        color: Colors.brown[900], fontWeight: FontWeight.bold)),
                Expanded(
                  child: Slider(
                    value: priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 10,
                    label: priceRange.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        priceRange = value;
                      });
                    },
                    activeColor: Colors.deepOrange,
                  ),
                ),
                Text("₹1000+",
                    style: TextStyle(
                        color: Colors.brown[900], fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                 onPressed: () {
                  // Pass filters back to home screen on Apply
                  Navigator.pop(context, {
                    'category': selectedCategory,
                    'rating': selectedRating,
                    'price': priceRange,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text("Apply", style: TextStyle(fontSize: 18, color: AppColors.buttonText)),
              ),
            ),
            SizedBox(height: 16),
            if (selectedCategory != filterCategories[0]['label'].toString() || selectedRating > 0 || priceRange < 1000)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Reset filters to default values
                    setState(() {
                      selectedCategory = filterCategories[0]['label'].toString();
                      selectedRating = 0;
                      priceRange = 1000;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    "Reset Filters",
                    style: TextStyle(fontSize: 18, color: AppColors.buttonText),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
