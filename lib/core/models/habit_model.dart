import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  int streak;

  @HiveField(4)
  DateTime? lastCompletedDay;

  Habit({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.streak = 0,
    this.lastCompletedDay,
  });
}
