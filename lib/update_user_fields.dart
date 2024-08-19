import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> updateUserFields() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User? user = _auth.currentUser;

  if (user != null) {
    final String userId = user.uid;

    final DocumentReference userDocRef = _firestore.collection('users').doc(userId);
    final DocumentSnapshot userDoc = await userDocRef.get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> updates = {};

      if (!userData.containsKey('lastPurchaseDate')) {
        updates['lastPurchaseDate'] = null;
      }

      if (!userData.containsKey('userId')) {
        updates['userId'] = userId;
      }

      if (updates.isNotEmpty) {
        await userDocRef.update(updates);
      }
    }
  }
}
