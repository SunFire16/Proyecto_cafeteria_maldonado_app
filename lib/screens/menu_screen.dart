import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_details_screen.dart';
import 'package:cafeteriamaldonado_app_2/models/product_model.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar productos...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Algo salió mal.');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          Map<String, List<Product>> categorizedProducts = {};
          List<Product> searchResults = [];

          for (var document in snapshot.data!.docs) {
            Product product = Product.fromFirestore(document);

            if (_searchQuery.isNotEmpty) {
              if (product.name.toLowerCase().contains(_searchQuery)) {
                searchResults.add(product);
              }
            } else {
              if (!categorizedProducts.containsKey(product.category)) {
                categorizedProducts[product.category] = [];
              }
              categorizedProducts[product.category]!.add(product);
            }
          }

          if (_searchQuery.isNotEmpty) {
            if (searchResults.isEmpty) {
              return const Center(child: Text('No se encontraron coincidencias.'));
            }

            return ListView(
              children: searchResults.map((product) {
                String priceText;

                if (product.price == 0.0 && product.variants.isNotEmpty) {
                  double minVariantPrice = product.variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);
                  priceText = 'Desde L. $minVariantPrice en adelante';
                } else {
                  priceText = 'L. ${product.price}';
                }

                return ListTile(
                  leading: product.imageUrl.isNotEmpty
                      ? Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 50),
                  title: Text(product.name),
                  subtitle: Text('$priceText\nQuedan ${product.inventory} disponibles'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          productId: product.id,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          } else {
            return ListView(
              children: categorizedProducts.entries.map((entry) {
                return ExpansionTile(
                  title: Text(entry.key),
                  children: entry.value.map((product) {
                    String priceText;

                    if (product.price == 0.0 && product.variants.isNotEmpty) {
                      double minVariantPrice = product.variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);
                      priceText = 'Desde L. $minVariantPrice en adelante';
                    } else {
                      priceText = 'L. ${product.price}';
                    }

                    return ListTile(
                      leading: product.imageUrl.isNotEmpty
                          ? Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 50),
                      title: Text(product.name),
                      subtitle: Text('$priceText\nQuedan ${product.inventory} disponibles'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(
                              productId: product.id,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
