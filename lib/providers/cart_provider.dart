import 'package:flutter/material.dart';
import 'package:cafeteriamaldonado_app_2/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  double _loyaltyPointsPercentage = 0.03;

  List<CartItem> get items => _items;

  CartProvider() {
    _loadLoyaltyPointsPercentage();
  }

  Future<void> _loadLoyaltyPointsPercentage() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('settings').doc('loyalty').get();
    if (doc.exists) {
      _loyaltyPointsPercentage = (doc['percentage'] ?? 3) / 100;
      notifyListeners();
    }
  }

  double get totalPrice => _items.fold(0, (total, item) {
    double variantPrice = item.product.variants.firstWhere(
      (variant) => variant.name == item.variant, 
      orElse: () => Variant(name: 'default', price: item.product.price, inventory: 0)
    ).price;
    double modifiersPrice = item.modifiers.fold(0, (sum, modifier) => sum + modifier.price);
    return total + (item.product.price + variantPrice + modifiersPrice) * item.quantity;
  });

  double get loyaltyPoints {
    return double.parse((totalPrice * _loyaltyPointsPercentage).toStringAsFixed(2));
  }

  void addToCart(Product product, String variant, List<String> modifiers, String comments, int quantity) {
    List<Modifier> selectedModifiers = product.modifierGroups.expand((group) => group.modifiers).where((modifier) => modifiers.contains(modifier.name)).toList();
    _items.add(CartItem(product: product, variant: variant, modifiers: selectedModifiers, comments: comments, quantity: quantity));
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void updateCartItemQuantity(CartItem item, int quantity) {
    item.quantity = quantity;
    notifyListeners();
  }

  void updateComments(CartItem item, String comments) {
    item.comments = comments;
    notifyListeners();
  }

    void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final Product product;
  final String variant;
  final List<Modifier> modifiers;
  String comments;
  int quantity;

  CartItem({
    required this.product,
    required this.variant,
    required this.modifiers,
    required this.comments,
    this.quantity = 1,
  });
}
