import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'list_screen.dart';

/// Public Landing Screen for RecipeBox
/// Author: Nguyen Vinh Phu (QE180136)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Checking authentication status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Active session detected -> navigate to protected recipe list screen
        if (snapshot.hasData && snapshot.data != null) {
          return const ListScreen();
        }

        // Public presentation view for unauthenticated guests
        return Scaffold(
          appBar: AppBar(
            title: const Text('RecipeBox'),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepOrange,
                  elevation: 0,
                ),
                child: const Text('Register'),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.soup_kitchen_rounded,
                    size: 72,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'RecipeBox',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your personal recipe collection. Save, organize into meal categories, track cooking difficulty, and mark your favorites effortlessly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 36),

                // 3 Required Feature Highlights
                _FeatureHighlightCard(
                  icon: Icons.restaurant_menu_rounded,
                  iconColor: Colors.deepOrange,
                  title: 'Save your recipes',
                  description: 'Keep a private collection of recipes you cook or want to try.',
                ),
                const SizedBox(height: 14),
                _FeatureHighlightCard(
                  icon: Icons.timer_outlined,
                  iconColor: Colors.blueAccent,
                  title: 'Sort by cooking time',
                  description: 'Quickly organize and view recipes ordered by shortest cook time.',
                ),
                const SizedBox(height: 14),
                _FeatureHighlightCard(
                  icon: Icons.star_rate_rounded,
                  iconColor: Colors.amber.shade700,
                  title: 'Mark your favorites',
                  description: 'Star your favorite dishes and filter them with a single click.',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeatureHighlightCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _FeatureHighlightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
