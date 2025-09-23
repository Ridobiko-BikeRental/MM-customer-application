import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../API/orders_api.dart';
import '../app_colors.dart';
import 'Order/orderDetails_screen.dart';
import '../widgets/navigation_bar.dart';

// Helper: Calculate total price of the order
double calculateTotalAmountFromOrder(Map<String, dynamic> order) {
  final items = order['items'] as List<dynamic>? ?? [];
  double subtotal = 0.0;
  
  for (final item in items) {
    final product = item['subCategory'] ?? {};
    final price = (product['pricePerUnit'] is int || product['pricePerUnit'] is double)
        ? (product['pricePerUnit'] as num).toDouble()
        : 0.0;
    final quantity = (item['quantity'] is int || item['quantity'] is double)
        ? (item['quantity'] as num).toDouble()
        : 1.0;
    subtotal += price * quantity;
  }

  final tax = (subtotal * 0.15).round(); // 15% tax
  final delivery = subtotal > 0 ? 30.0 : 0.0; // flat 30 delivery charge if subtotal > 0

  final total = subtotal + tax + delivery;

  return total;
}


Map<String, dynamic> orderToCard(Map<String, dynamic> order) {
  final itemsList = order['items'] as List<dynamic>? ?? [];
  final amount = calculateTotalAmountFromOrder(order);
  final orderNo = (order['_id'] ?? '').toString();
  return {
    'orderNo': orderNo.length > 7
        ? orderNo.substring(orderNo.length - 7)
        : orderNo,
    'amount': '₹${amount.toStringAsFixed(2)}',
    'date': order['createdAt'] != null
        ? DateFormat("dd MMM, hh:mm a")
            .format(DateTime.parse(order['createdAt']).toLocal())
        : '',
    'items': itemsList.fold<int>(
      0,
      (c, e) => c + ((e['quantity'] ?? 1) as num).toInt(),
    ),
    'status':
        (order['status'] == 'confirmed' ||
                order['status'] == 'delivered' ||
                order['status'] == 'completed')
            ? 'Order delivered'
            : (order['status'] == 'cancelled' ? 'Order cancelled' : 'Order placed'),
    'rawStatus': order['status'],
  };
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final int _selectedIndex = 3; // Keep track of current selected tab index in your State
  List<Map<String, dynamic>> _allOrders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await OrdersApi.fetchOrders();
      orders?.sort(
        (a, b) => DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])),
      );
      setState(() {
        _allOrders = orders?.cast<Map<String, dynamic>>() ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hides back button
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'History',
          style: TextStyle(
            color: AppColors.buttonText,
            //fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : _allOrders.isEmpty
                    ? const Center(child: Text("No order history found."))
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: _allOrders.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: Color(0xFFF2E3DC),
                          thickness: 1.2,
                          height: 24,
                        ),
                        itemBuilder: (context, index) {
                          final order = _allOrders[index];
                          final cardData = orderToCard(order);
                          return OrderHistoryCard(
                            order: cardData,
                            fullOrder: order,
                          );
                        },
                      ),
      ),
      bottomNavigationBar: MainNavBar(currentIndex: 3),
    );
  }

}

class OrderHistoryCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Map<String, dynamic> fullOrder; // Pass full order for details screen
  const OrderHistoryCard({super.key, required this.order, required this.fullOrder});

  @override
  Widget build(BuildContext context) {
    // Status/Color/Icon logic
    IconData statusIcon;
    Color statusColor;

    if (order['rawStatus'] == 'delivered' ||
        order['rawStatus'] == 'confirmed' ||
        order['rawStatus'] == 'completed') {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
    } else if (order['rawStatus'] == 'cancelled') {
      statusIcon = Icons.cancel;
      statusColor = Colors.red;
    } else {
      statusIcon = Icons.check_circle;
      statusColor = AppColors.primary;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expanded - order details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order No. ${order['orderNo']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order['date'] ?? '',
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 17),
                  const SizedBox(width: 5),
                  Text(
                    order['status'] ?? '',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              order['amount'] ?? '',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${order['items']} item${order['items'] == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 90,
              height: 32,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.95),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsScreen(order: fullOrder),
                    ),
                  );
                },
                child: const Text(
                  'Details',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
