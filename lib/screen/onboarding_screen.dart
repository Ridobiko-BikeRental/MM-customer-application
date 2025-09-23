import 'package:flutter/material.dart';
import 'package:yumquick/app_colors.dart';

// Sample images (unsplash, replace as needed)
const List<String> imageUrls = [
  "https://images.unsplash.com/photo-1504674900247-0877df9cc836", // pizza
  "https://images.unsplash.com/photo-1519864600265-abb23847ef2c", // dessert
  "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80", // coffee, adjust as desired
];

// Onboarding data
final List<_OnboardingPageData> _onboardingPages = [
  _OnboardingPageData(
    imageUrl: imageUrls[0],
    icon: Icons.fastfood,
    title: "Order For Food",
    desc: "Lorem ipsum dolor sit amet, conse ctetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna.",
  ),
  _OnboardingPageData(
    imageUrl: imageUrls[1],
    icon: Icons.credit_card,
    title: "Easy Payment",
    desc: "Lorem ipsum dolor sit amet, conse ctetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna.",
  ),
  _OnboardingPageData(
    imageUrl: imageUrls[2],
    icon: Icons.local_shipping,
    title: "Fast Delivery",
    desc: "Lorem ipsum dolor sit amet, conse ctetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna.",
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  void _nextPage() {
    if (_currentIndex < _onboardingPages.length - 1) {
      _controller.animateToPage(
        _currentIndex + 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _skip() {
    _controller.animateToPage(
      _onboardingPages.length - 1,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary, // Your yellow, or use your AppColors.secondary
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _onboardingPages.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final page = _onboardingPages[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top photo
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                          child: Image.network(
                            page.imageUrl,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                        child: Column(
                          children: [
                            if (index == 0 || index == 1)
                              Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: _skip,
                                  child: Text(
                                    "Skip >",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            Icon(page.icon,
                                size: 36, color: Colors.orange.shade700),
                            SizedBox(height: 16),
                            Text(
                              page.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.deepOrange,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              page.desc,
                              style: TextStyle(fontSize: 14, color: Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_onboardingPages.length, (dot) {
                                bool active = dot == _currentIndex;
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  width: active ? 18 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? Colors.deepOrange
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                onPressed: _nextPage,
                                child: Text(
                                  index == _onboardingPages.length - 1
                                      ? "Get Started"
                                      : "Next",
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Class
class _OnboardingPageData {
  final String imageUrl;
  final IconData icon;
  final String title;
  final String desc;

  const _OnboardingPageData({
    required this.imageUrl,
    required this.icon,
    required this.title,
    required this.desc,
  });
}
