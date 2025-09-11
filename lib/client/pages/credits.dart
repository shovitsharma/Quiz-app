import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_app/first_page.dart'; // Make sure this path is correct

// --- DATA MODEL (Updated: imageUrl is removed) ---
class DeveloperInfo {
  final String name;
  final String role;

  DeveloperInfo({required this.name, required this.role});
}

// --- MAIN WIDGET ---
class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  late final ScrollController _scrollController;

  // Updated: The list no longer contains image URLs.
  final List<DeveloperInfo> _developers = [
    DeveloperInfo(name: 'Shovit Sharma', role: 'Flutter Developer'),
    DeveloperInfo(name: 'Sarania Madhurjya', role: 'Flutter Developer'),
    DeveloperInfo(name: 'Anurag Sharma', role: 'Backend & API Developer'),
    DeveloperInfo(name: 'Vansh Bagra', role: 'Cloud Manager'),
    DeveloperInfo(name: 'Diksha', role: 'UI/UX Designer'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final scrollDuration = Duration(seconds: _developers.length * 1);

        _scrollController.animateTo(
          maxScroll,
          duration: scrollDuration,
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return QuizPageTemplate(
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height, bottom: 100),
            itemCount: _developers.length,
            itemBuilder: (context, index) {
              return _DeveloperCredit(developer: _developers[index]);
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const QuizFirstPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Back to Home', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// --- SUPPORTING WIDGETS ---

/// A widget to display a single developer's credit information.
class _DeveloperCredit extends StatelessWidget {
  final DeveloperInfo developer;
  const _DeveloperCredit({required this.developer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          // REMOVED: The CircleAvatar widget is no longer here.
          const SizedBox(height: 16),
          Text(
            developer.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            developer.role,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

// --- TEMPLATE WIDGET (Included here to prevent errors) ---

class QuizPageTemplate extends StatelessWidget {
  final Widget child;
  const QuizPageTemplate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackgroundCircles(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircles() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -150,
          child: _BlendedCircle(color: Colors.yellow.shade600, size: 300),
        ),
        Positioned(
          top: -80,
          left: -100,
          right: 2,
          child: _BlendedCircle(color: Colors.red.shade400, size: 200),
        ),
        Positioned(
          bottom: -100,
          right: -150,
          child: _BlendedCircle(color: Colors.green.shade400, size: 300),
        ),
        Positioned(
          bottom: -80,
          right: -100,
          left: 2,
          child: _BlendedCircle(color: Colors.blue.shade300, size: 200),
        ),
      ],
    );
  }
}

class _BlendedCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _BlendedCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        backgroundBlendMode: BlendMode.multiply,
      ),
    );
  }
}

