import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserDoc(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc : null;
    } catch (e) {
      debugPrint("Error fetching user doc: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard(int classLevel) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('classLevel', isEqualTo: classLevel)
          .orderBy('xp', descending: true)
          .limit(10)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint("Error fetching leaderboard: $e");
      return [];
    }
  }

  Future<void> saveUserScore(String uid, String name, int xp, int level, String? photoUrl, int classLevel) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'xp': xp,
        'level': level,
        'photoUrl': photoUrl,
        'classLevel': classLevel,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error saving user score: $e");
    }
  }
}
