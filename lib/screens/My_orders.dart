import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('customerName', isEqualTo: user!.displayName)
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Algo salió mal.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('No hay pedidos confirmados.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderData = order.data() as Map<String, dynamic>;
              Timestamp timestamp = orderData['timestamp'];
              DateTime dateTime = timestamp.toDate();
              String formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(dateTime);

              return ListTile(
                title: Text('Pedido #${orderData['id']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fecha: $formattedDate'),
                    Text('Total: L. ${orderData['totalPrice']}'),
                    Text('Puntos de lealtad: ${orderData['loyaltyPoints'].toStringAsFixed(2)}'),
                    QrImageView(
                      data: 'Pedido: ${orderData['items'].map((item) => item['product']['name']).join(', ')}',
                      version: QrVersions.auto,
                      size: 100.0,
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
                trailing: orderData['status'] == 'Entregado'
                    ? const Text('Entregado', style: TextStyle(color: Colors.green))
                    : const Text('Pendiente', style: TextStyle(color: Colors.red)),
                onTap: () {
                },
              );
            },
          );
        },
      ),
    );
  }
}
