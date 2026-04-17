import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nitya_habits/core/models/badge_model.dart' as app_badge;
import 'package:nitya_habits/core/models/habit_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Habit> habitBox;
  final TextEditingController _controller = TextEditingController();
void checkForBadgeUnlock(int streak) {
  final badgeBox = Hive.box<app_badge.Badge>('badges');

  void unlock(String id, String title, String emoji) {
    if (!badgeBox.containsKey(id)) {
      final badge = app_badge.Badge(
        id: id,
        title: title,
        milestone: streak,
        unlockedAt: DateTime.now(),
      );

      badgeBox.put(id, badge);

      _showBadgeUnlocked(context, title, emoji);
    }
  }

  if (streak >= 3) unlock('3_days', '3 Day Streak', '🔥');
  if (streak >= 7) unlock('7_days', '7 Day Streak', '🏆');
  if (streak >= 21) unlock('21_days', '21 Day Streak', '💎');
}

late Box<app_badge.Badge> badgeBox;

@override
void initState() {
  super.initState();
  habitBox = Hive.box<Habit>('habits');
  badgeBox = Hive.box<app_badge.Badge>('badges');
}


  // 🔁 RESET STREAK IF DAY MISSED
  void resetDailyCompletion() {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  for (final habit in habitBox.values) {
    // Reset daily completion
    if (habit.lastCompletedDay != todayDate) {
      habit.isCompleted = false;
      habit.save();
    }

    // Missed day reset (already logic)
    if (habit.lastCompletedDay != null) {
      final diff =
          todayDate.difference(habit.lastCompletedDay!).inDays;

      if (diff >= 2) {
        habit.streak = 0;
        habit.save();
      }
    }
  }
}
void toggleHabit(Habit habit) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  setState(() {
    if (!habit.isCompleted) {
      // Completing habit
      if (habit.lastCompletedDay == null ||
          habit.lastCompletedDay != todayDate) {
        habit.streak += 1;
        checkForBadgeUnlock(habit.streak);
        habit.lastCompletedDay = todayDate;
        if (habit.streak == 3 || habit.streak == 7 || habit.streak == 21) {
          _showCelebration(habit.streak);
        }
      }

      habit.isCompleted = true;
    } else {
      // Unchecking habit (same day undo)
      habit.isCompleted = false;
    }

    habit.save();
  });
}

void _showCelebration(int streak) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text('🎉 Congratulations!'),
      content: Text(
        'You’ve achieved a $streak-day streak!\nKeep going 💪',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Awesome!'),
        ),
      ],
    ),
  );
}


Widget buildHabitTile(Habit habit) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    padding: const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(
      color: habit.isCompleted
          ? Colors.green.withOpacity(0.10)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: habit.isCompleted
            ? Colors.green
            : Colors.grey.shade300,
      ),
    ),
    child: ListTile(
      title: Text(
        habit.title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
          color: habit.isCompleted ? Colors.green.shade700 : Colors.black,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            habit.streak > 0
                ? '🔥 ${habit.streak} day streak'
                : 'Start today',
            style: TextStyle(
              color: habit.streak > 0 ? Colors.orange : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          buildBadge(habit.streak),
          const SizedBox(height: 6),
          buildStreakProgress(habit.streak),
        ],
      ),
      trailing: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: habit.isCompleted ? 1.15 : 1.0,
        ),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Checkbox(
          value: habit.isCompleted,
          activeColor: Colors.green,
          onChanged: (_) => toggleHabit(habit),
        ),
      ),
      onTap: () => toggleHabit(habit),
    ),
  );
}
Widget _buildProgress(Box<Habit> box) {
  final total = box.length;
  final completed =
      box.values.where((h) => h.isCompleted).length;

  final progress = total == 0 ? 0.0 : completed / total;

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$completed of $total habits completed',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.green.shade100,
                valueColor: const AlwaysStoppedAnimation(Colors.green),
              );
            },
          ),
        ),
      ],
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Today'),
    ),

  body: ValueListenableBuilder(
    valueListenable: habitBox.listenable(),
    builder: (context, Box<Habit> box, _) {
      if (box.isEmpty) {
        return Center(
          child: _buildEmptyState(),
        );
      }

      return Column(
        children: [
          _buildProgress(box),
          Expanded(
            child: ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final habit = box.getAt(index)!;

                return Dismissible(
                  key: ValueKey(habit.key),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    final deletedHabit = habit;
                    final deletedKey = habit.key;

                    habitBox.delete(deletedKey);

                    // Clear any existing SnackBars to prevent stacking
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Habit deleted'),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'UNDO',
                          textColor: Colors.green,
                          onPressed: () {
                            habitBox.put(deletedKey, deletedHabit);
                            // Hide the SnackBar after undo
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                  },
                  child: buildHabitTile(habit),
                );
              },
            ),
          ),
        ],
      );
    },
  ),
      floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.green,
      onPressed: showAddHabitSheet,
      child: const Icon(Icons.add),
    ),
  );
}

