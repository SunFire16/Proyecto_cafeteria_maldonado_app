import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeteriamaldonado_app_2/screens/admin_screen.dart';
import 'package:cafeteriamaldonado_app_2/screens/home_screen.dart';
import 'package:cafeteriamaldonado_app_2/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cafeteriamaldonado_app_2/providers/cart_provider.dart';
import 'package:cafeteriamaldonado_app_2/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String theme = prefs.getString('theme') ?? 'system';
    setState(() {
      _themeMode = _getThemeModeFromString(theme);
    });
  }

  Future<void> _saveThemePreference(String theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    setState(() {
      _themeMode = _getThemeModeFromString(theme);
    });
  }

  ThemeMode _getThemeModeFromString(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void changeTheme(String theme) {
    _saveThemePreference(theme);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Cafetería Maldonado',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          iconTheme:
              IconThemeData(color: Colors.black), // Íconos negros en modo claro
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.amber,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[900],
          ),
          iconTheme: IconThemeData(
              color: Colors.white), // Íconos blancos en modo oscuro
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.grey[900],
            selectedItemColor: Colors.amber[800],
            unselectedItemColor: Colors.grey,
          ),
        ),
        themeMode: _themeMode,
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isAuthenticated = false;
  bool _isAdmin = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    checkAuthenticationStatus();
  }

  Future<void> checkAuthenticationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    setState(() {
      _isAuthenticated = isAuthenticated;
    });

    if (_isAuthenticated) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          String userId = user.uid;
          bool isAdminUser = await AuthService().isAdmin(userId);
          setState(() {
            _currentUser = user;
            _isAdmin = isAdminUser;
          });
        } else {
          setState(() {
            _currentUser = null;
            _isAuthenticated = false;
            _isAdmin = false;
          });
        }
      });
    } else {
      setState(() {
        _currentUser = null;
        _isAdmin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated || _currentUser == null) {
      return LoginScreen();
    } else {
      return _isAdmin ? AdminScreen() : HomeScreen();
    }
  }
}
