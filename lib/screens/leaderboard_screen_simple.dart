import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider_simple.dart';
import '../services/firebase_service.dart';

class LeaderboardScreenSimple extends StatefulWidget {
  final bool isEmbedded;
  const LeaderboardScreenSimple({super.key, this.isEmbedded = false});

  @override
  State<LeaderboardScreenSimple> createState() => _LeaderboardScreenSimpleState();
}

class _LeaderboardScreenSimpleState extends State<LeaderboardScreenSimple> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProviderSimple>(context);
    final childClass = userProvider.user?.classLevel ?? 1;

    final content = Column(
      children: [
        // Header info about the current class leaderboard
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Class $childClass Superstars',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ),
        
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: FirebaseService().getLeaderboard(childClass),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final leaderboard = snapshot.data ?? [];
              
              if (leaderboard.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No rankings for Class $childClass yet',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Top 3 Podium
                  if (leaderboard.length >= 3)
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildPodiumItem(leaderboard[1], 2, Colors.grey.shade400),
                          _buildPodiumItem(leaderboard[0], 1, Colors.yellow.shade600),
                          _buildPodiumItem(leaderboard[2], 3, Colors.brown.shade400),
                        ],
                      ),
                    ),

                  // Leaderboard List
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: leaderboard.length,
                        itemBuilder: (context, index) {
                          final user = leaderboard[index];
                          return LeaderboardTile(
                            rank: index + 1,
                            user: user,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );

    if (widget.isEmbedded) return content;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('GyanYatra Leaderboard'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: content,
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> user, int rank, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: color, width: 3),
          ),
          child: Icon(
            Icons.person,
            size: 40,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user['name'].toString().split(' ')[0],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.yellow.shade600,
              size: 16,
            ),
            const SizedBox(width: 2),
            Text(
              '${user['xp']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LeaderboardTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> user;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    Color rankColor = Colors.grey.shade600;
    IconData rankIcon = Icons.numbers;
    
    if (rank == 1) {
      rankColor = Colors.yellow.shade600;
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = Colors.grey.shade400;
      rankIcon = Icons.workspace_premium;
    } else if (rank == 3) {
      rankColor = Colors.brown.shade400;
      rankIcon = Icons.military_tech;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              rankIcon,
              color: rankColor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // User Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade200,
            child: Icon(
              Icons.person,
              size: 24,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.school,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Level ${user['level']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.red.shade600,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${user['xp']}',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
