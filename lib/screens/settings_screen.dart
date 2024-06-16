import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _loyaltyPercentageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLoyaltyPercentage();
  }

  Future<void> _loadLoyaltyPercentage() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('settings').doc('loyalty').get();
    if (doc.exists) {
      setState(() {
        _loyaltyPercentageController.text = (doc['percentage'] ?? 10).toString();
      });
    }
  }

  Future<void> _saveLoyaltyPercentage() async {
    double percentage = double.tryParse(_loyaltyPercentageController.text) ?? 10;
    await FirebaseFirestore.instance.collection('settings').doc('loyalty').set({
      'percentage': percentage,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Porcentaje de lealtad actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Settings Screen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Configuración de Puntos de Lealtad',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _loyaltyPercentageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Porcentaje de Puntos de Lealtad',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _saveLoyaltyPercentage,
            child: const Text('Guardar Porcentaje'),
          ),
        ],
      ),
    );
  }
}
