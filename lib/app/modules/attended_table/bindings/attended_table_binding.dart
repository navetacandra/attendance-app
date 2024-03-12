import 'package:get/get.dart';

import '../controllers/attended_table_controller.dart';

class AttendedTableBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AttendedTableController>(AttendedTableController());
  }
}
