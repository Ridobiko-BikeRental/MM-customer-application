/* import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../models/subcategory.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.75;
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      body: Consumer<CartProvider>(
        builder: (context, cart, _) => Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(32)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          child: Column(
            children: [
              // Header
              Row(
                children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Text(
            "Filter",
            style: TextStyle(
                color: AppColors.buttonText, fontSize: 24),
          ),
                ],
              ),
              SizedBox(height: 8),
              Divider(color: Colors.yellow.shade100, thickness: 1),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  cart.isEmpty
                      ? "Your cart is empty"
                      : "You have ${cart.totalUniqueItems} item(s) in the cart",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // CART CONTENT or EMPTY STATE
              if (cart.isEmpty)
                Expanded(
                  child: Center(
                    child: Icon(
                      Icons.remove_shopping_cart,
                      size: 100,
                      color: Colors.white24,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final cartItem = cart.items[index];
                      return CartProductTile(
                        cartItem: cartItem,
                        onIncrement: () =>
                            cart.incrementQuantityBy(cartItem.product.id),
                        onDecrement: () =>
                            cart.decrementQuantityBy(cartItem.product.id),
                      );
                    },
                  ),
                ),

              Divider(color: Colors.yellow.shade100, thickness: 1),
              SizedBox(height: 12),

              // BILL DETAILS (automatically updates with cart)
              BillSection(
                subtotal: cart.subtotal,
                taxAndFees: cart.taxAndFees,
                delivery: cart.delivery,
                total: cart.total,
              ),

              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: cart.isEmpty
                      ? null
                      : () {
                          Navigator.pushNamed(context, '/checkout');
                        },
                  child: Text(
                    "Checkout",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Separate Widget: Cart Product Row ----
class CartProductTile extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartProductTile({
    super.key,
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (cartItem.imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              cartItem.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fastfood, color: Colors.white54),
          ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cartItem.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              if (cartItem.product is SubCategory &&
                  (cartItem.product as SubCategory).discount > 0)
                Row(
                  children: [
                    Text(
                      '₹${(cartItem.product as SubCategory).pricePerUnit}',
                      style: const TextStyle(
                        color: Colors.white70,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '₹${cartItem.pricePerUnit}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  '₹${cartItem.pricePerUnit}',
                  style: const TextStyle(color: Colors.white70),
                ),
            ],
          ),
        ),

        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.white70, size: 22),
              onPressed: onDecrement,
            ),
            Text(
              '${cartItem.quantity}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.white, size: 22),
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }
}

// ---- Separate Widget: Bill Section ----

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
              color: Colors.white,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Text(
            "₹${price.toString()}",
            style: TextStyle(
              color: Colors.white,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
} */
