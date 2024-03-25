import 'package:get/get.dart';

import '../controllers/edit_teacher_controller.dart';

class EditTeacherBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<EditTeacherController>(EditTeacherController());
  }
}
