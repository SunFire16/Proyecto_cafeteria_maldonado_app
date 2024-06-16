import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'add_product_screen.dart';
import 'product_list_screen.dart';
import 'inventory_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'order_tracking_screen.dart';
import 'categories_screen.dart';
import 'home_screen.dart';
import 'modifier_groups_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late String userName = '';
  int _selectedIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    fetchUserName();
    _screens.addAll([
      const AdminHomeScreen(),
      const InventoryScreen(),
      const ReportsScreen(),
      const SettingsScreen(),
      const OrderTrackingScreen(),
    ]);
  }

  Future<void> fetchUserName() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        userName = userData['firstName'];
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido a la pantalla de administrador, $userName! :)'),
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Screen'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ));
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            activeIcon: Icon(Icons.home, color: Colors.amber),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory, color: Colors.black),
            activeIcon: Icon(Icons.inventory, color: Colors.amber),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, color: Colors.black),
            activeIcon: Icon(Icons.bar_chart, color: Colors.amber),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.black),
            activeIcon: Icon(Icons.settings, color: Colors.amber),
            label: 'Configuraciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping, color: Colors.black),
            activeIcon: Icon(Icons.local_shipping, color: Colors.amber),
            label: 'Pedidos',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber,
        onTap: _onItemTapped,
      ),
    );
  }
}

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Algo salió mal.'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No se encontraron datos del usuario.'));
        }

        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
        String userName = userData['firstName'];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 150),
                    const SizedBox(height: 16),
                    Text(
                      'Bienvenido, $userName',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _buildGridTile(
                          context,
                          'Agregar Producto',
                          Icons.add_box,
                          const AddProductScreen(),
                        ),
                        _buildGridTile(
                          context,
                          'Lista de Productos',
                          Icons.list,
                          const ProductListScreen(),
                        ),
                        _buildGridTile(
                          context,
                          'Gestión de Inventario',
                          Icons.inventory,
                          const InventoryScreen(),
                        ),
                        _buildGridTile(
                          context,
                          'Gestión de Categorías',
                          Icons.category,
                          const CategoriesScreen(),
                        ),
                        _buildGridTile(
                          context,
                          'Gestión de Modificadores',
                          Icons.settings,
                          const ModifierGroupsScreen(),
                        ),
                        _buildGridTile(
                          context,
                          'Ver como Cliente',
                          Icons.visibility,
                          const HomeScreen(isAdminView: true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridTile(BuildContext context, String title, IconData icon, Widget screen) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.amber),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
