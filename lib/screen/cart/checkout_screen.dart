import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yumquick/API/auth_api.dart';
import 'package:yumquick/API/orders_api.dart';
import 'package:yumquick/screen/Order/order_confirmed_screen.dart';
import '../../app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../API/address_api.dart';
import '../../models/subcategory.dart';
import '../../models/MealBox_model.dart';

// Provider to hold the selected address (same AddressModel type)
class SelectedAddressProvider extends ChangeNotifier {
  AddressModel? _selectedAddress;

  AddressModel? get selectedAddress => _selectedAddress;

  void setAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void clearAddress() {
    _selectedAddress = null;
    notifyListeners();
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool showAddressList = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      final selectedAddressProvider = Provider.of<SelectedAddressProvider>(context, listen: false);

      await addressProvider.fetchAddresses();
      if (!mounted) return;

      if (addressProvider.addresses != null && addressProvider.addresses!.isNotEmpty) {
        // Initialize selected address in provider with first address
        selectedAddressProvider.setAddress(addressProvider.addresses!.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);
    final selectedAddressProvider = Provider.of<SelectedAddressProvider>(context);
    //final vendor = Provider.of<CategoryProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false);

    final selectedAddress = selectedAddressProvider.selectedAddress;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          "Checkout",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shipping Address title
              Text(
                "Shipping Address",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),

              if (addressProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (addressProvider.addresses == null || addressProvider.addresses!.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_off, color: AppColors.primary),
                          const SizedBox(width: 10),
                          const Expanded(child: Text("No address found.")),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        icon: const Icon(Icons.add_location_alt),
                        label: const Text("Add Address"),
                        onPressed: () {
                          Navigator.pushNamed(context, '/updateaddress');
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showAddressList = !showAddressList;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary, width: 1.3),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _addressToString(selectedAddress ?? addressProvider.addresses!.first),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              showAddressList ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (showAddressList)
                      Container(
                        margin: const EdgeInsets.only(top: 6, bottom: 6),
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 2)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...addressProvider.addresses!
                                .where((a) => a != selectedAddress)
                                .map(
                                  (address) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(Icons.location_on, color: AppColors.primary),
                                    title: Text(
                                      _addressToString(address),
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    onTap: () {
                                      selectedAddressProvider.setAddress(address);
                                      setState(() {
                                        showAddressList = false;
                                      });
                                    },
                                  ),
                                ),
                            Center(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                                icon: const Icon(Icons.add_location_alt),
                                label: const Text("Add Address"),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/updateaddress');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 22),

              // Order Summary Header
              Text(
                "Order Summary",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              // Cart Items List or Empty Text
              Expanded(
                child: cart.items.isEmpty
                    ? const Center(
                        child: Text(
                          "Cart is empty",
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (_, i) {
                          final item = cart.items[i];
                          return CheckoutCartTile(
                            cartItem: item,
                            onIncrement: () => cart.incrementQuantity(item.product.id),
                            onDecrement: () => cart.decrementQuantity(item.product.id),
                            onRemove: () => cart.removeFromCart(item.product.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      // Bill Section and Place Order Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BillSection(
              subtotal: cart.subtotal,
              taxAndFees: cart.taxAndFees,
              delivery: cart.delivery,
              total: cart.total,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: cart.isEmpty || selectedAddress == null
                    ? null
                    : () async {
                        try {
                          final items = cart.items.map((item) {
                            if (item.product is SubCategory) {
                              final p = item.product as SubCategory;
                              return {
                                "category": p.categoryId,
                                "subCategory": p.id,
                                "quantity": item.quantity,
                              };
                            } else if (item.product is MealBox) {
                              final p = item.product as MealBox;
                              return {
                                "mealBox": p.id,
                                "quantity": item.quantity,
                              };
                            }
                            throw Exception("Unknown product type");
                          }).toList();

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );

                          final vendorId = cart.items.first.vendorId;
                          final response = await OrdersApi.placeOrder(
                            //customerName: user.userFullName,
                            //customerEmail: user.userEmail,
                            items: items,
                            vendorId: vendorId,
                          );
                          log("vendor_id (local): $vendorId");

                          
                          Navigator.pop(context);
                          cart.clearCart();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const OrderConfirmedScreen()),
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order failed: $e')));
                        }
                      },
                child: const Text(
                  "Place Order",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _addressToString(AddressModel address) {
    return "${address.addressLine}, ${address.city}, ${address.state}";
  }
}


class CheckoutCartTile extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CheckoutCartTile({
    super.key,
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (cartItem.imageUrl.isNotEmpty)
                ? Image.network(
                    cartItem.imageUrl,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 50,
                    height: 50,
                    color: Colors.yellow.shade100,
                    child: Icon(
                      Icons.fastfood,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.name, // <<< USE GETTER
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  "₹${cartItem.pricePerUnit.toStringAsFixed(2)}    ${cartItem.quantity} item${cartItem.quantity > 1 ? 's' : ''}",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    TextButton(
                      onPressed: onRemove,
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.primary,
                        minimumSize: Size(1, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Text("Cancel Order"),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: onDecrement,
                    ),
                    Text(
                      "${cartItem.quantity}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: onIncrement,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.shade300,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class BillSection extends StatelessWidget {
  final int subtotal;
  final int taxAndFees;
  final int delivery;
  final int total;

  const BillSection({
    super.key,
    required this.subtotal,
    required this.taxAndFees,
    required this.delivery,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _billRow("Subtotal", subtotal),
        SizedBox(height: 4),
        _billRow("Tax and Fees", taxAndFees),
        SizedBox(height: 4),
        _billRow("Delivery", delivery),
        SizedBox(height: 10),
        Divider(color: Colors.yellow.shade100, thickness: 1),
        _billRow("Total", total, isTotal: true),
      ],
    );
  }

  Widget _billRow(String label, int price, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.orange.shade700 : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Text(
            "₹${price.toString()}",
            style: TextStyle(
              color: isTotal ? Colors.orange.shade700 : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
