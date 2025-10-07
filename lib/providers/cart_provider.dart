import 'package:flutter/material.dart';
import '../models/subcategory.dart';
import '../models/MealBox_model.dart';

// CartItem wraps a product and tracks its quantity
class CartItem<T> {
  final T product;
  final String vendorId;
  int quantity;

  CartItem({required this.product, required this.vendorId, this.quantity = 1});

  String get name {
    if (product is SubCategory) return (product as SubCategory).name;
    if (product is MealBox) return (product as MealBox).title.replaceAll('"', '').trim();
    return '';
  }

  String get imageUrl {
    if (product is SubCategory) return (product as SubCategory).imageUrl ?? '';
    if (product is MealBox) {
      final mb = product as MealBox;
      // Prefer actualImage, fallback to boxImage
      return (mb.actualImage?.isNotEmpty == true)
          ? mb.actualImage!
          : ((mb.boxImage?.isNotEmpty == true) ? mb.boxImage! : '');
    }
    return '';
  }

  int get pricePerUnit {
    if (product is SubCategory) {
      final sub = product as SubCategory;
      return sub.discountedPrice; // use discountedPrice always
    }
    if (product is MealBox) return (product as MealBox).price;
    return 0;
  }

  String get id {
    if (product is SubCategory) return (product as SubCategory).id.toString();
    if (product is MealBox) return (product as MealBox).id;
    return '';
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem<dynamic>> _items = [];
  List<CartItem<dynamic>> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;
  int get totalUniqueItems => _items.length;
  int get subtotal =>
      _items.fold(0, (sum, item) => sum + item.pricePerUnit * item.quantity);
  int get taxAndFees => (subtotal * 0.15).round();

  int get delivery {
    if (isEmpty) return 0;

    int subCategoryDelivery = 0;
    bool hasMealBox = false;

    for (var item in _items) {
      if (item.product is SubCategory) {
        final sub = item.product as SubCategory;
        if (sub.deliveryPriceEnabled) {
          subCategoryDelivery += sub.deliveryPrice.toInt();
        }
      } else if (item.product is MealBox) {
        hasMealBox = true;
      }
    }

    // Delivery for MealBox is fixed at 30 if any exist in cart
    int mealBoxDelivery = hasMealBox ? 30 : 0;

    // Sum delivery charges if both types in cart
    return subCategoryDelivery + mealBoxDelivery;
  }

  int get total => subtotal + taxAndFees + delivery;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  // Add SubCategory or MealBox to cart
  void addToCart(dynamic product) {
    final id = product is SubCategory
        ? product.id.toString()
        : product is MealBox
            ? product.id
            : null;

    if (id == null) throw Exception("Unsupported product");

    final idx = _items.indexWhere((item) => item.id == id);

    final int minQty = product is SubCategory
        ? product.minQty
        : product is MealBox
            ? product.minQty
            : 1;

    if (idx >= 0) {
      // Increase quantity by minQty, not just 1
      _items[idx].quantity += minQty;
    } else {
      final vendorId = product is SubCategory
          ? product.vendorId.toString()
          : product is MealBox
              ? product.vendorId
              : '';
      // Add with quantity = minQty initially
      _items.add(CartItem<dynamic>(product: product, vendorId: vendorId, quantity: minQty));
    }
    notifyListeners();
  }

  // Increment quantity by step (e.g., minQty)
  void incrementQuantityBy(String productId, int step) {
    final index = _items.indexWhere((item) => item.product.id.toString() == productId);
    if (index >= 0) {
      _items[index].quantity += step;
      notifyListeners();
    }
  }

  // Decrement quantity by step, remove if below minQty
  void decrementQuantityBy(String productId, int step) {
    final index = _items.indexWhere((item) => item.product.id.toString() == productId);
    if (index >= 0) {
      int newQty = _items[index].quantity - step;
      final minQty = _getMinQtyForProduct(_items[index].product);
      if (newQty < minQty) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQty;
      }
      notifyListeners();
    }
  }

  int _getMinQtyForProduct(dynamic product) {
    if (product is SubCategory) return product.minQty;
    if (product is MealBox) return product.minQty;
    return 1;
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
