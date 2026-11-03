import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

/// Entry bootstrap sequence for RecipeBox
/// Author: Nguyen Vinh Phu (QE180136)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const _RecipeBoxApplicationRoot());
}

class _RecipeBoxApplicationRoot extends StatelessWidget {
  const _RecipeBoxApplicationRoot();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: RecipeAppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      builder: (context, childWidget) {
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(physics: const BouncingScrollPhysics()),
          child: childWidget ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
