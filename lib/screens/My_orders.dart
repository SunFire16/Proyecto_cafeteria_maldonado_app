import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';  // Importa el paquete intl

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('customerName', isEqualTo: user?.displayName ?? 'Cliente')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Algo salió mal.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No tienes pedidos confirmados.'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              Timestamp timestamp = data['timestamp'];
              DateTime dateTime = timestamp.toDate();
              String formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(dateTime);

              return ListTile(
                title: Text('Pedido ID: ${document.id}'),
                subtitle: Text(
                  'Total: L. ${data['totalPrice']}\nPuntos de lealtad ganados: ${data['loyaltyPoints'].toStringAsFixed(2)}\nFecha: $formattedDate',
                ),
                onTap: () {
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
