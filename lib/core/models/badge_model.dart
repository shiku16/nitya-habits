import 'package:hive/hive.dart';

part 'badge_model.g.dart';

@HiveType(typeId: 1)
class Badge extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int milestone;

  @HiveField(3)
  final DateTime unlockedAt;

  Badge({
    required this.id,
    required this.title,
    required this.milestone,
    required this.unlockedAt,
  });
}
