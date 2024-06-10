import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_screen.dart';
import 'mi_pedido_screen.dart';
import 'ofertas_screen.dart';
import 'mas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late String userName = '';

  final List<Widget> _screens = [
    const HomeContentScreen(),
    const MenuScreen(),
    const MiPedidoScreen(),
    const OfertasScreen(),
    const MasScreen(),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserName();
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
            content: Text(
                '¡Bienvenido a la app de Cafetería Maldonado, $userName! :)'),
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
        title: const Text('Home'),
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
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu, color: Colors.black),
            label: 'Menú',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            label: 'Mi Pedido',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer, color: Colors.black),
            label: 'Ofertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            label: 'Más',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContentScreen extends StatelessWidget {
  const HomeContentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              Map<String, dynamic> userData =
                  snapshot.data!.data() as Map<String, dynamic>;
              String userName = userData['firstName'];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bienvenido, $userName',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // Aquí puedes agregar más widgets para mostrar información o funcionalidades adicionales
                ],
              );
            } else {
              return const Text('No se encontraron datos del usuario.');
            }
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
