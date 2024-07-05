import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final double totalPrice;

  const PaymentScreen({Key? key, required this.totalPrice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Método de Pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Efectivo al momento de la entrega'),
              leading: const Icon(Icons.money),
              onTap: () {
              },
            ),
            ListTile(
              title: const Text('Transferencia (requiere aprobación)'),
              leading: const Icon(Icons.account_balance),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No disponible por el momento'),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Tarjeta de débito o crédito'),
              leading: const Icon(Icons.credit_card),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No disponible por el momento'),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('PayPal'),
              leading: const Icon(Icons.payment),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No disponible por el momento'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
