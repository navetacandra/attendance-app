import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:attendance_app/app/data/students.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class PickStudentController extends GetxController {
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
  final students = <Map<String, dynamic>>[].obs;
  final selectedStudent = <String, dynamic>{}.obs;

  @override
  void onInit() async {
    super.onInit();
    if (Get.arguments?["card"] != null) {
      card = Get.arguments["card"];
      formControllers["card"] =
          TextEditingController(text: Get.arguments["card"]);
    }

    try {
      students.value = await getStudents(Get.context as BuildContext);
    } catch (err) {
      showAlert(Get.context as BuildContext, "Failed get students", "",
          ArtSweetAlertType.danger, () => Get.back());
    }
  }

  Future<List<Map<String, dynamic>>> getStudents(BuildContext context) async {
    final response = await HttpController.get("/students");
    if (response["code"] != 200) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert(
          context,
          "Failed Get Student",
          response["error"]["message"],
          ArtSweetAlertType.danger,
          () => Get.back(),
        );
      });
    } else if ((response["data"] as List).isEmpty) {
      throw "no data";
    }
    return (response["data"] as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }

  List<DropdownMenuItem> buildMenu() {
    final uniqueStudents = Set.from(students.map((student) => student));
    return uniqueStudents
        .map((student) => student as Map<String, dynamic>)
        .where((student) => student["card"] == null)
        .map(
          (student) => DropdownMenuItem(
            value: student,
            child:
                Text("${student["nama"] ?? "-"} (${student["kelas"] ?? "-"})"),
          ),
        )
        .toList();
  }

  void changeSelection(Map<String, dynamic> student) {
    selectedStudent.value = student;
    formControllers["nis"]!.text = student["nis"];
    formControllers["nama"]!.text = student["nama"];
    formControllers["email"]!.text = student["email"];
    formControllers["kelas"]!.text = student["kelas"];
    formControllers["alamat"]!.text = student["alamat"];
    formControllers["telSiswa"]!.text = student["telSiswa"];
    formControllers["telWaliKelas"]!.text = student["telWaliKelas"];
    formControllers["telWaliMurid"]!.text = student["telWaliMurid"];
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
    final result = await HttpController.put(
        "/student/${selectedStudent["_id"]}", dataStudent.toJSON());
    if (result["code"] == 200) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert(
          context,
          "Student Updated",
          "",
          ArtSweetAlertType.success,
          () => Get.back(),
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert(
          context,
          "Failed Update Student",
          result["error"]["message"],
          ArtSweetAlertType.danger,
          () {},
        );
      });
    }
  }
}
