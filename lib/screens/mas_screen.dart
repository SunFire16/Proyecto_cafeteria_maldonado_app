import 'package:flutter/material.dart';
import 'add_info_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeteriamaldonado_app_2/main.dart';

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
