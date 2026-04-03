import 'package:flutter/foundation.dart';
import '../models/user.dart';

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
    
    // Simulate sign-in with mock user data
    await Future.delayed(const Duration(seconds: 2));
    
    _user = User(
      uid: 'demo_user',
      name: 'Demo Student',
      email: 'demo@nepallearning.quest',
      photoUrl: null,
      xp: 50,
      level: 1,
      streak: 3,
      completedLessons: [],
      badges: [],
    );
    
    _setLoading(false);
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
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
    
    notifyListeners();
  }

  Future<void> completeLesson(String lessonId) async {
    if (_user == null) return;
    
    if (!_user!.completedLessons.contains(lessonId)) {
      _user = _user!.copyWith(
        completedLessons: [..._user!.completedLessons, lessonId]
      );
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
