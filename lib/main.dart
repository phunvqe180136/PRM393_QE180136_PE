import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

/// RecipeBox Application Entry Point
/// Developed by Nguyen Vinh Phu (QE180136) for PRM393 Practical Exam
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase client service
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RecipeBoxApp());
}

class RecipeBoxApp extends StatelessWidget {
  const RecipeBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: RecipeAppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
