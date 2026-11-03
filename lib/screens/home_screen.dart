import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme/app_theme.dart';
import '../repositories/firebase_auth_repository.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'list_screen.dart';

/// Next-Generation Landing Presentation View for RecipeBox
/// Author: Nguyen Vinh Phu (QE180136)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authGateway = FirebaseAuthRepository();

    return StreamBuilder<User?>(
      stream: authGateway.userSessionStream,
      builder: (context, session) {
        if (session.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.surfaceCanvas,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryEmerald),
            ),
          );
        }

        // Redirect directly to protected recipe collection if signed in
        if (session.hasData && session.data != null) {
          return const ListScreen();
        }

        return Scaffold(
          backgroundColor: AppTheme.surfaceCanvas,
          appBar: _buildTopBar(context),
          body: const SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroPresentationHeader(),
                  SizedBox(height: 32),
                  _FeatureBentoList(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context) {
    return AppBar(
      title: const Text('RecipeBox'),
      backgroundColor: AppTheme.primaryEmerald,
      actions: [
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          child: const Text(
            'Login',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryEmerald,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _HeroPresentationHeader extends StatelessWidget {
  const _HeroPresentationHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryEmerald.withValues(alpha: 0.15),
                  AppTheme.primaryEmerald.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.soup_kitchen_rounded,
              size: 46,
              color: AppTheme.primaryEmerald,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'RecipeBox',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryEmerald,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Your personal recipe collection. Save, organize into meal categories, track cooking difficulty, and mark your favorites effortlessly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                color: Color(0xFF475569),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBentoList extends StatelessWidget {
  const _FeatureBentoList();

  @override
  Widget build(BuildContext context) {
    const features = [
      (
        index: '01',
        icon: Icons.restaurant_menu_rounded,
        title: 'Save your recipes',
        desc: 'Keep a private collection of recipes you cook or want to try.',
        accent: AppTheme.primaryEmerald,
      ),
      (
        index: '02',
        icon: Icons.timer_outlined,
        title: 'Sort by cooking time',
        desc: 'Quickly organize and view recipes ordered by shortest cook time.',
        accent: Color(0xFF0284C7),
      ),
      (
        index: '03',
        icon: Icons.star_rate_rounded,
        title: 'Mark your favorites',
        desc: 'Star your favorite dishes and filter them with a single click.',
        accent: AppTheme.accentAmber,
      ),
    ];

    return Column(
      children: features.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.accent, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.desc,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.index,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
