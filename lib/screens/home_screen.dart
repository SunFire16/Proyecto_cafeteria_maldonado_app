import 'package:cafeteriamaldonado_app_2/screens/My_orders.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'mi_pedido_screen.dart';
import 'mas_screen.dart';
import 'admin_screen.dart';
import 'menu_screen.dart';
import 'friends_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdminView;

  const HomeScreen({Key? key, this.isAdminView = false}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late String userName = '';
  double loyaltyPoints = 0.0;
  int totalOrders = 0;
  DateTime? lastPurchaseDate;

  final List<Widget> _screens = [
    const HomeContentScreen(),
    const MenuScreen(),
    const MiPedidoScreen(),
    const MyOrdersScreen(),
    const MasScreen(),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserNameAndData();
  }

  Future<void> fetchUserNameAndData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        userName = userData['firstName'];
        loyaltyPoints = userData['loyaltyPoints'] ?? 0.0;
        totalOrders = userData['totalOrders'] ?? 0;
        if (userData['lastPurchaseDate'] != null) {
          lastPurchaseDate = (userData['lastPurchaseDate'] as Timestamp).toDate();
        }
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido a la app de Cafetería Maldonado, $userName! :)'),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: widget.isAdminView
          ? AppBar(
              title: const Text('Home'),
              actions: <Widget>[
                if (widget.isAdminView)
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const AdminScreen(),
                      ));
                    },
                  ),
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
            )
          : null,
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: iconColor),
            activeIcon: Icon(Icons.home, color: Colors.amber),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu, color: iconColor),
            activeIcon: Icon(Icons.menu, color: Colors.amber),
            label: 'Menú',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: iconColor),
            activeIcon: Icon(Icons.shopping_cart, color: Colors.amber),
            label: 'Mi Pedido',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt, color: iconColor),
            activeIcon: Icon(Icons.list_alt, color: Colors.amber),
            label: 'Mis pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz, color: iconColor),
            activeIcon: Icon(Icons.more_horiz, color: Colors.amber),
            label: 'Más',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContentScreen extends StatelessWidget {
  const HomeContentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return const Text('Algo salió mal.');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('No se encontraron datos del usuario.');
        }

        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
        String userName = userData['firstName'];
        double loyaltyPoints = userData['loyaltyPoints'] ?? 0.0;
        int totalOrders = userData['totalOrders'] ?? 0;
        DateTime? lastPurchaseDate;
        if (userData['lastPurchaseDate'] != null) {
          lastPurchaseDate = (userData['lastPurchaseDate'] as Timestamp).toDate();
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
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
                  if (lastPurchaseDate != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Última Compra'),
                        subtitle: Text(
                          'Fecha: ${lastPurchaseDate.toLocal().day}/${lastPurchaseDate.toLocal().month}/${lastPurchaseDate.toLocal().year}',
                        ),
                      ),
                    ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.loyalty),
                      title: const Text('Puntos de Lealtad'),
                      subtitle: Text('${loyaltyPoints.toStringAsFixed(2)} puntos'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: const Text('Total de Pedidos'),
                      subtitle: Text('$totalOrders pedidos'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Conéctate con amigos'),
                      subtitle: const Text('Encuentra y haz amigos para donar puntos de lealtad.'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FriendsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
