import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider_simple.dart';

class ClassSelectionScreen extends StatelessWidget {
  const ClassSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final name = args['name'] as String;
    final age = args['age'] as int;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF81D4FA),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                      color: Colors.white,
                    ),
                    const Expanded(
                      child: Text(
                        'Choose Your Class',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for centering
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Hi $name! What class are you in?',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: _buildClassCard(context, 1, name, age)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildClassCard(context, 2, name, age)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: _buildClassCard(context, 3, name, age)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildClassCard(context, 4, name, age)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          children: [
                            const Spacer(flex: 1),
                            Expanded(flex: 2, child: _buildClassCard(context, 5, name, age)),
                            const Spacer(flex: 1),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, int classLevel, String name, int age) {
    Color cardColor;
    
    switch (classLevel) {
      case 1:
        cardColor = const Color(0xFFFFD700); // Sunny Yellow
        break;
      case 2:
        cardColor = const Color(0xFF90EE90); // Lush Green
        break;
      case 3:
        cardColor = const Color(0xFF87CEEB); // Sky Blue
        break;
      case 4:
        cardColor = const Color(0xFFFFA07A); // Light Salmon
        break;
      case 5:
      default:
        cardColor = const Color(0xFFDDA0DD); // Plum
        break;
    }

    return Consumer<UserProviderSimple>(
      builder: (context, userProvider, child) {
        return GestureDetector(
          onTap: () async {
            // Create child profile here now that class is chosen
            await userProvider.createChildProfile(
              name: name,
              age: age,
              classLevel: classLevel,
              avatar: 'mountain',
            );
            
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: cardColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: cardColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'CLASS',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  classLevel.toString(),
                  style: const TextStyle(
                    fontSize: 56,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF64655C),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
