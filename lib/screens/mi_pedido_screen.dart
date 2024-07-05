import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cafeteriamaldonado_app_2/providers/cart_provider.dart';
import 'order_summary_screen.dart';
import 'package:cafeteriamaldonado_app_2/models/product_model.dart';

class MiPedidoScreen extends StatelessWidget {
  const MiPedidoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Pedido'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return const Center(
              child: Text('No hay productos en el carrito.'),
            );
          }

          return ListView.builder(
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              var cartItem = cartProvider.items[index];

              double variantPrice = 0.0;
              if (cartItem.variant.isNotEmpty) {
                variantPrice = cartItem.product.variants
                    .firstWhere(
                      (variant) => variant.name == cartItem.variant,
                      orElse: () => Variant(name: '', price: 0.0, inventory: 0),
                    )
                    .price;
              }

              double modifiersPrice = cartItem.modifiers.fold(
                0.0,
                (sum, modifier) => sum + modifier.price,
              );

              double itemTotalPrice = (cartItem.product.price + variantPrice + modifiersPrice) * cartItem.quantity;

              return ListTile(
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
                    Text('Precio unitario: L. ${(cartItem.product.price + variantPrice + modifiersPrice).toStringAsFixed(2)}'),
                    Text('Total: L. ${itemTotalPrice.toStringAsFixed(2)}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    cartProvider.removeFromCart(cartItem);
                  },
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      TextEditingController _commentsController = TextEditingController(text: cartItem.comments);
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                        if (cartItem.quantity > 1) {
                                          setState(() {
                                            cartProvider.updateCartItemQuantity(cartItem, cartItem.quantity - 1);
                                          });
                                        }
                                      },
                                    ),
                                    Text(cartItem.quantity.toString(), style: const TextStyle(fontSize: 16)),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          cartProvider.updateCartItemQuantity(cartItem, cartItem.quantity + 1);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    cartProvider.updateComments(cartItem, _commentsController.text);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Guardar cambios'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Container(
            color: Colors.blue,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Puntos de lealtad a recibir: ${cartProvider.loyaltyPoints.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PaymentScreen(),
                      ),
                    );
                  },
                  child: Text('Realizar Pedido (Total: L. ${cartProvider.totalPrice.toStringAsFixed(2)})'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métodos de Pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OrderSummaryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.monetization_on),
              label: const Text('Pagar al momento de la entrega'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No disponible por el momento')),
                );
              },
              icon: const Icon(Icons.transfer_within_a_station),
              label: const Text('Transferencia (requiere aprobación)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No disponible por el momento')),
                );
              },
              icon: const Icon(Icons.credit_card),
              label: const Text('Tarjeta de débito o crédito'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No disponible por el momento')),
                );
              },
              icon: const Icon(Icons.paypal),
              label: const Text('PayPal'),
            ),
          ],
        ),
      ),
    );
  }
}
