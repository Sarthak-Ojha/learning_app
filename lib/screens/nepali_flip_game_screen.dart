import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/user_provider_simple.dart';

class NepaliFlipGameScreen extends StatefulWidget {
  final int classLevel;

  const NepaliFlipGameScreen({super.key, required this.classLevel});

  @override
  State<NepaliFlipGameScreen> createState() => _NepaliFlipGameScreenState();
}

class _NepaliFlipGameScreenState extends State<NepaliFlipGameScreen> {
  // Full Nepali Consonants Pool (36 letters)
  final List<String> _alphabetPool = [
    'क', 'ख', 'ग', 'घ', 'ङ', 
    'च', 'छ', 'ज', 'झ', 'ञ', 
    'ट', 'ठ', 'ड', 'ढ', 'ण', 
    'त', 'थ', 'द', 'ध', 'न', 
    'प', 'फ', 'ब', 'भ', 'म', 
    'य', 'र', 'ल', 'व', 'श', 
    'ष', 'स', 'ह', 'क्ष', 'त्र', 'ज्ञ'
  ];

  late List<String> _letters;
  late List<bool> _cardFlipped;
  late List<bool> _cardMatched;
  int? _firstSelectedIndex;
  bool _isProcessing = false;
  int _moves = 0;
  int _matches = 0;
  final int _totalPairs = 10; // 20 cards total (4x5)

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    // 1. Pick 10 random unique letters from the pool
    List<String> pool = List.from(_alphabetPool)..shuffle();
    List<String> selected = pool.take(_totalPairs).toList();
    
    // 2. Double them to create pairs and shuffle
    _letters = [...selected, ...selected]..shuffle();
    
    // 3. Reset state
    _cardFlipped = List.generate(_totalPairs * 2, (index) => false);
    _cardMatched = List.generate(_totalPairs * 2, (index) => false);
    _firstSelectedIndex = null;
    _isProcessing = false;
    _moves = 0;
    _matches = 0;
  }

  void _onCardTap(int index) {
    if (_isProcessing || _cardFlipped[index] || _cardMatched[index]) return;

    setState(() {
      _cardFlipped[index] = true;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _moves++;
      _isProcessing = true;
      int firstIndex = _firstSelectedIndex!;
      
      if (_letters[firstIndex] == _letters[index]) {
        // Match!
        setState(() {
          _cardMatched[firstIndex] = true;
          _cardMatched[index] = true;
          _matches++;
          _firstSelectedIndex = null;
          _isProcessing = false;
        });

        if (_matches == _totalPairs) {
          _onGameComplete();
        }
      } else {
        // No match
        Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _cardFlipped[firstIndex] = false;
              _cardFlipped[index] = false;
              _firstSelectedIndex = null;
              _isProcessing = false;
            });
          }
        });
      }
    }
  }

  void _onGameComplete() {
    final provider = Provider.of<UserProviderSimple>(context, listen: false);
    provider.addXP(30);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Column(
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 60),
            SizedBox(height: 12),
            Text('Congratulations!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'You matched all $_totalPairs Nepali letter pairs in $_moves moves!\nYou earned 30 XP! 🌟',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _setupGame();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Play Again!'),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Nepali Flip & Pair', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statHeader('Moves', '$_moves'),
                    _statHeader('Matches', '$_matches/$_totalPairs'),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double width = constraints.maxWidth;
                    final double height = constraints.maxHeight;
                    // For a 4x5 grid (20 cards)
                    const int columns = 4;
                    const int rows = 5;
                    final double cardWidth = (width - (columns + 1) * 8) / columns;
                    final double cardHeight = (height - (rows + 1) * 8) / rows;
                    final double aspectRatio = cardWidth / cardHeight;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(), // Fit exactly
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: _totalPairs * 2,
                        itemBuilder: (context, index) {
                          return _buildCard(index, cardWidth > 100);
                        },
                      ),
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Match two identical Nepali letters to clear them!',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statHeader(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCard(int index, bool largeSize) {
    bool isFlipped = _cardFlipped[index] || _cardMatched[index];
    
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _cardMatched[index] 
              ? Colors.green.shade400 
              : (isFlipped ? Colors.white : const Color(0xFF0277BD)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: isFlipped 
              ? Text(
                  _letters[index],
                  style: TextStyle(
                    fontSize: largeSize ? 36 : 28,
                    fontWeight: FontWeight.bold,
                    color: _cardMatched[index] ? Colors.white : const Color(0xFF1976D2),
                  ),
                )
              : const Icon(Icons.help_outline_rounded, color: Colors.white38, size: 24),
        ),
      ),
    );
  }
}
