import 'package:flutter/material.dart';
import '../models/subcategory.dart';
import '../models/MealBox_model.dart';

// CartItem wraps a product and tracks its quantity
class CartItem<T> {
  final T product;
  final String vendorId;
  int quantity;


  CartItem({required this.product,required this.vendorId, this.quantity = 1});

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
      return mb.actualImage.isNotEmpty
          ? mb.actualImage
          : (mb.boxImage.isNotEmpty ? mb.boxImage : '');
    }
    return '';
  }

  int get pricePerUnit {
    if (product is SubCategory) {
      final sub = product as SubCategory;
      return sub.discountedPrice; // <-- use discountedPrice always
    }
    if (product is MealBox) return (product as MealBox).price;
    return 0;
  }

  String get id {
    if (product is SubCategory) return (product as SubCategory).id;
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
  int get delivery => isEmpty ? 0 : 30;
  int get total => subtotal + taxAndFees + delivery;
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  // Add SubCategory or MealBox to cart
  void addToCart(dynamic product) {
    final id = product is SubCategory
        ? product.id
        : product is MealBox
            ? product.id
            : null;

    if (id == null) throw Exception("Unsupported product");

    final idx = _items.indexWhere((item) => item.id == id);

    if (idx >= 0) {
      _items[idx].quantity++;
    } else{
      final vendorId = product is SubCategory
        ? product.vendor 
        : '';  // 👈 make sure SubCategory has a `vendor` or `vendorId`
       // : product is MealBox
            //? product.    //if MealBox also has vendor
            //: '';
      _items.add(CartItem<dynamic>(product: product,vendorId: vendorId,));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    final idx = _items.indexWhere((item) => item.id == productId);
    if (idx >= 0) {
      _items[idx].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    final idx = _items.indexWhere((item) => item.id == productId);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
