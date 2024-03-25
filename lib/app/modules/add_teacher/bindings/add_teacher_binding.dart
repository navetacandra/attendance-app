import 'package:get/get.dart';

import '../controllers/add_teacher_controller.dart';

class AddTeacherBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AddTeacherController>(AddTeacherController());
  }
}
