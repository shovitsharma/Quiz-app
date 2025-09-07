import 'package:flutter/material.dart';
import 'package:quiz_app/auth/live_models.dart';
import 'package:quiz_app/auth/socket_service.dart';
import 'package:quiz_app/client/pages/thankyou_page.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // The same red curved background from the quiz screen
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Header ---
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      "Final Results",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // --- Leaderboard Card ---
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: ListView.separated(
                        itemCount: finalLeaderboard.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final player = finalLeaderboard[index];
                          return _PlayerTile(
                            player: player,
                            rank: index + 1,
                            isCurrentUser: player.name == currentPlayerName,
                          );
                        },
                      ),
                    ),
                  ),

                  // --- "Finish" Button ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: ElevatedButton(
                      onPressed: () {
                        LiveSocketService.instance.disconnect(); // Disconnect from the session
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const ThankYouPage()),
                          (route) => false, // Clear navigation stack
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400, // Matching color
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Matching shape
                        ),
                      ),
                      child: const Text(
                        "Finish",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the red curved shape in the background. (Copied from TakeQuizScreen)
  Widget _buildBackground() {
    return ClipPath(
      clipper: _BackgroundClipper(),
      child: Container(
        height: 200,
        color: Colors.red.shade400,
      ),
    );
  }
}


// --- Custom Player Tile Widget ---
class _PlayerTile extends StatelessWidget {
  final LobbyPlayer player;
  final int rank;
  final bool isCurrentUser;

  const _PlayerTile({
    required this.player,
    required this.rank,
    this.isCurrentUser = false,
  });

  Widget _getRankIcon() {
    switch (rank) {
      case 1:
        return const Text("🥇", style: TextStyle(fontSize: 24));
      case 2:
        return const Text("🥈", style: TextStyle(fontSize: 24));
      case 3:
        return const Text("🥉", style: TextStyle(fontSize: 24));
      default:
        return Text(
          '$rank',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlightColor = isCurrentUser ? Colors.blue.shade50 : null;
    final fontWeight = isCurrentUser ? FontWeight.bold : FontWeight.normal;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: highlightColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Center(child: _getRankIcon())),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(fontSize: 18, fontWeight: fontWeight),
            ),
          ),
          Text(
            '${player.score} pts',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}


// A custom clipper to create the curved background shape. (Copied from TakeQuizScreen)
class _BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}