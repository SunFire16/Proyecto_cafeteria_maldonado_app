import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String userId;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser!.uid;
  }

  Future<void> addFriend(String friendId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .doc(friendId)
        .set({'addedAt': Timestamp.now()});
    await _firestore
        .collection('users')
        .doc(friendId)
        .collection('friends')
        .doc(userId)
        .set({'addedAt': Timestamp.now()});
  }

  void shareFriendLink() {
    final String data = userId;
    Share.share('Escanea este código QR para agregarme como amigo en la Cafetería Maldonado App: $data');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.white : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Amigos'),
      ),
      body: Column(
        children: <Widget>[
          QrImageView(
            data: userId,
            version: QrVersions.auto,
            size: 200.0,
            backgroundColor: backgroundColor,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const QRViewExample()),
              );
            },
            child: const Text('Escanear Código QR'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').doc(userId).collection('friends').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Text('Algo salió mal.');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No tienes amigos agregados.');
                }
                List<DocumentSnapshot> friendDocs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: friendDocs.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore.collection('users').doc(friendDocs[index].id).get(),
                      builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            title: Text('Cargando...'),
                          );
                        }
                        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                          return const ListTile(
                            title: Text('Usuario no encontrado'),
                          );
                        }
                        Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(userData['firstName']),
                          subtitle: Text(userData['email']),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });
      if (result != null) {
        await _addFriend(result!.code!);
        controller.pauseCamera();
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _addFriend(String friendId) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final User? user = _auth.currentUser;

    if (user != null) {
      final String userId = user.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .set({'addedAt': Timestamp.now()});
      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(userId)
          .set({'addedAt': Timestamp.now()});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Código QR')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Código QR detectado: ${result!.code}')
                  : const Text('Escanea un código QR'),
            ),
          )
        ],
      ),
    );
  }
}
