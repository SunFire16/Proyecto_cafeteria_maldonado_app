import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cafeteriamaldonado_app_2/providers/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cafeteriamaldonado_app_2/models/product_model.dart';

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({Key? key}) : super(key: key);

  Future<void> _confirmOrder(BuildContext context, CartProvider cartProvider) async {
    final user = FirebaseAuth.instance.currentUser;
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    final userDoc = await userDocRef.get();

    double currentLoyaltyPoints = userDoc.exists && (userDoc.data() as Map<String, dynamic>).containsKey('loyaltyPoints')
        ? userDoc['loyaltyPoints']
        : 0.0;

    double totalSpent = userDoc.exists && (userDoc.data() as Map<String, dynamic>).containsKey('totalSpent')
        ? userDoc['totalSpent']
        : 0.0;

    DateTime now = DateTime.now();

    // Obtener el nombre completo del usuario
    String customerName = '${userDoc['firstName']} ${userDoc['lastName']}';

    // Generar un ID único para el pedido
    String orderId = FirebaseFirestore.instance.collection('orders').doc().id;

    Map<String, dynamic> orderData = {
      'id': orderId,
      'userId': user.uid,  // Añadir userId para referenciar al usuario
      'customerName': customerName,
      'customerEmail': user.email,  // Añadir correo electrónico del cliente
      'items': cartProvider.items.map((item) {
        Map<String, dynamic> productData = {
          'product': item.product.toJson(),
          'quantity': item.quantity,
        };
        if (item.variant.isNotEmpty) {
          productData['variant'] = item.variant;
        }
        if (item.modifiers.isNotEmpty) {
          productData['modifiers'] = item.modifiers.map((modifier) => modifier.toJson()).toList();
        }
        if (item.comments.isNotEmpty) {
          productData['comments'] = item.comments;
        }
        return productData;
      }).toList(),
      'totalPrice': cartProvider.totalPrice,
      'loyaltyPoints': cartProvider.loyaltyPoints,
      'timestamp': now,
      'status': 'Pendiente',
    };

    await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);

    for (var item in cartProvider.items) {
      DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc(item.product.id);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(productRef);
        if (!snapshot.exists) {
          throw Exception("Producto no existe!");
        }

        Product product = Product.fromFirestore(snapshot);
        if (item.variant.isNotEmpty) {
          for (var variant in product.variants) {
            if (variant.name == item.variant) {
              variant.inventory -= item.quantity;
            }
          }
        } else {
          product.inventory -= item.quantity;
        }

        transaction.update(productRef, product.toJson());
      });
    }

    await userDocRef.set({
      'loyaltyPoints': currentLoyaltyPoints + cartProvider.loyaltyPoints,
      'totalSpent': totalSpent + cartProvider.totalPrice,
      'lastPurchaseDate': now,  // Guardar la fecha de la última compra
    }, SetOptions(merge: true));

    cartProvider.clearCart();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido confirmado')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.white : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del Pedido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.items.length,
                itemBuilder: (context, index) {
                  var cartItem = cartProvider.items[index];
                  return ListTile(
                    leading: cartItem.product.imageUrl.isNotEmpty
                        ? Image.network(
                            cartItem.product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image, size: 50),
                    title: Text(cartItem.product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cartItem.variant.isNotEmpty)
                          Text('Variante: ${cartItem.variant}'),
                        if (cartItem.modifiers.isNotEmpty)
                          Text('Modificadores: ${cartItem.modifiers.map((modifier) => modifier.name).join(', ')}'),
                        if (cartItem.comments.isNotEmpty)
                          Text('Comentarios: ${cartItem.comments}'),
                        Text('Cantidad: ${cartItem.quantity}'),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: QrImageView(
                data: 'Pedido: ${cartProvider.items.map((item) => item.product.name).join(', ')}',
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: backgroundColor,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _confirmOrder(context, cartProvider),
                child: const Text('Confirmar Pedido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
