import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafeteriamaldonado_app_2/models/product_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String productsCollection = 'products';
  final String categoriesCollection = 'categories';
  final String modifiersCollection = 'modifiers';

  Future<void> addProduct(Product product) async {
    await _db.collection(productsCollection).add(product.toJson());
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection(productsCollection).doc(product.id).update(product.toJson());
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection(productsCollection).doc(productId).delete();
  }

  Future<List<Product>> getProducts() async {
    QuerySnapshot snapshot = await _db.collection(productsCollection).get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  Future<void> addCategory(Category category) async {
    await _db.collection(categoriesCollection).add(category.toJson());
  }

  Future<void> updateCategory(Category category) async {
    await _db.collection(categoriesCollection).doc(category.id).update(category.toJson());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db.collection(categoriesCollection).doc(categoryId).delete();
  }

Future<List<Category>> getCategories() async {
    QuerySnapshot snapshot = await _db.collection(categoriesCollection).get();
    return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
  }
    
Future<void> addModifierGroup(ModifierGroup group) async {
    await _db.collection('modifierGroups').doc(group.name).set(group.toJson());
  }

  Future<void> updateModifierGroup(ModifierGroup group) async {
    await _db.collection('modifierGroups').doc(group.name).update(group.toJson());
  }

  Future<void> deleteModifierGroup(String groupName) async {
    await _db.collection('modifierGroups').doc(groupName).delete();
  }

  Future<List<ModifierGroup>> getModifierGroups() async {
    QuerySnapshot snapshot = await _db.collection('modifierGroups').get();
    return snapshot.docs.map((doc) => ModifierGroup.fromFirestore(doc)).toList();
  }
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
