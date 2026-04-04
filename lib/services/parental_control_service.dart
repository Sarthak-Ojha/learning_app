import 'package:shared_preferences/shared_preferences.dart';

class ParentalControlService {
  static ParentalControlService? _instance;
  static ParentalControlService get instance =>
      _instance ??= ParentalControlService._();
  ParentalControlService._();

  static const _kPin = 'parent_pin';
  static const _kTimeLimit = 'time_limit_minutes'; // 0 = unlimited
  static const _kSessionStart = 'session_start_ms';
  static const _kIsLocked = 'is_locked';

  // ── PIN ────────────────────────────────────────────────────────────────────

  Future<bool> isSetUp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kPin) && (prefs.getString(_kPin) ?? '').length == 4;
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPin, pin);
  }

  Future<bool> verifyPin(String input) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPin) == input;
  }

  // ── Time Limit ─────────────────────────────────────────────────────────────

  Future<void> setTimeLimit(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTimeLimit, minutes);
  }

  Future<int> getTimeLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kTimeLimit) ?? 0;
  }

  // ── Session ────────────────────────────────────────────────────────────────

  Future<void> startSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSessionStart, DateTime.now().millisecondsSinceEpoch);
    await prefs.setBool(_kIsLocked, false);
  }

  /// Returns true if the time limit has been reached.
  Future<bool> checkSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final limitMinutes = prefs.getInt(_kTimeLimit) ?? 0;
    if (limitMinutes == 0) return false;

    final startMs = prefs.getInt(_kSessionStart);
    if (startMs == null) return false;

    final elapsed = DateTime.now().millisecondsSinceEpoch - startMs;
    final expiredMs = limitMinutes * 60 * 1000;
    return elapsed >= expiredMs;
  }

  // ── Lock / Unlock ──────────────────────────────────────────────────────────

  Future<void> lockApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsLocked, true);
  }

  Future<void> unlockApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsLocked, false);
    // Reset session timer on unlock
    await prefs.setInt(_kSessionStart, DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> isLocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsLocked) ?? false;
  }

  /// How many minutes remain in the current session. Returns null if unlimited.
  Future<int?> remainingMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final limitMinutes = prefs.getInt(_kTimeLimit) ?? 0;
    if (limitMinutes == 0) return null;

    final startMs = prefs.getInt(_kSessionStart);
    if (startMs == null) return limitMinutes;

    final elapsed =
        (DateTime.now().millisecondsSinceEpoch - startMs) ~/ 60000;
    final remaining = limitMinutes - elapsed;
    return remaining > 0 ? remaining : 0;
  }
}
