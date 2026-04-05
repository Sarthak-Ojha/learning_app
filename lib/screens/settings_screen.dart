import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/parental_control_service.dart';
import '../providers/user_provider_simple.dart';
import 'parental_lock_screen.dart';
import 'progress_report_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSetUp = false;
  int _timeLimitMinutes = 0;
  int? _remainingMinutes;

  static const _primary = Color(0xFF1976D2);
  static const _darkText = Color(0xFF1A237E);

  static const List<int> _timeLimitOptions = [0, 15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final setUp = await ParentalControlService.instance.isSetUp();
    final limit = await ParentalControlService.instance.getTimeLimit();
    final rem = await ParentalControlService.instance.remainingMinutes();
    if (mounted) {
      setState(() {
        _isSetUp = setUp;
        _timeLimitMinutes = limit;
        _remainingMinutes = rem;
      });
    }
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  /// Shows a 4-digit PIN entry dialog. Returns the entered PIN or null.
  Future<String?> _showPinEntryDialog({
    required String title,
    required String subtitle,
  }) async {
    String pin = '';
    String? error;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            void onKey(String k) {
              if (pin.length >= 4) return;
              setS(() {
                pin += k;
                error = null;
              });
            }

            void onDelete() => setS(() {
                  if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
                  error = null;
                });

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: _darkText)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 14)),
                  const SizedBox(height: 20),
                  // PIN dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      final filled = i < pin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 16,
                        height: 16,
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
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!,
                        style: TextStyle(
                            color: Colors.red.shade600, fontSize: 12)),
                  ],
                  const SizedBox(height: 20),
                  // Mini numpad
                  ...[
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ].map(
                    (row) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: row.map((k) {
                          return GestureDetector(
                            onTap: () => onKey(k),
                            child: Container(
                              width: 60,
                              height: 52,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1),
                              ),
                              child: Center(
                                child: Text(k,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: _darkText)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 72),
                      GestureDetector(
                        onTap: () => onKey('0'),
                        child: Container(
                          width: 60,
                          height: 52,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          child: const Center(
                            child: Text('0',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _darkText)),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          width: 60,
                          height: 52,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.red.shade200, width: 1),
                          ),
                          child: Icon(Icons.backspace_rounded,
                              color: Colors.red.shade400, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    child: Text('Cancel',
                        style: TextStyle(color: Colors.grey.shade600))),
                ElevatedButton(
                  onPressed: pin.length == 4
                      ? () => Navigator.of(ctx).pop(pin)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Verify an existing PIN before granting access to a protected action.
  /// Returns true if the user passed.
  Future<bool> _requirePin({
    String title = 'Parent PIN Required',
    String subtitle = 'Enter your 4-digit PIN to continue.',
  }) async {
    final entered = await _showPinEntryDialog(title: title, subtitle: subtitle);
    if (entered == null) return false;
    final ok = await ParentalControlService.instance.verifyPin(entered);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect PIN.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return ok;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _setupOrChangePin() async {
    if (_isSetUp) {
      // Must verify old PIN first
      final ok = await _requirePin(
          title: 'Verify Current PIN',
          subtitle: 'Enter your current PIN to change it.');
      if (!ok) return;
    }

    // Enter new PIN
    final newPin = await _showPinEntryDialog(
      title: 'Set New PIN',
      subtitle: 'Choose a 4-digit parent PIN.',
    );
    if (newPin == null) return;

    // Confirm new PIN
    final confirmPin = await _showPinEntryDialog(
      title: 'Confirm PIN',
      subtitle: 'Enter the same PIN again.',
    );
    if (confirmPin == null) return;

    if (newPin != confirmPin) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PINs do not match. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    await ParentalControlService.instance.setPin(newPin);
    await _loadState();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_isSetUp ? 'PIN changed successfully!' : 'PIN set up!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _changeTimeLimit(int newLimit) async {
    await ParentalControlService.instance.setTimeLimit(newLimit);
    await _loadState();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newLimit == 0
              ? 'Time limit removed.'
              : 'Time limit set to ${_formatMinutes(newLimit)}.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _viewProgressReport() async {
    final ok = await _requirePin(
        title: 'Progress Report',
        subtitle: 'Enter your parent PIN to view the progress chart.');
    if (!ok || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => const ProgressReportScreen()),
    );
  }

  Future<void> _lockNow() async {
    await ParentalControlService.instance.lockApp();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ParentalLockScreen()),
    );
    // After unlock, refresh state
    await _loadState();
  }

  Future<void> _changeClass() async {
    final ok = await _requirePin(
        title: 'Change Child Class',
        subtitle: 'Enter your parent PIN to change the class level.');
    if (!ok || !mounted) return;

    final userProvider =
        Provider.of<UserProviderSimple>(context, listen: false);
    final currentClass = userProvider.user?.classLevel ?? 1;

    final selectedClass = await showDialog<int>(
      context: context,
      builder: (ctx) {
        int picked = currentClass;
        return StatefulBuilder(
          builder: (ctx, setS) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Select Class',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: _darkText)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) => i + 1).map((cls) {
                final isSelected = picked == cls;
                return GestureDetector(
                  onTap: () => setS(() => picked = cls),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _primary.withValues(alpha: 0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _primary : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color:
                              isSelected ? _primary : Colors.grey.shade400,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text('Class $cls',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? _primary
                                    : _darkText,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text('Cancel',
                      style: TextStyle(color: Colors.grey.shade600))),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(picked),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
      },
    );

    if (selectedClass == null || selectedClass == currentClass || !mounted) return;

    await userProvider.changeClassLevel(selectedClass);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Class changed to $selectedClass!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _changeName() async {
    final ok = await _requirePin(
        title: 'Change Child Name',
        subtitle: 'Enter your parent PIN to edit the name.');
    if (!ok || !mounted) return;

    final userProvider =
        Provider.of<UserProviderSimple>(context, listen: false);
    final currentName = userProvider.user?.name ?? 'Student';

    final nameCtrl = TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Name',
            style: TextStyle(fontWeight: FontWeight.bold, color: _darkText)),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'New Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(nameCtrl.text),
            style: ElevatedButton.styleFrom(
                backgroundColor: _primary, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName == null || newName.trim().isEmpty || newName == currentName) {
      return;
    }

    await userProvider.changeChildName(newName.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ── UI ──────────────────────────────────────────────────────────────────────

  String _formatMinutes(int m) {
    if (m == 0) return 'Unlimited';
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '${h}h' : '${h}h ${rem}m';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProviderSimple>(context);
    final childName = userProvider.user?.name ?? 'Student';
    final childClass = userProvider.user?.classLevel ?? 1;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Child Profile ──────────────────────────────────────────────
          _sectionHeader('👤  Child Profile'),
          _infoCard([
            _infoRow(
              Icons.person_rounded,
              'Name',
              childName,
              onEdit: _changeName,
            ),
            const Divider(height: 1),
            _infoRow(
              Icons.school_rounded,
              'Current Class',
              'Class $childClass',
              onEdit: _changeClass,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Parental Controls ──────────────────────────────────────────
          _sectionHeader('🔒  Parental Controls'),

          if (!_isSetUp) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Set up a parent PIN to enable parental controls.',
                      style: TextStyle(
                          color: Colors.orange.shade800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          _actionCard([
            _actionTile(
              icon: Icons.pin_rounded,
              iconColor: _primary,
              title: _isSetUp ? 'Change Parent PIN' : 'Set Up Parent PIN',
              subtitle: _isSetUp
                  ? 'Change your 4-digit parent PIN'
                  : 'Create a PIN to protect settings',
              onTap: _setupOrChangePin,
              showArrow: true,
            ),
            if (_isSetUp) ...[
              const Divider(height: 1, indent: 56),
              _buildTimeLimitTile(),
              const Divider(height: 1, indent: 56),
              _actionTile(
                icon: Icons.school_rounded,
                iconColor: const Color(0xFF4CAF50),
                title: 'Change Child\'s Class',
                subtitle: 'Currently: Class $childClass',
                onTap: _changeClass,
                showArrow: true,
              ),
              const Divider(height: 1, indent: 56),
              _actionTile(
                icon: Icons.lock_rounded,
                iconColor: Colors.red.shade600,
                title: 'Lock App Now',
                subtitle: 'Child must ask you to unlock',
                onTap: _lockNow,
                showArrow: false,
                trailingWidget: Icon(Icons.chevron_right,
                    color: Colors.red.shade300),
              ),
            ],
          ]),

          if (_isSetUp && _remainingMinutes != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _primary.withValues(alpha: 0.25), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_rounded, color: _primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Time remaining today: $_remainingMinutes min',
                    style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // ── Progress Report ──────────────────────────────────────────────
          _sectionHeader('📊  Progress Report'),
          _actionCard([
            _actionTile(
              icon: Icons.radar_rounded,
              iconColor: const Color(0xFF9C27B0),
              title: 'View Progress Chart',
              subtitle: 'Radar chart of all subjects (PIN required)',
              onTap: _viewProgressReport,
              showArrow: true,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Session ──────────────────────────────────────────────────────
          _sectionHeader('🔑  Account'),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            child: ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Sign Out?', style: TextStyle(fontWeight: FontWeight.bold)),
                    content: const Text('Are you sure you want to sign out of GyanYatra?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  await userProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
                  }
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out of GyanYatra'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.red.shade100, width: 1.5),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Reusable widgets ────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _darkText,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _actionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: _primary, size: 22),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: _darkText, fontSize: 14)),
          if (onEdit != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onEdit,
              child: Icon(Icons.edit_rounded,
                  size: 18, color: _primary.withValues(alpha: 0.6)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
    Widget? trailingWidget,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _darkText,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            trailingWidget ??
                (showArrow
                    ? Icon(Icons.chevron_right,
                        color: Colors.grey.shade400)
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLimitTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.timer_rounded,
                color: Colors.orange, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Time Limit',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _darkText,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text(_formatMinutes(_timeLimitMinutes),
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          DropdownButton<int>(
            value: _timeLimitOptions.contains(_timeLimitMinutes)
                ? _timeLimitMinutes
                : 0,
            underline: const SizedBox(),
            icon:
                Icon(Icons.expand_more, color: Colors.grey.shade400),
            style: const TextStyle(
                color: _darkText,
                fontWeight: FontWeight.bold,
                fontSize: 14),
            items: _timeLimitOptions.map((m) {
              return DropdownMenuItem<int>(
                value: m,
                child: Text(_formatMinutes(m)),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) _changeTimeLimit(v);
            },
          ),
        ],
      ),
    );
  }
}
