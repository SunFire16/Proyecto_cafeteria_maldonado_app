import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

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
      body: Center(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                Map<String, dynamic> userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                String userName =
                    userData['firstName'];
                // Mostrar mensaje flotante de bienvenida
                Future.delayed(Duration(milliseconds: 500), () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('¡Bienvenido a la pantalla de administrador, $userName! :)'),
                      duration: Duration(seconds: 4), // Duración del mensaje flotante
                    ),
                  );
                });
              }
              // Mostrar el resto de la interfaz de usuario
              return SizedBox();
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
