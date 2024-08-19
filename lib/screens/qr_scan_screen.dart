import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';

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
