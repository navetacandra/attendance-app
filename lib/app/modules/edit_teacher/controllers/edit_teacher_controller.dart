import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:attendance_app/app/data/teachers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditTeacherController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final formControllers = {
    "nama": TextEditingController(),
    "kelas": TextEditingController(),
    "tel": TextEditingController(),
  };
  final RxMap formErrors = {}.obs;
  final RxBool isLoading = false.obs;
  var currentTeacher = {}; 

  Future<bool> getTeacher() async {
    final response = await HttpController.get("/teacher/${Get.arguments["id"]}");
    if (response["code"] != 200) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert("Failed Get Teacher", response["error"]["message"], ArtSweetAlertType.danger, () => Get.back());
      });
      return false;
    } else {
      currentTeacher = response["data"];
      final dataKeys = formControllers.keys.toList();

      for (var key in currentTeacher.keys.toList()) {
        if(dataKeys.contains(key)) {
          formControllers[key]!.text = response["data"][key];
        }
      }
      return true;
    }
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

void submit() async {
    isLoading.value = true;
    final dataKeys = formControllers.keys.toList();
    Map<String, dynamic> data = {};
    formErrors.value = {};

    for (var key in dataKeys) {
      data[key] = formControllers[key]?.value.text;
    }

    final dataTeacher = Teacher.fromJSON(data);
    final validated = dataTeacher.validate();
    
    var errCount = 0;
    final phones = {"tel": "Nomor telpon"};
    Map<String, dynamic> tmpFormErrors = {};
    
    if (validated["errors"] != null) {
      for (var key in dataKeys) {
        errCount++;
        tmpFormErrors[key] = validated["errors"][key];
      }
    }
 
    for (var phone in phones.keys) {
      if(tmpFormErrors[phone] != null) continue;
      final validated = await Teacher.validatePhone(phones[phone] ?? "", formControllers[phone]?.value.text ?? "");
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

    final result = await HttpController.put("/teacher/${Get.arguments["id"]}", dataTeacher.toJSON());
    if (result["code"] == 200) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert("Teacher Updated", "", ArtSweetAlertType.success, () => Get.back());
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert("Failed Update Teacher", result["error"]["message"], ArtSweetAlertType.danger, () {});
      });
    }
    isLoading.value = false;
  }
}
