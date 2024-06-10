import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');

  Future<bool> isAdmin(String userId) async {
  DocumentSnapshot userData = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();
  return userData['isAdmin'] ?? false;
}

  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final userData =
          await _usersCollection.doc(userId).get().then((doc) => doc.data());
      return userData as Map<String, dynamic>;
    } catch (e) {
      print('Error al obtener los datos del usuario: $e');
      return {};
    }
  }

  Future<void> updateUserData(String userId,
      {String? firstName, String? lastName, String? phone, String? email}) async {
    try {
      await _usersCollection.doc(userId).update({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phone,
        'email': email,
      });
    } catch (e) {
      print('Error al actualizar los datos del usuario: $e');
    }
  }


  Future<User?> registerAsClientWithEmailAndPassword(
    String email, String password, String name, String surname, String phone) async {
  try {
    final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = result.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'firstName': name,
        'lastName': surname,
        'phoneNumber': phone,
        'email': email,
        'isAdmin': false, // Establecer como cliente por defecto
      });
    }

    return user;
  } catch (e) {
    print(e.toString());
    return null;
  }
}

  Future<bool> doesEmailExist(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar el correo electrónico: $e');
      return false;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<User?> registerWithEmailAndPassword(
      String email, String password, String firstName, String lastName, String phoneNumber) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'email': email,
        });
      }

      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token);

        final UserCredential authResult = await _auth.signInWithCredential(credential);
        return authResult.user;
      } else {
        print(result.status);
        print(result.message);
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String?> verifyPhoneNumber(String phoneNumber) async {
    Completer<String> completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e.message ?? "Verification failed");
      },
      codeSent: (String verificationId, int? resendToken) {
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        completer.completeError("Timeout");
      },
    );

    return completer.future;
  }

  Future<User?> signInWithSmsCode(String verificationId, String smsCode) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      final UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
