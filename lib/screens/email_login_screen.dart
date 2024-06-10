import 'package:flutter/material.dart';
import 'package:cafeteriamaldonado_app_2/services/auth_service.dart';
import 'home_screen.dart';
import 'registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa esta librería

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({Key? key}) : super(key: key);

  @override
  _EmailLoginScreenState createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingreso con correo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logo.png',
                height: 150,
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                // Dentro del onPressed del botón de inicio de sesión en EmailLoginScreen

                onPressed: () async {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  // Verificar si el correo existe en la base de datos
                  bool emailExists = await _auth.doesEmailExist(email);

                  if (!emailExists) {
                    // Mostrar mensaje de advertencia si el correo no existe
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'No existe una cuenta de usuario con ese correo')),
                    );
                    return; // Salir del método onPressed
                  }

                  // Continuar con el inicio de sesión si el correo existe
                  final user =
                      await _auth.signInWithEmailAndPassword(email, password);
                  if (user != null) {
                    // Guardar el estado de autenticación como verdadero en SharedPreferences
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool('isAuthenticated', true);
                    // Resto del código...
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  } else {
                    // Handle login error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Contraseña incorrecta')),
                    );
                  }
                },

                icon: const Icon(Icons.login),
                label: const Text('Iniciar sesión'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const RegistrationScreen()),
                  );
                },
                icon: const Icon(Icons.app_registration),
                label: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
