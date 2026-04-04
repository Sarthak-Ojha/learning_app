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
      
      List<Map<String, dynamic>> players = 
          snapshot.docs.map((doc) => doc.data()).toList();

      // If we have very few real players, add high-quality "Smart Dummies"
      // to make the leaderboard look active and competitive.
      if (players.length < 10) {
        final List<String> dummyNames = [
          'Aayush Sharma', 'Smriti Rai', 'Rohan Gurung', 'Prakriti Thapa',
          'Siddharth Jha', 'Nisha Tamang', 'Bikram Shah', 'Anjali Pandey', 
          'Sunil Magar', 'Kripa Shrestha'
        ];
        
        // Base XP on real player's top XP if exists, otherwise use class-specific defaults
        int topXp = players.isNotEmpty ? players.first['xp'] : (classLevel * 200 + 500);
        
        for (int i = 0; i < (10 - players.length); i++) {
          final dummyXp = topXp - (i + 1) * 75;
          players.add({
            'name': dummyNames[i % dummyNames.length],
            'xp': dummyXp < 0 ? 10 : dummyXp,
            'level': (dummyXp / 150).floor().clamp(1, 10),
            'classLevel': classLevel,
            'isDummy': true,
          });
        }
      }

      // Re-sort because we added dummies
      players.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
      return players;
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
