import 'package:hive/hive.dart';

part 'maintenance_model.g.dart';

@HiveType(typeId: 0)
class MaintenanceModel extends HiveObject {
  MaintenanceModel({
    required this.id,
    required this.title,
    required this.cost,
    required this.date,
    required this.kmAtService,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double cost;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int kmAtService;
}
