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
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    studentStream.close();
  }

  void showAlert(BuildContext context, String title, String text,
      ArtSweetAlertType type, Function onDispose) {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        type: type,
        title: title,
        text: text,
        onDispose: onDispose,
      ),
    );
  }

  void deleteStudent(BuildContext context) async {
    try {
      final result =
          await HttpController.delete("/student/${selectedStudent["_id"]}");
      if (result["code"] == 200) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlert(
            context,
            "Student Deleted",
            "",
            ArtSweetAlertType.success,
            () => panelController.close(),
          );
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlert(
            context,
            "Failed Delete Student",
            result["error"]["message"],
            ArtSweetAlertType.danger,
            () {},
          );
        });
      }
    } catch (e) {
      print(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert(
          context,
          "Failed Delete Student",
          e.toString(),
          ArtSweetAlertType.danger,
          () {},
        );
      });
    }
  }
}
