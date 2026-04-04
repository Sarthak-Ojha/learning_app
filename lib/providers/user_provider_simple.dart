import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firebase_service.dart';
import '../services/database_service.dart';

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

  // Check for existing session on startup
  Future<void> checkCurrentUser() async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      _setLoading(true);

      // 1. Load from local SQLite first (Fast Offline Load)
      final localUser = await DatabaseService.instance.getUser(firebaseUser.uid);
      if (localUser != null) {
        _user = localUser;
        _setLoading(false);
        notifyListeners();
      }

      // 2. Sync with Firestore (Background Sync)
      try {
        final doc = await FirebaseService()
            .getUserDoc(firebaseUser.uid)
            .timeout(const Duration(seconds: 5));
        
        if (doc != null && doc.data() != null) {
          final data = doc.data()!;
          
          // CRITICAL: If we have a local user, prioritize local Name and ClassLevel
          // because these are user-set identities that shouldn't be 'rolled back' by sync.
          final String finalName = _user?.name ?? (data['name'] ?? 'Student');
          final int finalClassLevel = _user?.classLevel ?? (data['classLevel'] ?? 1);
          
          // XP and Level can be synced from cloud if cloud is higher (cross-device progress)
          final int cloudXp = data['xp'] ?? 0;
          final int cloudLevel = data['level'] ?? 1;
          
          final int finalXp = (cloudXp > (_user?.xp ?? 0)) ? cloudXp : (_user?.xp ?? 0);
          final int finalLevel = (cloudLevel > (_user?.level ?? 1)) ? cloudLevel : (_user?.level ?? 1);

          final syncedUser = User(
            uid: firebaseUser.uid,
            name: finalName,
            email: firebaseUser.email ?? (data['email'] ?? ''),
            photoUrl: firebaseUser.photoURL ?? data['photoUrl'],
            xp: finalXp,
            level: finalLevel,
            classLevel: finalClassLevel,
            streak: data['streak'] ?? (_user?.streak ?? 0),
            completedLessons: _user?.completedLessons ?? [],
            badges: [],
            isPremium: data['isPremium'] ?? (_user?.isPremium ?? false),
          );
          
          _user = syncedUser;
          // Always update local SQLite to ensure cloud/local convergence
          await DatabaseService.instance.saveUser(_user!);
        }
      } catch (e) {
        debugPrint("Session sync: Cloud fetch failed (using local only): $e");
      }

      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> createChildProfile({
    required String name,
    required int classLevel,
    required String avatar,
    required int age,
  }) async {
    _setLoading(true);

    // Simulate profile creation (Local Only for guest)
    await Future.delayed(const Duration(seconds: 1));

    _childProfile = ChildProfile(
      name: name,
      classLevel: classLevel,
      avatar: avatar,
      age: age,
    );

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

    await DatabaseService.instance.saveUser(_user!);
    
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
      } catch (e) {}

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;

      final firebase_auth.AuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
          );

      final firebase_auth.UserCredential userCredential = await firebase_auth
          .FirebaseAuth
          .instance
          .signInWithCredential(credential);
          
      final firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        int classLevel = 1;
        int xp = 0;
        int level = 1;

        try {
          final doc = await FirebaseService()
              .getUserDoc(firebaseUser.uid)
              .timeout(const Duration(seconds: 5));
          
          if (doc != null && doc.data() != null) {
            final data = doc.data()!;
            classLevel = data['classLevel'] ?? 1;
            xp = data['xp'] ?? 0;
            level = data['level'] ?? 1;
          }
        } catch (e) {
          debugPrint("Google Sign In: Cloud sync failed: $e");
        }
        
        _user = User(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Student',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          xp: xp,
          level: level,
          classLevel: classLevel,
          streak: 3,
          completedLessons: [],
          badges: [],
        );

        // 1. Save to Offline SQLite
        await DatabaseService.instance.saveUser(_user!);

        // 2. Sync to Cloud
        FirebaseService().saveUserScore(
          _user!.uid,
          _user!.name,
          _user!.xp,
          _user!.level,
          _user!.photoUrl,
          _user!.classLevel,
        ).catchError((e) => debugPrint("Cloud save failed: $e"));
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
      // Optional: clear local SQLite
      // await DatabaseService.instance.clearAll();
    } catch (e) {
      debugPrint("Sign out error: $e");
    }
    _user = null;
    notifyListeners();
  }

  Future<void> addXP(int xp) async {
    if (_user == null) return;

    _user = _user!.copyWith(xp: _user!.xp + xp);

    int newLevel = 1;
    int xpThreshold = 100;
    while (_user!.xp >= xpThreshold) {
      newLevel++;
      xpThreshold += newLevel * 100;
    }

    if (newLevel != _user!.level) {
      _user = _user!.copyWith(level: newLevel);
    }

    // 1. Save to SQLite (Immediate Offline Save)
    await DatabaseService.instance.saveUser(_user!);

    // 2. Sync to Firestore (Delayed Background Sync)
    FirebaseService().saveUserScore(
      _user!.uid,
      _user!.name,
      _user!.xp,
      _user!.level,
      _user!.photoUrl,
      _user!.classLevel,
    ).catchError((e) => debugPrint("Cloud XP sync failed: $e"));

    notifyListeners();
  }

  Future<void> upgradeToPremium() async {
    if (_user == null) return;
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 2));
    _user = _user!.copyWith(isPremium: true);
    await DatabaseService.instance.saveUser(_user!);
    _setLoading(false);
    notifyListeners();
  }

  Future<void> completeLesson(String lessonId, int xpReward) async {
    if (_user == null) return;

    if (!_user!.completedLessons.contains(lessonId)) {
      _user = _user!.copyWith(
        completedLessons: [..._user!.completedLessons, lessonId],
      );
      
      // 1. Save completion locally
      await DatabaseService.instance.addCompletedLesson(_user!.uid, lessonId);
      
      // 2. Award XP (handles its own SQLite/Cloud sync)
      await addXP(xpReward);
      
      notifyListeners();
    }
  }

  Future<void> changeClassLevel(int newClassLevel) async {
    if (_user == null) return;
    _user = _user!.copyWith(classLevel: newClassLevel);
    
    // 1. Save locally
    await DatabaseService.instance.saveUser(_user!);
    
    // 2. Sync to Firestore
    FirebaseService().saveUserScore(
      _user!.uid,
      _user!.name,
      _user!.xp,
      _user!.level,
      _user!.photoUrl,
      _user!.classLevel,
    ).catchError((e) => debugPrint("Cloud ClassLevel sync failed: $e"));

    notifyListeners();
  }

  Future<void> changeChildName(String newName) async {
    if (_user == null) return;
    _user = _user!.copyWith(name: newName);

    // 1. Save locally
    await DatabaseService.instance.saveUser(_user!);

    // 2. Sync to Firestore
    FirebaseService().saveUserScore(
      _user!.uid,
      _user!.name,
      _user!.xp,
      _user!.level,
      _user!.photoUrl,
      _user!.classLevel,
    ).catchError((e) => debugPrint("Cloud Name sync failed: $e"));

    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
