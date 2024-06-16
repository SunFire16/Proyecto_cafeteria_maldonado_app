import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cafeteriamaldonado_app_2/providers/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    // Generar un ID único para el pedido
    String orderId = FirebaseFirestore.instance.collection('orders').doc().id;

    // Crear los datos del pedido
    Map<String, dynamic> orderData = {
      'id': orderId,
      'customerName': user.displayName ?? 'Cliente',
      'items': cartProvider.items.map((item) => {
        'product': item.product.toJson(),
        'variant': item.variant,
        'modifiers': item.modifiers.map((modifier) => modifier.toJson()).toList(),
        'comments': item.comments,
        'quantity': item.quantity,
      }).toList(),
      'totalPrice': cartProvider.totalPrice,
      'loyaltyPoints': cartProvider.loyaltyPoints,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);

    await userDocRef.set({
      'loyaltyPoints': currentLoyaltyPoints + cartProvider.loyaltyPoints,
      'totalSpent': totalSpent + cartProvider.totalPrice,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del Pedido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Pedido',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.items.length,
                itemBuilder: (context, index) {
                  var cartItem = cartProvider.items[index];
                  return ListTile(
                    title: Text(cartItem.product.name),
                    subtitle: Text(
                      'Variante: ${cartItem.variant}\nModificadores: ${cartItem.modifiers.map((modifier) => modifier.name).join(', ')}\nComentarios: ${cartItem.comments}\nCantidad: ${cartItem.quantity}',
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
