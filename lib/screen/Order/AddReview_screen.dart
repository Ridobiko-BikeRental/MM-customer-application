/* import 'package:flutter/material.dart';
import '../../API/review_api.dart';
import '../../app_colors.dart';
import '../../models/subcategory.dart'; // <-- IMPORTANT: Make sure this import is present!

class ReviewScreen extends StatefulWidget {
  final dynamic order; // You can refine this type later if desired
  final SubCategory subCategory; // Properly typed, not dynamic

  const ReviewScreen({super.key, required this.order, required this.subCategory});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _controller.text.trim();
    if (_rating == 0 || comment.isEmpty) {
      setState(() =>
          _error = "Please provide a rating and write some feedback.");
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });

      print('ReviewScreen: Posting review for subCategoryId: ${widget.subCategory.id}');


    try {
      await ReviewApi.postReview(
        subCategoryId: widget.subCategory.id,
        rating: _rating,
        comment: comment,
      );
      if (!mounted) return;
      Navigator.pop(context, true); // Optionally return success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted!')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subCategory = widget.subCategory;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.buttonText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Leave a Review",
          style: TextStyle(
              color: AppColors.buttonText,
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                children: [
                  // Dish Image and Name
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      subCategory.imageUrl ?? '',
                      width: 108,
                      height: 94,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 108,
                        height: 94,
                        color: Colors.brown[100],
                        child: Icon(Icons.fastfood, size: 44, color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    subCategory.name ?? "...",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                        fontSize: 18),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "We'd love to know what you think of your dish.",
                    style: TextStyle(color: Colors.brown[600], fontSize: 13),
                  ),
                  SizedBox(height: 18),

                  // Star Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final isSelected = (index < _rating);
                      return IconButton(
                        icon: Icon(
                          isSelected ? Icons.star : Icons.star_border,
                          color: isSelected ? Colors.orange : Colors.grey,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Leave us your comment!",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                        fontSize: 15),
                  ),
                  SizedBox(height: 11),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF3D8),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      minLines: 2,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 15),
                        hintText: "Write Review…",
                        hintStyle: TextStyle(
                            color: Colors.brown[300], fontSize: 14),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    SizedBox(height: 10),
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    )
                  ],
                  SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                        ),
                        child: Text("Cancel", style: TextStyle(fontSize: 17, color: AppColors.primary)),
                      ),
                      SizedBox(width: 14),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(fontSize: 17),
                          padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                        ),
                        child: _submitting
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : Text("Submit"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 3),
    );
  }

  BottomNavigationBar _buildBottomNav(BuildContext context, int selectedIndex) {
    return BottomNavigationBar(
      backgroundColor: AppColors.primary,
      selectedItemColor: AppColors.buttonText,
      unselectedItemColor: Colors.white54,
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu), label: 'Menu'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Orders'),
        BottomNavigationBarItem(
            icon: Icon(Icons.support_agent), label: 'Help'),
      ],
    );
  }
} */
