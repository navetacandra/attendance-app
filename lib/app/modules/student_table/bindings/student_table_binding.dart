import 'package:get/get.dart';

import '../controllers/student_table_controller.dart';

class StudentTableBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StudentTableController>(StudentTableController());
  }
}
