import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({Key? key}) : super(key: key);

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  DateTime? _selectedDate;
  TextEditingController _dateController = TextEditingController();

  void _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('timestamp', descending: true);

    if (_selectedDate != null) {
      DateTime startOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      DateTime endOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);
      query = query
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de Pedidos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Filtrar por fecha',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _pickDate(context),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
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
                      subtitle: Text(
                        'Cliente: ${orderData['customerName']}\nTotal: L. ${orderData['totalPrice']}\nPuntos de lealtad: ${orderData['loyaltyPoints'].toStringAsFixed(2)}\nFecha: $formattedDate\nEstado: ${orderData['status']}',
                      ),
                      trailing: orderData['status'] == 'Entregado'
                          ? const Text('Entregado', style: TextStyle(color: Colors.green))
                          : ElevatedButton(
                              onPressed: () {
                                FirebaseFirestore.instance.collection('orders').doc(order.id).update({'status': 'Entregado'});
                              },
                              child: const Text('Marcar como Entregado'),
                            ),
                      onTap: () {},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
