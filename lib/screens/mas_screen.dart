import 'package:flutter/material.dart';
import 'add_info_screen.dart';

class MasScreen extends StatelessWidget {
  const MasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ModifyProfileScreen()),
                );
              },
              child: Text('Modificar perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
