import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddInfoScreen extends StatefulWidget {
  const AddInfoScreen({Key? key}) : super(key: key);

  @override
  _AddInfoScreenState createState() => _AddInfoScreenState();
}

class _AddInfoScreenState extends State<AddInfoScreen> {
  final TextEditingController _infoController = TextEditingController();
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> _addInfo() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await users.doc(userId).update({
      'additionalInfo': _infoController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Información añadida exitosamente')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Información del Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _infoController,
              decoration: const InputDecoration(
                labelText: 'Información Adicional',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addInfo,
              child: const Text('Añadir Información'),
            ),
          ],
        ),
      ),
    );
  }
}
