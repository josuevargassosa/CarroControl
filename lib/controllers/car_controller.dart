import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

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
    _vehicleBox = Hive.box<VehicleModel>('vehicles');
    _maintenanceBox = Hive.box<MaintenanceModel>('maintenances');

    vehicle.value = _vehicleBox.get('vehicle');
    history.assignAll(_maintenanceBox.values);
  }

  void updateMileage(int newKm) {
    final currentVehicle = vehicle.value;
    if (currentVehicle == null) {
      return;
    }

    if (newKm < currentVehicle.currentKm) {
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

  void registerVehicle({
    required String brand,
    required String model,
    required int year,
    required double purchaseCost,
    required int currentKm,
  }) {
    final now = DateTime.now();
    final newVehicle = VehicleModel(
      brand: brand,
      model: model,
      year: year,
      purchaseCost: purchaseCost,
      currentKm: currentKm,
      lastUpdate: now,
      dailyKmAverage: 0,
    );
    vehicle.value = newVehicle;
    _vehicleBox.put('vehicle', newVehicle);
  }

  void addMaintenance({
    required String title,
    required double cost,
    required DateTime date,
    required int kmAtService,
  }) {
    final currentVehicle = vehicle.value;
    if (currentVehicle == null) {
      return;
    }

    if (kmAtService > currentVehicle.currentKm) {
      updateMileage(kmAtService);
    }

    final maintenance = MaintenanceModel(
      id: const Uuid().v4(),
      title: title,
      cost: cost,
      date: date,
      kmAtService: kmAtService,
    );

    _maintenanceBox.add(maintenance);
    history.add(maintenance);
    history.sort((a, b) => b.date.compareTo(a.date));
    history.refresh();
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
