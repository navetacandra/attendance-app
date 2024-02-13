import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:attendance_app/app/data/students.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class AddStudentController extends GetxController {
  String? card;
  final formKey = GlobalKey<FormState>();
  final formControllers = {
    "nis": TextEditingController(),
    "nama": TextEditingController(),
    "email": TextEditingController(),
    "kelas": TextEditingController(),
    "alamat": TextEditingController(),
    "telSiswa": TextEditingController(),
    "telWaliMurid": TextEditingController(),
    "telWaliKelas": TextEditingController(),
  };
  final RxMap formErrors = {}.obs;

  @override
  void onInit() {
    super.onInit();
    if(Get.arguments?["card"] != null) {
      card = Get.arguments["card"];
      formControllers["card"] = TextEditingController(text: Get.arguments["card"]);
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
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

  void submit(BuildContext context) async {
    final dataKeys = formControllers.keys.toList();
    Map<String, dynamic> data = {};
    formErrors.value = {};

    for (var key in dataKeys) {
      data[key] = formControllers[key]?.value.text;
    }
    final dataStudent = Student.fromJSON(data);
    final validated = dataStudent.validate();
    if (validated["errors"] != null) {
      Map<String, dynamic> _formErrors = {};
      for (var key in dataKeys) {
        _formErrors[key] = validated["errors"][key];
      }
      formErrors.value = _formErrors;
    } else {
      final result =
          await HttpController.post("/students", dataStudent.toJSON());
      if (result["code"] == 200) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlert(
            context,
            "Student Added",
            "",
            ArtSweetAlertType.success,
            () => Get.back(),
          );
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlert(
            context,
            "Failed Add Student",
            result["error"]["message"],
            ArtSweetAlertType.success,
            () {},
          );
        });
      }
    }
  }
}
