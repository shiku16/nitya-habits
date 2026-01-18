import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final badgeBox = Hive.box('badges');

    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Achievements')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            badgeTile(
              title: '3 Day Streak',
              emoji: '🔥',
              unlocked: badgeBox.containsKey('3_days'),
            ),
            const SizedBox(height: 12),
            badgeTile(
              title: '7 Day Streak',
              emoji: '🏆',
              unlocked: badgeBox.containsKey('7_days'),
            ),
            const SizedBox(height: 12),
            badgeTile(
              title: '21 Day Streak',
              emoji: '💎',
              unlocked: badgeBox.containsKey('21_days'),
            ),
          ],
        ),
      ),
    );
  }
}
Widget badgeTile({
  required String title,
  required String emoji,
  required bool unlocked,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: unlocked ? Colors.green.withOpacity(0.1) : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: unlocked ? Colors.green : Colors.grey,
      ),
    ),
    child: Row(
      children: [
        Text(
          emoji,
          style: TextStyle(
            fontSize: 28,
            color: unlocked ? Colors.orange : Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: unlocked ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                unlocked ? 'Unlocked 🎉' : 'Locked 🔒',
                style: TextStyle(
                  color: unlocked ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (unlocked)
          const Icon(Icons.check_circle, color: Colors.green),
      ],
    ),
  );
}
