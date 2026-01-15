import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../data/models/maintenance_model.dart';
import '../data/models/vehicle_model.dart';

class CarController extends GetxController {
  final Rx<VehicleModel?> vehicle = Rx<VehicleModel?>(null);
  final RxList<MaintenanceModel> history = <MaintenanceModel>[].obs;

  late final Box<VehicleModel> _vehicleBox;
  late final Box<MaintenanceModel> _maintenanceBox;

  @override
  Future<void> onInit() async {
    super.onInit();
    _vehicleBox = await Hive.openBox<VehicleModel>('vehicles');
    _maintenanceBox = await Hive.openBox<MaintenanceModel>('maintenances');

    vehicle.value = _vehicleBox.get('vehicle');
    history.assignAll(_maintenanceBox.values);
  }

  void updateMileage(int newKm) {
    final currentVehicle = vehicle.value;
    if (currentVehicle == null) {
      return;
    }

    if (newKm <= currentVehicle.currentKm) {
      return;
    }

    final now = DateTime.now();
    final daysDiff = now.difference(currentVehicle.lastUpdate).inDays;
    final kmDiff = newKm - currentVehicle.currentKm;

    var newDailyAverage = currentVehicle.dailyKmAverage;
    if (daysDiff > 0) {
      newDailyAverage = (newDailyAverage + (kmDiff / daysDiff)) / 2;
    }

    currentVehicle
      ..currentKm = newKm
      ..lastUpdate = now
      ..dailyKmAverage = newDailyAverage;

    vehicle.value = currentVehicle;
    _vehicleBox.put('vehicle', currentVehicle);
  }

  DateTime? predictNextService(int intervalKm, int lastServiceKm) {
    final currentVehicle = vehicle.value;
    if (currentVehicle == null) {
      return null;
    }

    final nextServiceKm = lastServiceKm + intervalKm;
    final kmRestantes = nextServiceKm - currentVehicle.currentKm;
    if (currentVehicle.dailyKmAverage <= 0) {
      return null;
    }

    final diasRestantes = kmRestantes / currentVehicle.dailyKmAverage;
    return DateTime.now().add(Duration(days: diasRestantes.round()));
  }
}
