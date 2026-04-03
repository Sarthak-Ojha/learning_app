

class FirebaseService {
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    return [
      {'name': 'Aarav', 'xp': 1500, 'level': 5, 'photoUrl': null},
      {'name': 'Priya', 'xp': 1200, 'level': 4, 'photoUrl': null},
      {'name': 'Sujan', 'xp': 900, 'level': 3, 'photoUrl': null},
      {'name': 'Sita', 'xp': 800, 'level': 2, 'photoUrl': null},
      {'name': 'Ram', 'xp': 750, 'level': 2, 'photoUrl': null},
    ];
  }
}
