import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yumquick/widgets/navigation_bar.dart';
import '../../API/orders_api.dart';
import '../../app_colors.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});
  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  int selectedTab = 0; // 0 = Active, 1 = Completed, 2 = Cancelled
  List<dynamic> _allOrders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final orders = await OrdersApi.fetchOrders();
      orders?.sort((a, b) {
        final aDate = (a['createdAt'] != null && a['createdAt'].toString().isNotEmpty)
            ? DateTime.tryParse(a['createdAt'].toString())
            : null;
        final bDate = (b['createdAt'] != null && b['createdAt'].toString().isNotEmpty)
            ? DateTime.tryParse(b['createdAt'].toString())
            : null;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
      setState(() {
        _allOrders = orders ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  List<dynamic> get filteredOrders {
  if (selectedTab == 0) {
    // Active: pending or in-progress statuses
    return _allOrders.where((o) =>
      ((o['status'] ?? '').toString() == 'pending'
    )).toList();
  } else if (selectedTab == 1) {
    // Completed: delivered, confirmed, or completed
    return _allOrders.where((o) {
      final s = (o['status'] ?? '').toString();
      return s == 'confirmed' || s == 'delivered' || s == 'completed';
    }).toList();
  } else {
    // Cancelled
    return _allOrders.where((o) =>
      ((o['status'] ?? '').toString() == 'cancelled')
    ).toList();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.buttonText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: AppColors.buttonText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_errorMessage != null)
                  ? Center(child: Text('Error: $_errorMessage'))
                  : filteredOrders.isEmpty
                    ? const Center(child: Text('No orders found'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, idx) {
                          final order = filteredOrders[idx];
                          return OrderCard(
                            order: order,
                            onCancel: () => _loadOrders(),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavBar(currentIndex: 1),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 0, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _tabButton('Active', 0),
          const SizedBox(width: 16),
          _tabButton('Completed', 1),
          const SizedBox(width: 16),
          _tabButton('Cancelled', 2),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int idx) {
    final isSelected = selectedTab == idx;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFFFF3E1),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
  }


class OrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback? onCancel;
  const OrderCard({super.key, required this.order, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final List items = order['items'] ?? [];
    final orderId = (order['orderId'] ?? order['_id'] ?? '').toString();
    final status = (order['status'] ?? '').toString();
    final isPending = status == 'pending';
    final isCompleted = status == 'confirmed' || status == 'delivered' || status == 'completed';
    final isCancelled = status == 'cancelled';
    final orderDate = order['createdAt'] != null && order['createdAt'].toString().isNotEmpty
    ? DateFormat('dd MMM, h:mma').format(DateTime.parse(order['createdAt']).toLocal())
    : '--';
final deliveryDateRaw = order['deliveryDate'];
final deliveryDate = deliveryDateRaw != null && deliveryDateRaw.toString().isNotEmpty
    ? DateFormat('dd MMM, h:mma').format(DateTime.parse(deliveryDateRaw.toString()).toLocal())
    : '--';



    double total = 0.0;
    for (final item in items) {
      final subCategory = item['subCategory'] ?? {};
      final price = (subCategory['pricePerUnit'] is num)
          ? (subCategory['pricePerUnit']).toDouble()
          : 0.0;
      final qty = (item['quantity'] is int ? item['quantity'] : 1);
      total += price * qty;
    }
    final totalDisplay = '₹${total.toStringAsFixed(2)}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID and time
          Row(
            children: [
              Text(
                'Order ID: $orderId',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                orderDate,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Items List
          ...items.map((item) {
            final subCategory = item['subCategory'] ?? {};
            final name = (subCategory['name'] ?? '').toString();
            final price = (subCategory['pricePerUnit'] ?? '').toString();
            final qty = item['quantity'] ?? 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  Icon(Icons.check_box, color: Colors.green, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$qty x $name',
                      style: const TextStyle(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('₹${int.tryParse(price) != null ? (int.parse(price) * qty).toString() : price}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
                ],
              ),
            );
          }),
          const Divider(height: 18, thickness: 0.6),
          Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isCompleted
              ? 'Delivered'
              : isPending
                ? 'Pending'
                : isCancelled
                  ? 'Cancelled'
                  : status,
          style: TextStyle(
            color: isCompleted
                ? Colors.green
                : isPending
                  ? Colors.orange
                  : isCancelled
                    ? Colors.red
                    : Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Order placed: $orderDate',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 3),
        Text(
          'Order delivery: $deliveryDate',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    ),
    Text(
      totalDisplay,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ],
),
          const SizedBox(height: 14),
          // Buttons
          Row(
            children: [
              if (isPending)
                ...[
                  _OrderButton(
                    label: 'Cancel Order',
                    onPressed: () async {
                      final bool? didCancel = await Navigator.pushNamed(
                            context,
                            '/CancelOrder',
                            arguments: {'orderId': order['id'] ?? order['_id']},
                          ) as bool?;
                      if (didCancel == true && onCancel != null) onCancel!();
                    },
                  ),
                  const SizedBox(width: 10),
                  _OrderButton(
                    label: 'Track',
                    onPressed: () {
                      final orderIdVal = order['id'] ?? order['_id'];
                      if (orderIdVal != null && orderIdVal.toString().isNotEmpty) {
                        Navigator.pushNamed(
                          context,
                          '/tracking',
                          arguments: orderIdVal,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order ID not available!')),
                        );
                      }
                    },
                  ),
                ],
              if (isCompleted)
                ...[
                  _OrderButton(
                    label: 'Leave a review',
                    onPressed: () {
                      // Implement review navigation as needed
                    },
                  ),
                  const SizedBox(width: 10),
                  _OrderButton(
                    label: 'Order Again',
                    onPressed: () {
                      // Implement order again logic as needed
                    },
                  ),
                ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _OrderButton({required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: const Size(0, 32),
      ),
      onPressed: onPressed,
      child: Text(
        label, style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
