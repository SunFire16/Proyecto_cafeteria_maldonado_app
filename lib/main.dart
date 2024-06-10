import 'package:cafeteriamaldonado_app_2/screens/admin_screen.dart';
import 'package:cafeteriamaldonado_app_2/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafetería Maldonado',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthenticationWrapper(),
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
      String userId = FirebaseAuth.instance.currentUser!.uid;
      bool isAdminUser = await AuthService().isAdmin(userId);
      setState(() {
        _isAdmin = isAdminUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return LoginScreen();
    } else {
      return _isAdmin ? AdminScreen() : HomeScreen();
    }
  }
}
