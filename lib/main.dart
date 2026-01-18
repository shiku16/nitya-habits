import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/models/habit_model.dart';
import 'core/models/badge_model.dart' as app_badge;
import 'core/constants/app_theme.dart';
import 'core/ui/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(app_badge.BadgeAdapter());

  await Hive.openBox<Habit>('habits');
  await Hive.openBox<app_badge.Badge>('badges');

  runApp(const NityaHabitsApp());
}


class NityaHabitsApp extends StatelessWidget {
  const NityaHabitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nitya Habits',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}