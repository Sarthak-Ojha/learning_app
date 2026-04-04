import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/parental_control_service.dart';

/// Full-screen lock wall — back button disabled, only correct PIN dismisses it.
class ParentalLockScreen extends StatefulWidget {
  /// If true, shows "Time's up!" instead of "App is Locked".
  final bool isTimeLimitExpired;

  const ParentalLockScreen({
    super.key,
    this.isTimeLimitExpired = false,
  });

  @override
  State<ParentalLockScreen> createState() => _ParentalLockScreenState();
}

class _ParentalLockScreenState extends State<ParentalLockScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String? _errorMessage;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  static const _primary = Color(0xFF1976D2);
  static const _darkText = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onKeyTap(String key) {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += key;
      _errorMessage = null;
    });
    if (_enteredPin.length == 4) _verifyPin();
  }

  void _onDelete() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _verifyPin() async {
    final correct = await ParentalControlService.instance.verifyPin(_enteredPin);
    if (correct) {
      await ParentalControlService.instance.unlockApp();
      if (mounted) Navigator.of(context).pop(true);
    } else {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _enteredPin = '';
        _errorMessage = 'Incorrect PIN. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Scale down elements on small screens
    final isSmall = screenHeight < 700;
    final iconSize = isSmall ? 40.0 : 56.0;
    final keySize = isSmall ? 64.0 : 80.0;
    final keyFontSize = isSmall ? 20.0 : 26.0;
    final headerPadTop = isSmall ? 24.0 : 48.0;
    final headerPadBottom = isSmall ? 20.0 : 32.0;
    final titleFontSize = isSmall ? 20.0 : 26.0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // ── Header ──────────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(24, headerPadTop, 24, headerPadBottom),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF81D4FA), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmall ? 14 : 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isTimeLimitExpired
                                  ? Icons.timer_off_rounded
                                  : Icons.lock_rounded,
                              size: iconSize,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: isSmall ? 12 : 20),
                          Text(
                            widget.isTimeLimitExpired
                                ? "Time's Up! ⏰"
                                : 'App is Locked 🔒',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.isTimeLimitExpired
                                ? "Daily screen time has been reached.\nParent PIN required to continue."
                                : "Enter Parent PIN to unlock.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmall ? 13 : 15,
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ── PIN Dots ─────────────────────────────────────────
                    AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (context, child) {
                        final offset = _shakeCtrl.isAnimating
                            ? 10 * _shakeAnim.value * ((_shakeAnim.value * 8).ceil() % 2 == 0 ? 1 : -1)
                            : 0.0;
                        return Transform.translate(
                          offset: Offset(offset, 0),
                          child: child,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) {
                          final filled = i < _enteredPin.length;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: filled ? _primary : Colors.transparent,
                              border: Border.all(
                                color: filled ? _primary : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Error message
                    SizedBox(
                      height: 24,
                      child: _errorMessage != null
                          ? Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // ── Numpad ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          _buildRow(['1', '2', '3'], keySize, keyFontSize),
                          SizedBox(height: isSmall ? 10 : 14),
                          _buildRow(['4', '5', '6'], keySize, keyFontSize),
                          SizedBox(height: isSmall ? 10 : 14),
                          _buildRow(['7', '8', '9'], keySize, keyFontSize),
                          SizedBox(height: isSmall ? 10 : 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildKey('', keySize, keyFontSize, isBlank: true),
                              _buildKey('0', keySize, keyFontSize),
                              _buildDeleteKey(keySize),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'GyanYatra · Parental Controls',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> keys, double keySize, double keyFontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) => _buildKey(k, keySize, keyFontSize)).toList(),
    );
  }

  Widget _buildKey(String label, double keySize, double keyFontSize, {bool isBlank = false}) {
    if (isBlank) return SizedBox(width: keySize, height: keySize);
    return GestureDetector(
      onTap: () => _onKeyTap(label),
      child: Container(
        width: keySize,
        height: keySize,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: keyFontSize,
              fontWeight: FontWeight.bold,
              color: _darkText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey(double keySize) {
    return GestureDetector(
      onTap: _onDelete,
      child: Container(
        width: keySize,
        height: keySize,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red.shade200, width: 1.5),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_rounded,
            color: Colors.red.shade400,
            size: keySize * 0.35,
          ),
        ),
      ),
    );
  }
}
