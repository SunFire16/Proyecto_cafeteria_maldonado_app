import 'package:flutter/material.dart';
import 'package:cafeteriamaldonado_app_2/services/auth_service.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa esta librería

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Correo electrónico es obligatorio';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return 'Correo electrónico no válido';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Contraseña es obligatoria';
    }
    return null;
  }

  String? _validateName(String name) {
    if (name.isEmpty) {
      return 'Nombre es obligatorio';
    }
    return null;
  }

  String? _validateSurname(String surname) {
    if (surname.isEmpty) {
      return 'Apellido es obligatorio';
    }
    return null;
  }

  String? _validatePhone(String phone) {
    if (phone.isEmpty) {
      return 'Número de teléfono es obligatorio';
    }
    final phoneRegex = RegExp(r'^[389]\d{7}$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Número de teléfono no válido';
    }
    return null;
  }

  Future<void> _register() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final name = _nameController.text.trim();
  final surname = _surnameController.text.trim();
  final phone = _phoneController.text.trim();

  final emailError = _validateEmail(email);
  final passwordError = _validatePassword(password);
  final nameError = _validateName(name);
  final surnameError = _validateSurname(surname);
  final phoneError = _validatePhone(phone);

  if (emailError != null ||
      passwordError != null ||
      nameError != null ||
      surnameError != null ||
      phoneError != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Errores de validación:\n' +
              (emailError ?? '') +
              '\n' +
              (passwordError ?? '') +
              '\n' +
              (nameError ?? '') +
              '\n' +
              (surnameError ?? '') +
              '\n' +
              (phoneError ?? ''),
        ),
      ),
    );
    return;
  }

  // Verificar si el correo electrónico ya existe en la base de datos
  final bool emailExists = await _auth.doesEmailExist(email);
  if (emailExists) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('El correo electrónico ya está registrado')),
    );
    return;
  }

  // Registrar al usuario como cliente
  final user = await _auth.registerAsClientWithEmailAndPassword(
      email, password, name, surname, phone);
  if (user != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } else {
    // Handle registration error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fallo al registrarse')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de usuario'),
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
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _surnameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number, // Mostrar teclado numérico
                decoration: const InputDecoration(
                  labelText: 'Número de teléfono',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
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
                onPressed: _register,
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
