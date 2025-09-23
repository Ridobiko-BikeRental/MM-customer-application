import 'dart:async';
import 'package:flutter/material.dart';

class MealBoxImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;
  final BorderRadiusGeometry borderRadius;

  const MealBoxImageCarousel({
    super.key,
    required this.images,
    this.height = 110,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<MealBoxImageCarousel> createState() => _MealBoxImageCarouselState();
}

class _MealBoxImageCarouselState extends State<MealBoxImageCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (!mounted) return;
        _currentPage = (_currentPage + 1) % widget.images.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: widget.borderRadius,
                child: Image.network(
                  widget.images[index],
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
        // Dots
        if (widget.images.length > 1)
          Positioned(
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 10 : 8,
                  height: _currentPage == index ? 10 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
