import 'package:get/get.dart';

import '../controllers/edit_student_controller.dart';

class EditStudentBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<EditStudentController>(EditStudentController());
  }
}
