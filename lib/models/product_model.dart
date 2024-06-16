import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id;
  String name;
  String category;
  String details;
  String imageUrl;
  double price;
  double cost;
  int inventory;
  bool isVisible;
  List<Variant> variants;
  List<ModifierGroup> modifierGroups;

  Product({
    required this.id,
    required this.name,
    required this.category,
    this.details = '',
    this.imageUrl = '',
    required this.price,
    this.cost = 0.0,
    this.inventory = 0,
    this.isVisible = true,
    this.variants = const [],
    this.modifierGroups = const [], 
  });

  factory Product.fromJson(Map<String, dynamic> json, String documentId) {
    return Product(
      id: documentId,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      details: json['details'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      inventory: json['inventory'] ?? 0,
      isVisible: json['isVisible'] ?? true,
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map((variant) => Variant.fromJson(variant))
          .toList(),
      modifierGroups: (json['modifierGroups'] as List<dynamic>? ?? [])
          .map((group) => ModifierGroup.fromJson(group))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'details': details,
      'imageUrl': imageUrl,
      'price': price,
      'cost': cost,
      'inventory': inventory,
      'isVisible': isVisible,
      'variants': variants.map((variant) => variant.toJson()).toList(),
      'modifierGroups': modifierGroups.map((group) => group.toJson()).toList(),
    };
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    return Product.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }
}

class Variant {
  String name;
  double price;
  int inventory; 

  Variant({
    required this.name,
    required this.price,
    this.inventory = 0,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      inventory: json['inventory'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'inventory': inventory, 
    };
  }
}

class Modifier {
  String name;
  double price;

  Modifier({
    required this.name,
    required this.price,
  });

  factory Modifier.fromJson(Map<String, dynamic> json) {
    return Modifier(
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}

class ModifierGroup {
  String name;
  List<Modifier> modifiers;

  ModifierGroup({
    required this.name,
    this.modifiers = const [],
  });

  factory ModifierGroup.fromJson(Map<String, dynamic> json) {
    return ModifierGroup(
      name: json['name'] ?? '',
      modifiers: (json['modifiers'] as List<dynamic>? ?? [])
          .map((modifier) => Modifier.fromJson(modifier))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'modifiers': modifiers.map((modifier) => modifier.toJson()).toList(),
    };
  }

  factory ModifierGroup.fromFirestore(DocumentSnapshot doc) {
    return ModifierGroup.fromJson(doc.data() as Map<String, dynamic>);
  }
}
