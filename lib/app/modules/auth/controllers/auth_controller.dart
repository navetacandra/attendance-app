import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:attendance_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final storage = GetStorage();
  final RxBool isLoading = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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


  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Please enter username!';
    if(value.length < 8) return "Username must be at least 8 characters!";
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter password!';
    if(value.length < 8) return "Password must be at least 8 characters!";
    return null;
  }

  Future<void> getUserInfo() async {
    try {
      final res = await HttpController.get("/user/info");
      if(res["code"] != 200) {
        await storage.remove("token");
        await storage.remove("user");
        return showAlert("Failed to login", res["error"]["message"], ArtSweetAlertType.danger, () {});
      }
      await storage.write("user", res["data"]);
    } catch(e) {
      await storage.remove("token");
      await storage.remove("user");
      return showAlert("Failed to login", e.toString(), ArtSweetAlertType.danger, () {});
    }
  }

  void submit() async {
    isLoading.value = true;
    if(formKey.currentState!.validate()) {
      try {
        final res = await HttpController.post("/user/signin", {"username": usernameController.text, "password": passwordController.text});
        if(res["code"] != 200) {
          return showAlert("Failed to login", res["error"]["message"], ArtSweetAlertType.danger, () {});
        }
        await storage.write("token", res["data"]["token"]);
        await getUserInfo();
        return Get.offAllNamed(Routes.HOME);
      } catch(e) {
        return showAlert("Failed to login", e.toString(), ArtSweetAlertType.danger, () {});
      } finally {
        isLoading.value = false;
      }
    }
    isLoading.value = false;
  }
}
