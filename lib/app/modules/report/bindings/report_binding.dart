import 'package:get/get.dart';

import '../controllers/report_controller.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ReportController>(ReportController());
  }
}
