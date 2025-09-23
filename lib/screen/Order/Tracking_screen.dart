import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_colors.dart';
import '../../widgets/navigation_bar.dart';
import '../../API/tracking_api.dart';
import '../../API/auth_api.dart';

class TrackingScreen extends StatefulWidget {
  //final String orderId;
  const TrackingScreen({super.key, /*required this.orderId*/});
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late Future<List<OrderTrackingStatus>> _trackingFuture;

  @override
  void initState() {
    super.initState();
    final authToken = Provider.of<AuthProvider>(context, listen: false).token ?? '';
    _trackingFuture = TrackingApi.fetchOrderTrackings(authToken);
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
            //fontWeight: FontWeight.bold,
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
          final currentStatus = data.isNotEmpty ? data.last : null;

          // Determine which step is active
          final statusOrder = [
            "placed",
            "confirmed",
            "processing",
            "delivered"
          ];
          final statusText = {
            "placed": "Order Placed",
            "confirmed": "Order Confirmed",
            "processing": "Order Processed",
            "delivered": "Ready to Deliver",
          };
          final statusSubtext = {
            "placed": "We have received your order.",
            "confirmed": "Your order has been confirmed.",
            "processing": "We are preparing your order.",
            "delivered": "Your order is ready for pickup.",
          };
          final forcedStatus = 'processing';
int activeStep = statusOrder.indexOf(forcedStatus);

             

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
                          Text("ESTIMATED TIME",
                              style: TextStyle(
                                fontSize: 16,
                          color: AppColors.text.withOpacity(0.7),
                              )),
                          Text(
                            currentStatus?.deliveryTime.isNotEmpty == true
                                ? currentStatus!.deliveryTime
                                : "--",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("ORDER NUMBER",
                              style: TextStyle(
                                fontSize: 16,
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                              )),
                          /*Text(
                            "#${widget.orderId}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),*/
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ESTIMATED DATE",
                           style: TextStyle(
                             fontSize: 16,
                          color: AppColors.text.withOpacity(0.7),
                           )),
                      Text(
                            currentStatus?.deliveryDate.isNotEmpty == true
                                ? currentStatus!.deliveryDate
                                : "--",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
  final List<String> statusOrder;
  final Map<String, String> statusText;
  final Map<String, String> statusSubtext;
  const _OrderTrackingStepper({
    required this.activeStep,
    required this.statusOrder,
    required this.statusText,
    required this.statusSubtext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(statusOrder.length, (idx) {
        final active = idx <= activeStep;
        final isLast = idx == statusOrder.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 2),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: active ? (idx == activeStep ? Colors.blue : Colors.green) : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 3,
                    height: 36,
                    color: active ? Colors.green : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText[statusOrder[idx]]!,
                      style: TextStyle(
                        color: idx == activeStep
                            ? Colors.blue
                            : (active ? Colors.black : Colors.grey),
                        fontWeight: idx == activeStep ? FontWeight.bold : FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      statusSubtext[statusOrder[idx]]!,
                      style: TextStyle(
                        color: active ? Colors.black54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
