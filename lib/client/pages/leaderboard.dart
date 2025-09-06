import 'package:flutter/material.dart';
import 'package:quiz_app/auth/live_models.dart';
import 'package:quiz_app/auth/socket_service.dart';
import 'package:quiz_app/first_page.dart';

class FinalLeaderboardScreen extends StatelessWidget {
  final List<LobbyPlayer> finalLeaderboard;
  final String currentPlayerName;

  const FinalLeaderboardScreen({
    super.key,
    required this.finalLeaderboard,
    required this.currentPlayerName,
  });

  @override
  Widget build(BuildContext context) {
    // Separate the top three for the podium
    final topThree = finalLeaderboard.take(3).toList();
    final rest = finalLeaderboard.skip(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Final Results"),
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Podium for Top 3
          _Podium(topThree: topThree, currentPlayerName: currentPlayerName),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("All Scores", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          
          // List for the rest of the players
          Expanded(
            child: ListView.builder(
              itemCount: rest.length,
              itemBuilder: (context, index) {
                final player = rest[index];
                final isYou = player.name == currentPlayerName;
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 4}')), // Rank starts from 4
                  title: Text(player.name, style: TextStyle(fontWeight: isYou ? FontWeight.bold : FontWeight.normal)),
                  trailing: Text('${player.score} pts'),
                  tileColor: isYou ? Colors.blue.shade50 : null,
                );
              },
            ),
          ),
          
          // "Done" button to go home
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: () {
                LiveSocketService.instance.disconnect(); // Disconnect from the session
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const QuizFirstPage()),
                  (route) => false, // Clear navigation stack
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
              ),
              child: const Text("Finish", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Podium Widget ---
class _Podium extends StatelessWidget {
  final List<LobbyPlayer> topThree;
  final String currentPlayerName;

  const _Podium({required this.topThree, required this.currentPlayerName});

  @override
  Widget build(BuildContext context) {
    // Handle cases with fewer than 3 players
    final gold = topThree.isNotEmpty ? topThree[0] : null;
    final silver = topThree.length > 1 ? topThree[1] : null;
    final bronze = topThree.length > 2 ? topThree[2] : null;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (silver != null) _PodiumPlace(player: silver, rank: 2, color: Colors.grey.shade400, height: 120),
          if (gold != null) _PodiumPlace(player: gold, rank: 1, color: Colors.amber.shade400, height: 150),
          if (bronze != null) _PodiumPlace(player: bronze, rank: 3, color: Colors.brown.shade400, height: 100),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  final LobbyPlayer player;
  final int rank;
  final Color color;
  final double height;

  const _PodiumPlace({
    required this.player,
    required this.rank,
    required this.color,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          height: height,
          width: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: Colors.black54, width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$rank', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('${player.score} pts', style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}