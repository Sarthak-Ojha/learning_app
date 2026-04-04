class User {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  int xp;
  int level;
  int classLevel;
  int streak;
  List<String> completedLessons;
  List<String> badges;
  bool isPremium;

  User({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.xp = 0,
    this.level = 1,
    this.classLevel = 1,
    this.streak = 0,
    this.completedLessons = const [],
    this.badges = const [],
    this.isPremium = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'xp': xp,
      'level': level,
      'classLevel': classLevel,
      'streak': streak,
      'completedLessons': completedLessons,
      'badges': badges,
      'isPremium': isPremium,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      xp: map['xp']?.toInt() ?? 0,
      level: map['level']?.toInt() ?? 1,
      classLevel: map['classLevel']?.toInt() ?? 1,
      streak: map['streak']?.toInt() ?? 0,
      completedLessons: List<String>.from(map['completedLessons'] ?? []),
      badges: List<String>.from(map['badges'] ?? []),
      isPremium: map['isPremium'] ?? false,
    );
  }

  User copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    int? xp,
    int? level,
    int? classLevel,
    int? streak,
    List<String>? completedLessons,
    List<String>? badges,
    bool? isPremium,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      classLevel: classLevel ?? this.classLevel,
      streak: streak ?? this.streak,
      completedLessons: completedLessons ?? this.completedLessons,
      badges: badges ?? this.badges,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  int get xpToNextLevel => level * 100;
  double get levelProgress => xp / xpToNextLevel;
  
  String get levelName {
    switch (level) {
      case 1:
        return 'Terai Explorer';
      case 2:
        return 'Pahad Climber';
      case 3:
        return 'Himal Summiter';
      default:
        return 'Everest Master';
    }
  }
}
