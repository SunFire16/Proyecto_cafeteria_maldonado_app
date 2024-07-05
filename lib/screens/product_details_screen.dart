import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafeteriamaldonado_app_2/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:cafeteriamaldonado_app_2/providers/cart_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String _selectedVariant = '';
  List<String> _selectedModifiers = [];
  TextEditingController _commentsController = TextEditingController();
  ValueNotifier<double> _totalPrice = ValueNotifier<double>(0.0);
  ValueNotifier<int> _quantity = ValueNotifier<int>(1);
  Product? _product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Producto'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('products').doc(widget.productId).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState ==ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return const Text('Algo salió mal.');
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('El producto no existe.');
          }

          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          Product product = Product.fromFirestore(snapshot.data!);

          if (_product == null) {
            _product = product;
            _totalPrice.value = product.price;
          }

          void _updateTotalPrice() {
            double basePrice = product.price;

            double variantPrice = 0.0;
            if (_selectedVariant.isNotEmpty) {
              variantPrice = product.variants.firstWhere(
                (variant) => variant.name == _selectedVariant,
                orElse: () => Variant(name: '', price: 0.0, inventory: 0),
              ).price;
            }

            double modifiersPrice = _selectedModifiers.fold(0.0, (sum, modifierName) {
              for (var group in product.modifierGroups) {
                for (var modifier in group.modifiers) {
                  if (modifier.name == modifierName) {
                    return sum + modifier.price;
                  }
                }
              }
              return sum;
            });

            _totalPrice.value = basePrice;
            if (_selectedVariant.isNotEmpty || _selectedModifiers.isNotEmpty) {
              _totalPrice.value += variantPrice + modifiersPrice;
            }
            _totalPrice.value *= _quantity.value;
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              data['imageUrl'] != null
                  ? Image.network(data['imageUrl'], height: 400, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 200),
              const SizedBox(height: 16),
              Text(
                data['name'],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (product.price == 0.0 && product.variants.isNotEmpty) ...[
                Text('Desde L. ${product.variants.map((v) => v.price).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
              ] else ...[
                Text('L. ${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
              ],
              const SizedBox(height: 8),
              Text(data['details'] ?? ''),
              const SizedBox(height: 16),
              if (product.variants.isNotEmpty) ...[
                const Text('Variantes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      children: product.variants.map((variant) {
                        return RadioListTile<String>(
                          title: Text('${variant.name} (Quedan ${variant.inventory})'),
                          subtitle: Text('L. ${variant.price.toStringAsFixed(2)}'),
                          value: variant.name,
                          groupValue: _selectedVariant,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedVariant = value!;
                              _updateTotalPrice();
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              if (product.modifierGroups.isNotEmpty) ...[
                const Text('Modificadores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Column(
                  children: product.modifierGroups.map((group) {
                    return ExpansionTile(
                      title: Text(group.name),
                      initiallyExpanded: true,
                      children: group.modifiers.map((modifier) {
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return CheckboxListTile(
                              title: Text(modifier.name),
                              subtitle: Text('L. ${modifier.price.toStringAsFixed(2)}'),
                              value: _selectedModifiers.contains(modifier.name),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedModifiers.add(modifier.name);
                                  } else {
                                    _selectedModifiers.remove(modifier.name);
                                  }
                                  _updateTotalPrice();
                                });
                              },
                            );
                          },
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _commentsController,
                decoration: const InputDecoration(
                  labelText: 'Comentarios adicionales',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Cantidad:', style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_quantity.value > 1) {
                        _quantity.value--;
                        _updateTotalPrice();
                      }
                    },
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: _quantity,
                    builder: (context, value, child) {
                      return Text(value.toString(), style: const TextStyle(fontSize: 16));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _quantity.value++;
                      _updateTotalPrice();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<double>(
                valueListenable: _totalPrice,
                builder: (context, value, child) {
                  return ElevatedButton(
                    child: Text('Agregar al Carrito (Total: L. ${value.toStringAsFixed(2)})'),
                    onPressed: product.price == 0.0 && _selectedVariant.isEmpty
                        ? null
                        : () {
                            Provider.of<CartProvider>(context, listen: false).addToCart(
                              product,
                              _selectedVariant,
                              _selectedModifiers,
                              _commentsController.text,
                              _quantity.value,
                            );
                            Navigator.of(context).pop();
                          },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
