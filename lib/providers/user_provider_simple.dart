import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firebase_service.dart';

class ChildProfile {
  final String name;
  final int classLevel;
  final String avatar;
  final int age;

  ChildProfile({
    required this.name,
    required this.classLevel,
    required this.avatar,
    required this.age,
  });
}

class UserProviderSimple with ChangeNotifier {
  User? _user;
  ChildProfile? _childProfile;
  bool _isLoading = false;

  User? get user => _user;
  ChildProfile? get childProfile => _childProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<bool> createChildProfile({
    required String name,
    required int classLevel,
    required String avatar,
    required int age,
  }) async {
    _setLoading(true);

    // Simulate profile creation
    await Future.delayed(const Duration(seconds: 1));

    _childProfile = ChildProfile(
      name: name,
      classLevel: classLevel,
      avatar: avatar,
      age: age,
    );

    // Create user with child profile
    _user = User(
      uid: 'child_${name.toLowerCase().replaceAll(' ', '_')}',
      name: name,
      email: 'child@nepallearning.quest',
      photoUrl: null,
      xp: 0,
      level: 1,
      classLevel: classLevel,
      streak: 0,
      completedLessons: [],
      badges: [],
    );

    _setLoading(false);
    notifyListeners();
    return true;
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      try {
        await GoogleSignIn.instance.initialize(
          serverClientId: '235702908555-nereq6ujcslkmtgmakl1usp16ded06os.apps.googleusercontent.com',
        );
      } catch (e) {
        debugPrint('Init error (ignored): $e');
      } // Ignore initialization errors if already initialized
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final googleAuth = googleUser.authentication;
      final authz = await googleUser.authorizationClient.authorizationForScopes(
        [],
      );

      final firebase_auth.OAuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
            accessToken: authz?.accessToken,
            idToken: googleAuth.idToken,
          );

      final firebase_auth.UserCredential userCredential = await firebase_auth
          .FirebaseAuth
          .instance
          .signInWithCredential(credential);
      final firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        int classLevel = 1;
        try {
          final doc = await FirebaseService().getUserDoc(firebaseUser.uid);
          if (doc != null && doc.data()!.containsKey('classLevel')) {
            classLevel = doc.data()!['classLevel'];
          }
        } catch (e) {
          // Default to 1
        }
        
        _user = User(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Student',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          xp: 50,
          level: 1,
          classLevel: classLevel,
          streak: 3,
          completedLessons: [],
          badges: [],
        );
        // Save to Firestore
        await FirebaseService().saveUserScore(
          _user!.uid,
          _user!.name,
          _user!.xp,
          _user!.level,
          _user!.photoUrl,
          _user!.classLevel,
        );
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Google sign in error: $e");
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      await firebase_auth.FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("Sign out error: $e");
    }
    _user = null;
    notifyListeners();
  }

  Future<void> addXP(int xp) async {
    if (_user == null) return;

    _user = _user!.copyWith(xp: _user!.xp + xp);

    // Update level if needed
    int newLevel = 1;
    int xpThreshold = 100;
    while (_user!.xp >= xpThreshold) {
      newLevel++;
      xpThreshold += newLevel * 100;
    }

    if (newLevel != _user!.level) {
      _user = _user!.copyWith(level: newLevel);
    }

    // Update Firestore whenever XP changes
    await FirebaseService().saveUserScore(
      _user!.uid,
      _user!.name,
      _user!.xp,
      _user!.level,
      _user!.photoUrl,
      _user!.classLevel,
    );

    notifyListeners();
  }

  Future<void> upgradeToPremium() async {
    if (_user == null) return;

    _setLoading(true);
    // Simulate API call for premium upgrade
    await Future.delayed(const Duration(seconds: 2));

    _user = _user!.copyWith(isPremium: true);

    _setLoading(false);
    notifyListeners();
  }

  Future<void> completeLesson(String lessonId) async {
    if (_user == null) return;

    if (!_user!.completedLessons.contains(lessonId)) {
      _user = _user!.copyWith(
        completedLessons: [..._user!.completedLessons, lessonId],
      );
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
