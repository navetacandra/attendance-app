import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class StudentsController extends GetxController {
  final studentStream = HttpController.streamList("/students");
  final panelController = PanelController();
  final RxList students = [].obs;
  final RxMap selectedStudent = {}.obs;

  @override
  void onInit() {
    studentStream.stream.listen((studentz) {
      students.value = studentz;
    });
    super.onInit();
  }

  @override
  void onClose() {
    studentStream.close();
    super.onClose();
  }

  void showAlert(String title, String text, ArtSweetAlertType type, Function onDispose) {
    ArtSweetAlert.show(
      context: Get.context!,
      artDialogArgs: ArtDialogArgs(
        type: type,
        title: title,
        text: text,
        onDispose: onDispose,
      ),
    );
  }

  void deleteStudent() async {
    try {
      final result = await HttpController.delete("/student/${selectedStudent["_id"]}");
      if (result["code"] == 200) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlert("Student Deleted", "", ArtSweetAlertType.success, () => panelController.close());
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlert("Failed Delete Student", result["error"]["message"], ArtSweetAlertType.danger, () {});
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert("Failed Delete Student", e.toString(), ArtSweetAlertType.danger, () {});
      });
    }
  }
}
