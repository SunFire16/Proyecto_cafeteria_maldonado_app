import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchReportData() async {
    double totalSales = 0.0;
    double totalLoyaltyPoints = 0.0;
    int totalOrders = 0;
    int totalProductsSold = 0;

    QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance.collection('orders').get();
    for (var doc in ordersSnapshot.docs) {
      Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
      totalSales += orderData['totalPrice'];
      totalLoyaltyPoints += orderData['loyaltyPoints'];
      totalOrders++;
      for (var item in orderData['items']) {
        totalProductsSold += (item['quantity'] as num).toInt();
      }
    }

    return {
      'totalSales': totalSales,
      'totalLoyaltyPoints': totalLoyaltyPoints,
      'totalOrders': totalOrders,
      'totalProductsSold': totalProductsSold,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchReportData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los informes'));
          }

          final reportData = snapshot.data ?? {};
          final totalSales = reportData['totalSales'] ?? 0.0;
          final totalLoyaltyPoints = reportData['totalLoyaltyPoints'] ?? 0.0;
          final totalOrders = reportData['totalOrders'] ?? 0;
          final totalProductsSold = reportData['totalProductsSold'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildReportCard('Ventas Totales', 'L. ${totalSales.toStringAsFixed(2)}', Icons.attach_money),
                _buildReportCard('Puntos de Lealtad Acumulados', '${totalLoyaltyPoints.toStringAsFixed(2)}', Icons.loyalty),
                _buildReportCard('Total de Pedidos', '$totalOrders', Icons.receipt),
                _buildReportCard('Total de Productos Vendidos', '$totalProductsSold', Icons.shopping_basket),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.amber),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
