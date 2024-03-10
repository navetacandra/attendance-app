import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:attendance_app/app/data/students.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class EditStudentController extends GetxController {
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
  var currentStudent = {};
  final RxMap formErrors = {}.obs;
  final RxBool isLoading = false.obs;

  Future<bool> getStudent(BuildContext context) async {
    final response = await HttpController.get("/student/${Get.arguments["id"]}");
    if (response["code"] != 200) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert(context, "Failed Get Student", response["error"]["message"], ArtSweetAlertType.danger, () => Get.back());
      });
      return false;
    } else {
      currentStudent = response["data"];
      final dataKeys = formControllers.keys.toList();

      for (var key in currentStudent.keys.toList()) {
        if(dataKeys.contains(key)) {
          formControllers[key]!.text = response["data"][key];
        }
      }
      return true;
    }
  }

  void showAlert(BuildContext context, String title, String text, ArtSweetAlertType type, Function onDispose) {
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
    isLoading.value = true;
    final dataKeys = formControllers.keys.toList();
    Map<String, dynamic> data = {};
    formErrors.value = {};

    for (var key in dataKeys) {
      data[key] = formControllers[key]?.value.text;
    }
    final dataStudent = Student.fromJSON(data);
    final validated = dataStudent.validate();
    
    var errCount = 0;
    final phones = {"telSiswa": "Telpon siswa", "telWaliMurid": "Telpon wali murid", "telWaliKelas": "Telpon wali kelas"};
    Map<String, dynamic> tmpFormErrors = {};

    if (validated["errors"] != null) {
      for (var key in dataKeys) {
        errCount++;
        tmpFormErrors[key] = validated["errors"][key];
      }
    }

    for (var phone in phones.keys) {
      if(tmpFormErrors[phone] != null || formControllers[phone]?.value.text == currentStudent[phone]) continue;
      final validated = await Student.validatePhone(phones[phone] ?? "", formControllers[phone]?.value.text ?? "");
      if(validated != null) {
        errCount++;
        tmpFormErrors[phone] = validated;
      }
    }

    if(errCount > 0) {
      formErrors.value = tmpFormErrors;
      isLoading.value = false;
      return;
    }

    final result = await HttpController.put("/student/${Get.arguments["id"]}", dataStudent.toJSON());
    if (result["code"] == 200) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert(context, "Student Updated", "", ArtSweetAlertType.success, () => Get.back());
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert(context, "Failed Update Student", result["error"]["message"], ArtSweetAlertType.danger, () {});
      });
    }
    isLoading.value = false;
  }
}
