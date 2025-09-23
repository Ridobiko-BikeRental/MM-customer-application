import 'package:flutter/material.dart';
import '../../app_colors.dart';

class CancelConfirmedScreen extends StatelessWidget {
  const CancelConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Outer circle with tick
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
                          child: Icon(Icons.check_circle, size: 60, color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: 28),
                    Text(
                      "Order Cancelled!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.brown[900],
                      ),
                    ),
                    SizedBox(height: 13),
                    Text(
                      "Your order has been Cancelled\nsuccesfully",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.brown[900]),
                    ),
                    SizedBox(height: 14),
                    /* Text(
                      "Delivery by Thu, 29th, 4:00 PM", // you can make this dynamic
                      style: TextStyle(fontSize: 15, color: Colors.brown[900]),
                    ), */
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
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
      // bottomNavigationBar: ... (add your navigation if needed)
    );
  }
}
