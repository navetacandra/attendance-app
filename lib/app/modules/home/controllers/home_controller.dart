import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // final streamStudent = HttpController.streamList("/students");

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    // streamStudent.close();
  }

  void increment() => count.value++;
}
