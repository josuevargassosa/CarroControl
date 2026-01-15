import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../controllers/car_controller.dart';
import '../data/models/maintenance_model.dart';
import '../data/models/maintenance_model.g.dart';
import '../data/models/vehicle_model.dart';
import '../data/models/vehicle_model.g.dart';

Future<void> initApp() async {
  await Hive.initFlutter();
  Hive.registerAdapter(VehicleModelAdapter());
  Hive.registerAdapter(MaintenanceModelAdapter());
  await Hive.openBox<VehicleModel>('vehicles');
  await Hive.openBox<MaintenanceModel>('maintenances');
  Get.put(CarController());
}
