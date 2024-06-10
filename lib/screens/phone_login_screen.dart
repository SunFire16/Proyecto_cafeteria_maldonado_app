import 'package:flutter/material.dart';
import 'package:cafeteriamaldonado_app_2/services/auth_service.dart';
import 'home_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  _PhoneLoginScreenState createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  String? verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresar con celular'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Número de celular'),
            ),
            ElevatedButton(
              onPressed: () async {
                final phone = _phoneController.text.trim();
                try {
                  verificationId = await _auth.verifyPhoneNumber(phone);
                } catch (e) {
                  print('Error durante la verificación: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Verificar mi número de celular'),
            ),
            TextField(
              controller: _smsController,
              decoration: const InputDecoration(labelText: 'Código SMS'),
            ),
            ElevatedButton(
              onPressed: () async {
                final smsCode = _smsController.text.trim();
                if (verificationId != null) {
                  final user = await _auth.signInWithSmsCode(verificationId!, smsCode);
                  if (user != null) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
                  } else {
                    print('Error al iniciar sesión con celular');
                  }
                } else {
                  print('Verificación ID es nulo');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Primero verifica tu número de celular')),
                  );
                }
              },
              child: const Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }
}
