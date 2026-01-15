import 'package:hive/hive.dart';

part 'vehicle_model.g.dart';

@HiveType(typeId: 1)
class VehicleModel extends HiveObject {
  VehicleModel({
    required this.brand,
    required this.model,
    required this.year,
    required this.purchaseCost,
    required this.currentKm,
    required this.lastUpdate,
    required this.dailyKmAverage,
  });

  @HiveField(0)
  int currentKm;

  @HiveField(1)
  DateTime lastUpdate;

  @HiveField(2)
  double dailyKmAverage;

  @HiveField(3)
  String brand;

  @HiveField(4)
  String model;

  @HiveField(5)
  int year;

  @HiveField(6)
  double purchaseCost;
}
