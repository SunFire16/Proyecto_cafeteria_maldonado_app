import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeteriamaldonado_app_2/main.dart';
import 'add_info_screen.dart';
import 'login_screen.dart';

class MasScreen extends StatefulWidget {
  const MasScreen({Key? key}) : super(key: key);

  @override
  _MasScreenState createState() => _MasScreenState();
}

class _MasScreenState extends State<MasScreen> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
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

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar cierre de sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión? Necesitarás ingresar tu correo y contraseña para volver a acceder.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                _signOut(context); // Cerrar sesión
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text('Configuraciones de la App'),
            trailing: const Icon(Icons.settings),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Modificar Perfil'),
            trailing: const Icon(Icons.person),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ModifyProfileScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Cerrar sesión'),
            trailing: const Icon(Icons.logout),
            onTap: () => _showSignOutDialog(context),
          ),
        ],
      ),
    );
  }
}

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  _AppSettingsScreenState createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
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
      appBar: AppBar(
        title: const Text('Configuraciones de la App'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo Oscuro'),
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
