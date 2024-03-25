import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class TeachersController extends GetxController {
  final teacherStream = HttpController.streamList("/teachers");
  final panelController = PanelController();
  final RxList teachers = [].obs;
  final RxMap selectedTeacher = {}.obs;

  @override
  void onInit() {
    teacherStream.stream.listen((studentz) {
      teachers.value = studentz;
    });
    super.onInit();
  }

  @override
  void onClose() {
    teacherStream.close();
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

  void deleteTeacher() async {
    try {
      final result = await HttpController.delete("/teacher/${selectedTeacher["_id"]}");
      if (result["code"] == 200) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlert("Teacher Deleted", "", ArtSweetAlertType.success, () => panelController.close());
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlert("Failed Delete Teacher", result["error"]["message"], ArtSweetAlertType.danger, () {});
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert("Failed Delete Student", e.toString(), ArtSweetAlertType.danger, () {});
      });
    }
  }
}
