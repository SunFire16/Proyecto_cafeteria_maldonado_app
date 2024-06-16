import 'package:flutter/material.dart';
import 'package:cafeteriamaldonado_app_2/services/auth_service.dart';
import 'email_login_screen.dart';
import 'phone_login_screen.dart';
import 'home_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
              height: 300,
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              icon: const Icon(Icons.email),
              label: const Text('Iniciar sesión con correo'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const EmailLoginScreen(),
                ));
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
              label: const Text('Iniciar sesión con Google'),
              onPressed: () async {
                final user = await AuthService().signInWithGoogle();
                if (user != null) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const HomeScreen()));
                } else {                  
                  print('Error al iniciar sesión con Google');
                }
              },
            ),
            const SizedBox(height: 10),
            /* Botón de inicio de sesión con Facebook
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
              label: const Text('Iniciar sesión con Facebook'),
              onPressed: () async {
                final user = await AuthService().signInWithFacebook();
                if (user != null) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const HomeScreen()));
                } else {
                  print('Error al iniciar sesión con Facebook');
                }
              },
            ),
            const SizedBox(height: 10),*/
            // Botón de inicio de sesión con número de celular
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              icon: const Icon(Icons.phone),
              label: const Text('Iniciar sesión con número de celular'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PhoneLoginScreen(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