Widget _buildEmptyState() {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 500),
    builder: (context, value, _) {
      return Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.self_improvement,
                  size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text(
                'Start with one small habit 🌱',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'Consistency beats intensity',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showAddHabitSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'New Habit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter habit name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addHabit,
              child: const Text('Add Habit'),
            ),
          ],
        ),
      );
    },
  );
}

void _addHabit() {
  if (_controller.text.trim().isEmpty) return;

  final habit = Habit(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: _controller.text.trim(),
  );

  habitBox.put(habit.id, habit);
  _controller.clear();
  Navigator.pop(context);
}
}
int getBadgeLevel(int streak) {
  if (streak >= 30) return 4; // Legend
  if (streak >= 14) return 3; // Warrior
  if (streak >= 7) return 2;  // Consistent
  if (streak >= 3) return 1;  // Starter
  return 0;
}
Widget buildBadge(int streak) {
  final level = getBadgeLevel(streak);

  if (level == 0) return const SizedBox.shrink();

  final badges = {
    1: ('🌱', 'Starter'),
    2: ('🔥', 'Consistent'),
    3: ('⚔️', 'Warrior'),
    4: ('👑', 'Legend'),
  };

  return Row(
    children: [
      Text(
        badges[level]!.$1,
        style: const TextStyle(fontSize: 18),
      ),
      const SizedBox(width: 6),
      Text(
        badges[level]!.$2,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.green,
        ),
      ),
    ],
  );
}
void _showBadgeUnlocked(BuildContext context, String title, String emoji) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text('$emoji Badge Unlocked!'),
      content: Text(
        'You earned the "$title" badge.\nKeep building habits 💪',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Awesome'),
        ),
      ],
    ),
  );
}
Widget buildStreakProgress(int streak) {
  const milestones = [3, 7, 21];
  final next = milestones.firstWhere(
    (m) => streak < m,
    orElse: () => milestones.last,
  );

  final progress = (streak / next).clamp(0.0, 1.0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '🔥 $streak / $next day streak',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        backgroundColor: Colors.grey.shade300,
        valueColor: const AlwaysStoppedAnimation(Colors.orange),
      ),
    ],
  );
}
Widget badgeTile({
  required String title,
  required String emoji,
  required bool unlocked,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: unlocked ? Colors.orange.shade50 : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Text(
          unlocked ? emoji : '🔒',
          style: const TextStyle(fontSize: 26),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: unlocked ? Colors.black : Colors.grey,
          ),
        ),
      ],
    ),
  );
}
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final badgeBox = Hive.box<app_badge.Badge>('badges');

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Achievements'),
      ),
      body: ValueListenableBuilder(
        valueListenable: badgeBox.listenable(),
        builder: (context, Box<app_badge.Badge> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'No badges yet',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: box.values.map((b) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: badgeTile(
                  title: b.title,
                  emoji: getBadgeEmoji(b.title),
                  unlocked: box.containsKey(b.id),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
String getBadgeEmoji(String title) {
  if (title.contains('3')) return '🔥';
  if (title.contains('7')) return '🏆';
  if (title.contains('21')) return '💎';
  return '🏅';
}

