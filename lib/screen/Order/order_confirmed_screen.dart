import 'dart:async';
import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../API/tracking_api.dart';
import '../../API/auth_api.dart';
import 'package:provider/provider.dart';

class OrderConfirmedScreen extends StatefulWidget {
  const OrderConfirmedScreen({super.key});

  @override
  State<OrderConfirmedScreen> createState() => _OrderConfirmedScreenState();
}

class _OrderConfirmedScreenState extends State<OrderConfirmedScreen> {
    late Future<List<OrderTrackingStatus>> _trackingFuture;
  Timer? _refreshTimer;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (!_isConfirmed) {
        await _fetchStatus();
      }
    });
  }

  Future<void> _fetchStatus() async {
    final authToken = Provider.of<AuthProvider>(context, listen: false).token ?? '';
    setState(() {
       _trackingFuture = TrackingApi.fetchOrderTrackings(authToken);
    });
    // Optionally: check for direct state update after, if needed
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: FutureBuilder<List<OrderTrackingStatus>>(
          future: _trackingFuture,
          builder: (context, snapshot) {
            final List<OrderTrackingStatus> orders = snapshot.data ?? [];
            final latestStatus = orders.isNotEmpty ? orders.last.status.toLowerCase() : '';
            _isConfirmed = latestStatus == 'confirmed';

            return RefreshIndicator(
              onRefresh: _fetchStatus,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 70),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Outer circle with tick or pending icon
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
                                _isConfirmed ? Icons.check_circle : Icons.hourglass_top,
                                size: 60,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          _isConfirmed ? "Order Confirmed!" : "Order Pending",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            color: Colors.brown[900],
                          ),
                        ),
                        const SizedBox(height: 13),
                        Text(
                          _isConfirmed
                            ? "Your order has been confirmed by the vendor."
                            : "Your order has been placed\nand is waiting for confirmation.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.brown[900]),
                        ),
                        const SizedBox(height: 14),
                        /* if (_isConfirmed && orders.isNotEmpty)
                          Text(
                            "Delivery by ${orders.last.deliveryDate}  ${orders.last.deliveryTime}",
                            style: TextStyle(fontSize: 15, color: Colors.brown[900]),
                          ), */
                        const SizedBox(height: 10),
                        if (_isConfirmed)
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/tracking');
                            },
                            child: Text(
                              "Track my order",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
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
            );
          },
        ),
      ),
    );
  }
}

