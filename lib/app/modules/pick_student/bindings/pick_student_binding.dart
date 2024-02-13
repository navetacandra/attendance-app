import 'package:get/get.dart';

import '../controllers/pick_student_controller.dart';

class PickStudentBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PickStudentController>(PickStudentController());
  }
}
