import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_colors.dart';
import '../../widgets/navigation_bar.dart';
import '../../API/tracking_api.dart';
import '../../API/auth_api.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class TrackingScreen extends StatefulWidget {
  final String orderId;
  final bool isMealBox;

  const TrackingScreen({
    super.key,
    required this.orderId,
    this.isMealBox = false,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late Future<List<OrderTrackingStatus>> _trackingFuture;
  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _connectSocket();
  }

    void _connectSocket() {
    _socket = IO.io('https://mm-food-backend.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      print('Socket connected');
      // Join the correct room for real-time tracking
      if (widget.isMealBox) {
        log('Joining mealbox order room for orderId: ${widget.orderId}');
        _socket!.emit('joinMealBoxOrderRoom', widget.orderId);
      } else {
        log('Joining order room for orderId: ${widget.orderId}');
        _socket!.emit('joinOrderRoom', widget.orderId);
      }
    });

    // Listen for mealbox order tracking updates
    _socket!.on('mealboxOrderTrackingUpdated', (data) {
      log('Received mealboxOrderTrackingUpdated: $data');
      if (widget.isMealBox &&
          data != null &&
          data['order'] != null &&
          data['order']['_id'] == widget.orderId) {
        if (mounted) _fetchStatus();
      }
    });

    // Listen for normal order tracking updates
    _socket!.on('orderTrackingUpdated', (data) {
      print('Received orderTrackingUpdated: $data');
      if (!widget.isMealBox &&
          data != null &&
          data['order'] != null &&
          data['order']['_id'] == widget.orderId) {
        if (mounted) _fetchStatus();
      }
    });

    _socket!.onDisconnect((_) => print('Socket disconnected'));
  }

  @override
  void dispose() {
    _socket?.off('mealboxOrderTrackingUpdated');
    _socket?.off('orderTrackingUpdated');
    _socket?.dispose();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    final authToken =
        Provider.of<AuthProvider>(context, listen: false).token ?? '';

    setState(() {
      if (widget.isMealBox) {
        _trackingFuture = TrackingApi.fetchMealBoxTrackingById(
          authToken,
          widget.orderId,
        );
      } else {
        _trackingFuture = TrackingApi.fetchOrderTrackingById(
          authToken,
          widget.orderId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.buttonText),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        centerTitle: true,
        title: Text(
          'Track Order',
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 24,
          ),
        ),
      ),
      body: FutureBuilder<List<OrderTrackingStatus>>(
        future: _trackingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load tracking info.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          final data = snapshot.data ?? [];
          final currentStatus = data.isNotEmpty ? data.first : null;

          final statusOrder = [
            "placed",
            "pending",
            "confirmed",
            "processing",
            "delivered"
          ];

          final statusText = {
             "placed": "Order Placed",
            "pending": "Order Pending",
            "confirmed": "Order Confirmed",
            "processing": "Order Processed",
            "delivered": "delivered",
          };
          final statusSubtext = {
            "pending": "Your order is pending confirmation.",
            "placed": "We have received your order.",
            "confirmed": "Your order has been confirmed.",
            "processing": "We are preparing your order.",
            "delivered": "Your order is ready for pickup.",
          };

          int statusIndex = currentStatus != null
              ? statusOrder.indexOf(currentStatus.status.toLowerCase())
              : 0;

          int activeStep = statusIndex;
          if (statusOrder[statusIndex] == "confirmed") {
            activeStep = 3; // processing
          }
          if (statusOrder[statusIndex] == "delivered") {
            activeStep = 4;
          }

          String? deliveryDate = currentStatus?.deliveryDate;
          String? deliveryTime = currentStatus?.deliveryTime;
          bool isDeliveredToday = false;
          if (deliveryDate != null && deliveryDate.isNotEmpty) {
            final today = DateTime.now();
            final deliveredDateParsed = DateTime.tryParse(deliveryDate);
            if (deliveredDateParsed != null &&
                deliveredDateParsed.year == today.year &&
                deliveredDateParsed.month == today.month &&
                deliveredDateParsed.day == today.day) {
              isDeliveredToday = true;
            }
          }

          String? orderNumber = currentStatus?.orderId ?? widget.orderId;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Info (ETA + Order ID)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDeliveredToday ? "ARRIVING TODAY" : "ESTIMATED TIME",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            isDeliveredToday
                                ? ""
                                : (deliveryTime?.isNotEmpty == true ? deliveryTime! : "--"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "ORDER NUMBER",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            orderNumber,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (!isDeliveredToday)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ESTIMATED DATE",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          deliveryDate?.isNotEmpty == true
                              ? deliveryDate!
                              : "--",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  // Stepper timeline
                  _OrderTrackingStepper(
                    activeStep: activeStep,
                    statusOrder: statusOrder,
                    statusText: statusText,
                    statusSubtext: statusSubtext,
                    realStatusIndex: statusIndex,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: MainNavBar(currentIndex: 1),
    );
  }
}

class _OrderTrackingStepper extends StatelessWidget {
  final int activeStep;
  final int realStatusIndex;
  final List<String> statusOrder;
  final Map<String, String> statusText;
  final Map<String, String> statusSubtext;

  const _OrderTrackingStepper({
    required this.activeStep,
    required this.statusOrder,
    required this.statusText,
    required this.statusSubtext,
    required this.realStatusIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        statusOrder.length,
        (idx) {
          final bool isCompleted = idx < activeStep;
          final bool isActive = idx == activeStep;
          final bool isLast = idx == statusOrder.length - 1;
          Color nodeColor = isCompleted
              ? Colors.green
              : (isActive ? Colors.blue : Colors.grey[300]!);
          Color lineColor = isCompleted
              ? Colors.green
              : (isActive ? Colors.blue : Colors.grey[300]!);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 2),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  if (!isLast)
                    Container(
                      width: 3,
                      height: 38,
                      color: lineColor,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText[statusOrder[idx]] ?? '',
                        style: TextStyle(
                          color: isActive
                              ? Colors.blue
                              : (isCompleted ? Colors.green[900] : Colors.grey),
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusSubtext[statusOrder[idx]] ?? '',
                        style: TextStyle(
                          color: isCompleted || isActive
                              ? Colors.black54
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
