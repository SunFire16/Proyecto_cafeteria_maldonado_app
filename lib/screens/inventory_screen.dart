import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafeteriamaldonado_app_2/models/product_model.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final Map<String, TextEditingController> _productInventoryControllers = {};
  final Map<String, Map<String, TextEditingController>> _variantInventoryControllers = {};

  void _updateInventory(String productId, String variantName, int newInventory) async {
    DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc(productId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(productRef);
      if (!snapshot.exists) {
        throw Exception("Product does not exist!");
      }

      Product product = Product.fromFirestore(snapshot);
      if (variantName.isEmpty) {
        product.inventory = newInventory;
      } else {
        for (var variant in product.variants) {
          if (variant.name == variantName) {
            variant.inventory = newInventory;
          }
        }
        product.inventory = product.variants.fold(0, (sum, variant) => sum + variant.inventory);
      }

      transaction.update(productRef, product.toJson());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inventario actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Algo salió mal.');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Product product = Product.fromFirestore(document);

              if (!_productInventoryControllers.containsKey(product.id)) {
                _productInventoryControllers[product.id] = TextEditingController(
                  text: product.inventory.toString(),
                );
              }

              if (!_variantInventoryControllers.containsKey(product.id)) {
                _variantInventoryControllers[product.id] = {};
                for (var variant in product.variants) {
                  _variantInventoryControllers[product.id]![variant.name] = TextEditingController(
                    text: variant.inventory.toString(),
                  );
                }
              }

              return ExpansionTile(
                title: Text(product.name),
                subtitle: Text('Inventario total: ${product.inventory}'),
                children: [
                  if (product.variants.isNotEmpty) ...product.variants.map((variant) {
                    return ListTile(
                      title: Text(variant.name),
                      subtitle: TextField(
                        controller: _variantInventoryControllers[product.id]![variant.name],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Inventario'),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () {
                          int newInventory = int.tryParse(_variantInventoryControllers[product.id]![variant.name]!.text) ?? variant.inventory;
                          _updateInventory(product.id, variant.name, newInventory);
                        },
                      ),
                    );
                  }).toList(),
                  if (product.variants.isEmpty)
                    ListTile(
                      subtitle: TextField(
                        controller: _productInventoryControllers[product.id],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Inventario'),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () {
                          int newInventory = int.tryParse(_productInventoryControllers[product.id]!.text) ?? product.inventory;
                          _updateInventory(product.id, '', newInventory);
                        },
                      ),
                    ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _productInventoryControllers.values.forEach((controller) => controller.dispose());
    _variantInventoryControllers.values.forEach((map) {
      map.values.forEach((controller) => controller.dispose());
    });
    super.dispose();
  }
}
