import 'package:flutter/material.dart';
import '../../app_colors.dart';

class OrderPlacedScreen extends StatelessWidget {
  final String orderId;
  final bool isMealBox;
  final String customerOrderId;

  const OrderPlacedScreen({
    super.key,
    required this.orderId,
    this.isMealBox = false,
    required this.customerOrderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Center(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              const SizedBox(height: 70),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 8,
                        ),
                      ),
                      child: Center(
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 35,
                          child: Icon(
                            Icons.check_circle,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      "Order Placed",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.brown[900],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Order ID: $customerOrderId",
                      style: TextStyle(
                        fontSize: 17,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 26),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/tracking',
                          arguments: orderId,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        "Track Order",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.only(bottom: 26.0),
                child: Text(
                  "If you have any questions, please reach out\n directly to our customer support",
                  style: TextStyle(fontSize: 13, color: Colors.brown[900]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
