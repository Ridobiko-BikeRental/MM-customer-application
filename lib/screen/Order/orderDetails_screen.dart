import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_colors.dart';

// Pass the full order map here when navigating to details (@required this.order)
class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailsScreen({super.key, required this.order});

  double get subtotal {
    final itemsRaw = order['items'];
    final List<dynamic> items = (itemsRaw is List) ? itemsRaw : [];
    double sum = 0;
    for (final item in items) {
      final product = item['subCategory'] ?? {};
      final price =
          (product['pricePerUnit'] is int || product['pricePerUnit'] is double)
          ? product['pricePerUnit'].toDouble()
          : 0.0;
      final quantity = (item['quantity'] is int || item['quantity'] is double)
          ? (item['quantity'] as num).toInt()
          : 1;
      sum += price * quantity;
    }
    return sum;
  }

double get taxAndFees => (subtotal * 0.15).roundToDouble(); // (15% tax for example)
  double get delivery =>
      subtotal == 0 ? 0 : 30; // You can adjust delivery pricing as per logic
  double get total => subtotal + taxAndFees + delivery;

  String get orderNo {
    final id = order['_id']?.toString() ?? '';
    return id.length > 7 ? id.substring(id.length - 7) : id;
  }

  String get dateFormatted {
    if (order['createdAt'] == null) return '';
    final dt = DateTime.parse(order['createdAt']).toLocal();
    return DateFormat('dd MMM, hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final itemsRaw = order['items'];
    final List<dynamic> items = (itemsRaw is List) ? itemsRaw : [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.buttonText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
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
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order number and date
            Text(
              "Order No. $orderNo",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateFormatted,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Divider(color: Color(0xFFF2E3DC), thickness: 1.2, height: 1),
            const SizedBox(height: 8),

            // Order items
            ...items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final product = item['subCategory'] ?? {};
              final name = product['name'] ?? '';
              final desc = product['description'] ?? '';
              final price = product['pricePerUnit']?.toDouble() ?? 0.0;
              final imageUrl = product['imageUrl'] ?? '';
              final quantity =
                  (item['quantity'] is int || item['quantity'] is double)
                  ? (item['quantity'] as num).toInt()
                  : 1;
              final itemDate = item['createdAt'] ?? order['createdAt'];
              final displayDate = itemDate != null
                  ? DateFormat(
                      'dd/MM/yy\nHH:mm',
                    ).format(DateTime.parse(itemDate).toLocal())
                  : '';
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: 58,
                            height: 58,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.fastfood,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.text,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '₹${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (displayDate.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            displayDate,
                            style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 13,
                              height: 1.25,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Text(
                            '-',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black45,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const Text(
                            '+',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (i != items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                        color: Color(0xFFF2E3DC),
                        thickness: 1,
                        height: 2,
                      ),
                    ),
                ],
              );
            }),

            const SizedBox(height: 18),

            // Bill section
            Divider(color: Color(0xFFF2E3DC), thickness: 1.2, height: 1),
            const SizedBox(height: 10),

            _billDetailRow("Subtotal", subtotal),
            const SizedBox(height: 6),
            _billDetailRow("Tax and Fees", taxAndFees),
            const SizedBox(height: 6),
            _billDetailRow("Delivery", delivery),
            const SizedBox(height: 8),
            Divider(color: Color(0xFFF2E3DC), thickness: 1, height: 2),
            const SizedBox(height: 8),
            _billDetailRow("Total", total, isTotal: true),
            const Spacer(),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  /* Place any reorder logic here */
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary, width: 1.2),
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 38, vertical: 12),
                ),
                child: const Text(
                  "Order Again",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context, 3),
    );
  }

  Widget _billDetailRow(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.text,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 19 : 16,
          ),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 19 : 16,
          ),
        ),
      ],
    );
  }

  Widget _bottomNav(BuildContext context, int selectedIndex) {
    return BottomNavigationBar(
      backgroundColor: AppColors.primary,
      selectedItemColor: AppColors.buttonText,
      unselectedItemColor: Colors.white54,
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        if (index == selectedIndex) return;
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home_screen');
            break;
          case 1:
            Navigator.pushNamed(context, '/mealbox_screen');
            break;
          case 2:
            Navigator.pushNamed(context, '/favourite');
            break;
          case 3:
            Navigator.pushNamed(context, '/history');
            break;
          case 4:
            Navigator.pushNamed(context, '/help');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Help'),
      ],
    );
  }
}
