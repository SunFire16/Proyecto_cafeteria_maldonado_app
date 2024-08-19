import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  void _showQrFullScreen(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: Colors.white,
            ),
          ),
        );
      },
    );
  }

  void _showCancelOrderDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Pedido'),
          content: const Text('¿Estás seguro de que deseas cancelar este pedido?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                _cancelOrder(orderId);
                Navigator.of(context).pop();
              },
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelOrder(String orderId) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'Cancelado',
    });
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> orderData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles del Pedido #${orderData['id']}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Cliente: ${orderData['customerName']}'),
                Text('Email: ${orderData['customerEmail']}'),
                Text('Fecha: ${DateFormat('dd/MM/yyyy, HH:mm').format(orderData['timestamp'].toDate())}'),
                Text('Total: L. ${orderData['totalPrice']}'),
                Text('Puntos de lealtad: ${orderData['loyaltyPoints'].toStringAsFixed(2)}'),
                Text('Estado: ${orderData['status']}'),
                const SizedBox(height: 10),
                const Text('Productos:'),
                for (var item in orderData['items'])
                  Text(
                    '${item['product']['name']} x${item['quantity']} - L. ${(item['product']['price'] * item['quantity']).toStringAsFixed(2)}',
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user!.uid)
        .orderBy('timestamp', descending: true);

    return Scaffold(
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

              final orderTime = dateTime.add(const Duration(hours: 3));
              final canCancel = DateTime.now().isBefore(orderTime);
              final timeRemaining = orderTime.difference(DateTime.now()).inMilliseconds;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pedido #${orderData['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Fecha: $formattedDate'),
                      Text('Total: L. ${orderData['totalPrice']}'),
                      Text('Puntos de lealtad: ${orderData['loyaltyPoints'].toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      Center(
                        child: GestureDetector(
                          onTap: () => _showQrFullScreen(context, 'Pedido: ${orderData['items'].map((item) => item['product']['name']).join(', ')}'),
                          child: QrImageView(
                            data: 'Pedido: ${orderData['items'].map((item) => item['product']['name']).join(', ')}',
                            version: QrVersions.auto,
                            size: 150.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      if (canCancel) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: CountdownTimer(
                            endTime: DateTime.now().millisecondsSinceEpoch + timeRemaining,
                            widgetBuilder: (_, time) {
                              if (time == null) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                'Tienes hasta: ${time.hours ?? 0}h ${time.min ?? 0}m ${time.sec ?? 0}s si deseas cancelar tu pedido.',
                                style: const TextStyle(color: Colors.red),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _showCancelOrderDialog(context, order.id),
                            child: const Text('Cancelar Pedido', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            _showOrderDetails(context, orderData);
                          },
                          child: const Text('Ver Detalles'),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          orderData['status'] == 'Entregado'
                              ? 'Entregado'
                              : orderData['status'] == 'Cancelado'
                                  ? 'Cancelado'
                                  : 'Pendiente',
                          style: TextStyle(
                            color: orderData['status'] == 'Entregado'
                                ? Colors.green
                                : orderData['status'] == 'Cancelado'
                                    ? Colors.grey
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
