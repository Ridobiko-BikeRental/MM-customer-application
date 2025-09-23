import 'package:flutter/material.dart';
import 'package:yumquick/screen/Order/cancel_confirmed_screen.dart';
import '../../app_colors.dart';
import '../../API/orders_api.dart'; // Import your API here

class CancelOrderScreen extends StatefulWidget {
  final String orderId; // Pass orderId from previous screen

  const CancelOrderScreen({super.key, required this.orderId});

  @override
  State<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  final List<String> reasons = [
    "Ordered by mistake",
    "Found a better price elsewhere",
    "Delivery taking too long",
    "Changed my mind",
    "Forgot to add items",
    "Incorrect delivery address",
    "Other reason",
  ];

  int? selectedReasonIndex;
  final TextEditingController othersController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    othersController.dispose();
    super.dispose();
  }

  void _submitCancel() async {
    String? reason;
    if (selectedReasonIndex != null) {
      reason = reasons[selectedReasonIndex!];
    } else if (othersController.text.trim().isNotEmpty) {
      reason = othersController.text.trim();
    } else {
      // Show error if no reason provided
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select or enter a cancellation reason.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await OrdersApi.cancelOrder(
        orderId: widget.orderId,
        reason: reason,
      );
      setState(() => _isLoading = false);

      // Navigate to confirmed screen on success
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CancelConfirmedScreen()),
      ).then((_) {
        Navigator.pop(context, true); // Pop CancelOrderScreen with "true"
      });
    } catch (e) {
      setState(() => _isLoading = false);

      // Show error snackbar on failure
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to cancel order: $e')));
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
        title: Text(
          'Cancel Order',
          style: TextStyle(
            color: AppColors.buttonText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 0),
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                child: ListView(
                  children: [
                    Text(
                      'Please select a reason for cancelling your order:',
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    SizedBox(height: 18),
                    ...List.generate(
                      reasons.length,
                      (index) => Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              reasons[index],
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Radio<int>(
                              value: index,
                              groupValue: selectedReasonIndex,
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                setState(() {
                                  selectedReasonIndex = val;
                                  othersController.text = '';
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                selectedReasonIndex = index;
                                othersController.text = '';
                              });
                            },
                          ),
                          Divider(
                            height: 0,
                            thickness: 1,
                            color: Color(0xFFF2E3DC),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Others',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffFFF6C5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: othersController,
                        maxLines: 2,
                        onTap: () {
                          setState(() {
                            selectedReasonIndex = null;
                          });
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Others reason…',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.buttonText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitCancel,
                  child: _isLoading
                      ? CircularProgressIndicator(color: AppColors.buttonText)
                      : Text(
                          'Submit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context, 3),
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
        // Handle navigation as desired
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Help'),
      ],
    );
  }
}
