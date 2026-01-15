import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../data/models/maintenance_model.dart';

class CarController extends GetxController {
  final RxList<MaintenanceModel> history = <MaintenanceModel>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    final box = await Hive.openBox<MaintenanceModel>('maintenance');
    history.assignAll(box.values);
  }
}
