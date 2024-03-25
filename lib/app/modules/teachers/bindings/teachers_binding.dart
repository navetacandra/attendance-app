import 'package:get/get.dart';

import '../controllers/teachers_controller.dart';

class TeachersBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TeachersController>(TeachersController());
  }
}
