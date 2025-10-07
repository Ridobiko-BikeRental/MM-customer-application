import 'package:flutter/material.dart';
import 'package:yumquick/API/auth_api.dart';
import 'package:provider/provider.dart';
import 'package:yumquick/API/orders_api.dart';
import 'package:yumquick/screen/Order/order_confirmed_screen.dart';
import '../../app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../API/address_api.dart';
import '../../models/subcategory.dart';
import '../../models/MealBox_model.dart';
import '../../API/mealbox_api.dart';

// Provider for selected address
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
      final addressProvider = Provider.of<AddressProvider>(
        context,
        listen: false,
      );
      final selectedAddressProvider = Provider.of<SelectedAddressProvider>(
        context,
        listen: false,
      );
      await addressProvider.fetchAddresses();
      if (!mounted) return;
      if (addressProvider.addresses != null &&
          addressProvider.addresses!.isNotEmpty) {
        selectedAddressProvider.setAddress(addressProvider.addresses!.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);
    final selectedAddressProvider = Provider.of<SelectedAddressProvider>(
      context,
    );
    final selectedAddress = selectedAddressProvider.selectedAddress;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          "Cart",
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
              // Shipping Address
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
              else if (addressProvider.addresses == null ||
                  addressProvider.addresses!.isEmpty)
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
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
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade100,
                          borderRadius: BorderRadius.circular(14),
                          //border: Border.all(color: AppColors.primary, width: 1.3),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _addressToString(
                                  selectedAddress ??
                                      addressProvider.addresses!.first,
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              showAddressList
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (showAddressList)
                      Container(
                        margin: const EdgeInsets.only(top: 6, bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 2),
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
                                    leading: Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                    ),
                                    title: Text(
                                      _addressToString(address),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onTap: () {
                                      selectedAddressProvider.setAddress(
                                        address,
                                      );
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                icon: const Icon(Icons.add_location_alt),
                                label: const Text("Add Address"),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/updateaddress',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 22),
              // Order Summary
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
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              itemCount: cart.items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (_, i) {
                                final item = cart.items[i];
                                return ModernCartTile(
                                  cartItem: item,
                                  onIncrement: () => cart.incrementQuantityBy(
                                    item.product.id,
                                    item.product.minQty,
                                  ),
                                  onDecrement: () => cart.decrementQuantityBy(
                                    item.product.id,
                                    item.product.minQty,
                                  ),
                                  onRemove: () =>
                                      cart.removeFromCart(item.product.id),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // ADD THIS ROW HERE
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow.shade100,
                                    foregroundColor: Colors.deepOrange,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/home_screen',
                                    );
                                  },
                                  child: const Text(
                                    "Add More Items",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow.shade100,
                                    foregroundColor: Colors.deepOrange,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  onPressed:
                                      cart.isEmpty || selectedAddress == null
                                      ? null
                                      : () async {
                                          int minDeliveryDays = 0;
                                          int maxDeliveryDays = 0;
                                          int minPrepareOrderDays = 0;
                                          int maxPrepareOrderDays = 0;
                                          for (var item in cart.items) {
                                            if (item.product is SubCategory) {
                                              final subCat =
                                                  item.product as SubCategory;
                                              if (subCat.minDeliveryDays >
                                                  minDeliveryDays)
                                                minDeliveryDays =
                                                    subCat.minDeliveryDays;
                                              if (subCat.maxDeliveryDays >
                                                  maxDeliveryDays)
                                                maxDeliveryDays =
                                                    subCat.maxDeliveryDays;
                                            } else if (item.product
                                                is MealBox) {
                                              final mealBox =
                                                  item.product as MealBox;
                                              if (mealBox.minPrepareOrderDays !=
                                                      null &&
                                                  mealBox.minPrepareOrderDays! >
                                                      minPrepareOrderDays)
                                                minPrepareOrderDays = mealBox
                                                    .minPrepareOrderDays!;
                                              if (mealBox.maxPrepareOrderDays !=
                                                      null &&
                                                  mealBox.maxPrepareOrderDays! >
                                                      maxPrepareOrderDays)
                                                maxPrepareOrderDays = mealBox
                                                    .maxPrepareOrderDays!;
                                            }
                                          }
                                          final result =
                                              await Navigator.pushNamed(
                                                context,
                                                '/slot_booking',
                                                arguments: {
                                                  'cartItems': cart.items,
                                                },
                                              );
                                          if (result != null) {
                                            // Handle slot date/time
                                            print(
                                              "Slot booking selected: $result",
                                            );
                                          }
                                        },
                                  child: const Text(
                                    "Book Slot",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: cart.isEmpty || selectedAddress == null
                    ? null
                    : () async {
                        try {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          String orderId;
                          String customerOrderId;
                          bool isMealBox = false;
                          if (cart.items.length == 1 &&
                              cart.items.first.product is MealBox) {
                            final mb = cart.items.first.product as MealBox;
                            final result = await MealBoxApi.placeMealBoxOrder(
                              mealBoxId: mb.id.toString(), // Ensure String type
                              quantity: mb.minQty, // Remains int
                              vendorId: mb.vendorId
                                  .toString(), // Ensure String type
                              // deliveryDays: ..., // Add if API expects this
                            );

                            orderId = result['orderId'];
                            customerOrderId =
                                result['orderId']; // Assign here as well
                            isMealBox = true;
                            print("MealBox order placed: $result");
                          } else {
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

                            final vendorId = cart.items.first.vendorId;
                            final response = await OrdersApi.placeOrder(
                              items: items,
                              vendorId: vendorId,
                            );
                            print("Placed food order result: $response");
                            orderId = response['orderId'];
                            customerOrderId = response['customerOrderId'];
                            isMealBox = false;
                          }

                          Navigator.pop(context);
                          cart.clearCart();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderPlacedScreen(
                                orderId: orderId,
                                customerOrderId: customerOrderId,
                              ),
                            ),
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Order failed: $e')),
                          );
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

// Modern order summary tile as per your new design!
class ModernCartTile extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const ModernCartTile({
    super.key,
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final minQty =
        cartItem.product.minQty; // works for both MealBox & SubCategory
    final int displayQuantity = cartItem.quantity;
    final int pricePerUnit = cartItem.pricePerUnit;
    final int totalPrice = displayQuantity * pricePerUnit;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Image and info
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (cartItem.imageUrl.isNotEmpty)
                  ? Image.network(
                      cartItem.imageUrl,
                      height: 55,
                      width: 55,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 55,
                      height: 55,
                      color: Colors.yellow.shade100,
                      child: Icon(
                        Icons.fastfood,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
            ),
            SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "MinQty: $minQty",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "₹$pricePerUnit per unit",
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            // Right: increment, decrement, total price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _IncDecButton(
                      icon: Icons.remove,
                      onTap: () => onDecrement(),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        '$displayQuantity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    _IncDecButton(icon: Icons.add, onTap: () => onIncrement()),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  "₹${totalPrice}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Little custom circle inc/dec button
class _IncDecButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IncDecButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Icon(icon, color: AppColors.primary, size: 13),
        padding: const EdgeInsets.all(4),
      ),
    );
  }
}

// BillSection same as before!
class BillSection extends StatefulWidget {
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
  State<BillSection> createState() => _BillSectionState();
}

class _BillSectionState extends State<BillSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Total and Arrow
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "TOTAL: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "₹${widget.total}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      /* Text(
                        "Breakdown",
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ), */
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: Colors.orange.shade700,
                        size: 28,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Conditional: Show breakdown only if expanded
          AnimatedCrossFade(
            duration: Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: Colors.yellow.shade100, thickness: 1),
                _billRow("Subtotal", widget.subtotal),
                SizedBox(height: 4),
                _billRow("Tax and Fees", widget.taxAndFees),
                SizedBox(height: 4),
                _deliveryRow(),
                SizedBox(height: 10),
              ],
            ),
            secondChild: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _deliveryRow() {
    if (widget.delivery == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Delivery",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
            Text(
              "Free Delivery",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else {
      return _billRow("Delivery", widget.delivery);
    }
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
