import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:get/get.dart';

class StudentTableController extends GetxController {
  final streamStudents = HttpController.streamList("/students");
  final students = [].obs;

  @override
  void onInit() {
    streamStudents.stream.listen((studentz) {
      students.value = studentz;
    });
    super.onInit();
  }

  @override
  void onClose() {
    streamStudents.close();
    super.onClose();
  }
}
