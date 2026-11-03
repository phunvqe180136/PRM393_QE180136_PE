import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Đang kiểm tra trạng thái đăng nhập
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Nếu đã đăng nhập -> Chuyển trực tiếp sang List screen
        if (snapshot.hasData && snapshot.data != null) {
          return const ListScreen();
        }

        // Nếu chưa đăng nhập -> Hiển thị màn hình Home công khai
        return Scaffold(
          appBar: AppBar(
            title: const Text('RecipeBox'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepOrange,
                ),
                child: const Text('Register'),
              ),
              const SizedBox(width: 12),
            ],
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.soup_kitchen_rounded,
                  size: 80,
                  color: Colors.deepOrange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'RecipeBox',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your personal recipe collection. Save, organize into meal categories, track cooking difficulty, and mark your favorites effortlessly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),
                // 3 Feature Cards
                _buildFeatureCard(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Save your recipes',
                  description: 'Keep a private collection of recipes you cook or want to try.',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.timer_outlined,
                  title: 'Sort by cooking time',
                  description: 'Quickly organize and view recipes ordered by shortest cook time.',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.star_rate_rounded,
                  title: 'Mark your favorites',
                  description: 'Star your favorite dishes and filter them with a single click.',
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.deepOrange, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
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
