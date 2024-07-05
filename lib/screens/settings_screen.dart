import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeteriamaldonado_app_2/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _loyaltyPercentageController = TextEditingController();
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadLoyaltyPercentage();
    _loadThemePreference();
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

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String theme = prefs.getString('theme') ?? 'system';
    setState(() {
      isDarkMode = theme == 'dark';
    });
  }

  Future<void> _saveThemePreference(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String theme = isDarkMode ? 'dark' : 'light';
    await prefs.setString('theme', theme);
    setState(() {
      this.isDarkMode = isDarkMode;
    });
    MyApp.of(context)?.changeTheme(theme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: Text('Puntos de Lealtad'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoyaltyPointsSettingsScreen(
                  loyaltyPercentageController: _loyaltyPercentageController,
                  saveLoyaltyPercentage: _saveLoyaltyPercentage,
                )),
              );
            },
          ),
          SwitchListTile(
            title: Text('Modo Oscuro'),
            value: isDarkMode,
            onChanged: (bool value) {
              _saveThemePreference(value);
            },
          ),
        ],
      ),
    );
  }
}

class LoyaltyPointsSettingsScreen extends StatelessWidget {
  final TextEditingController loyaltyPercentageController;
  final Future<void> Function() saveLoyaltyPercentage;

  LoyaltyPointsSettingsScreen({
    required this.loyaltyPercentageController,
    required this.saveLoyaltyPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración de Puntos de Lealtad'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Configuración de Puntos de Lealtad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: loyaltyPercentageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Porcentaje de Puntos de Lealtad',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: saveLoyaltyPercentage,
              child: const Text('Guardar Porcentaje'),
            ),
          ],
        ),
      ),
    );
  }
}
