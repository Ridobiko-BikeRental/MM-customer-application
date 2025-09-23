import 'package:flutter/material.dart';
import '../../API/orders_api.dart';
import '../../app_colors.dart';
import 'AddReview_screen.dart';
import '../../models/subcategory.dart';

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final orders = await OrdersApi.fetchOrders();
      orders?.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
      setState(() {
        _allOrders = orders ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<dynamic> get filteredOrders {
    String status;
    if (selectedTab == 0) {
      status = 'pending';
    } else if (selectedTab == 1) status = 'confirmed';
    else status = 'cancelled';
    return _allOrders.where((o) => o['status'] == status).toList();
  }

  // Flattened list of maps with each individual item for every order
  List<Map<String, dynamic>> get flattenedOrderItems {
    final List<Map<String, dynamic>> flat = [];
    for (final order in filteredOrders) {
      final List items = order['items'] ?? [];
      for (final item in items) {
        flat.add({
          'order': order,
          'item': item,
        });
      }
    }
    return flat;
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
          Container(
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
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_errorMessage != null)
                    ? Center(child: Text('Error: $_errorMessage'))
                    : flattenedOrderItems.isEmpty
                        ? const Center(child: Text('No orders found'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemCount: flattenedOrderItems.length,
                            itemBuilder: (context, index) {
                              final entry = flattenedOrderItems[index];
                              final order = entry['order'];
                              final item = entry['item'];
                              return _orderCard(order, item);
                            },
                          ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, 3),
    );
  }

  Widget _tabButton(String label, int idx) {
    final isSelected = idx == selectedTab;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = idx;
        });
      },
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

  Widget _orderCard(dynamic order, dynamic item) {
    final subCategory = item['subCategory'];
    final imageUrl = subCategory != null && subCategory['imageUrl'] != null
        ? subCategory['imageUrl']
        : 'https://via.placeholder.com/150';
    final quantity = item['quantity'] ?? 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              height: 70,
              width: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 70,
                  width: 70,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 36,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and price row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        subCategory != null && subCategory['name'] != null
                            ? subCategory['name']
                            : 'No name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      subCategory != null && subCategory['pricePerUnit'] != null
                          ? '₹${subCategory['pricePerUnit']}'
                          : '',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      order['createdAt'] != null
                          ? formatDateTimeSimple(order['createdAt'])
                          : '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$quantity item${quantity > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                // Buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (order['status'] == 'confirmed') ...[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: () {
                          final List items = order['items'] ?? [];
                          final subCategoryObj = items.isNotEmpty
                              ? SubCategory.fromJson(items[0]['subCategory'])
                              : null;
                          if (subCategoryObj != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewScreen(
                                  order: order,
                                  subCategory: subCategoryObj,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Leave a review',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: () {
                          // Implement Order Again logic here
                        },
                        child: const Text(
                          'Order Again',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                    if (order['status'] == 'pending') ...[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: () async {
                          final bool? didCancel = await Navigator.pushNamed(
                            context,
                            '/CancelOrder',
                            arguments: {'orderId': order['_id']},
                          ) as bool?;
                          if (didCancel == true) _loadOrders();
                        },
                        child: const Text(
                          'Cancel Order',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: () {
                          // Implement Track Driver logic here
                        },
                        child: const Text(
                          'Track Driver',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
          ),
          ),
        ],
        ),
      );
  }

  String formatDateTimeSimple(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      String day = dateTime.day.toString().padLeft(2, '0');
      String month = months[dateTime.month];
      int hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      String period = 'am';
      int displayHour = hour;
      if (hour == 0) {
        displayHour = 12;
      } else if (hour == 12) {
        period = 'pm';
        displayHour = 12;
      } else if (hour > 12) {
        displayHour = hour - 12;
        period = 'pm';
      }
      return '$day $month, ${displayHour.toString().padLeft(2, '0')}:$minute $period';
    } catch (e) {
      return dateTimeString;
    }
  }

  Widget _buildBottomNav(BuildContext context, int selectedIndex) {
    return BottomNavigationBar(
      backgroundColor: AppColors.primary,
      selectedItemColor: AppColors.buttonText,
      unselectedItemColor: Colors.white54,
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        // Implement navigation logic here
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Help'),
      ],
    );
  }
}
