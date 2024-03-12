import 'dart:async';
import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:attendance_app/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  StreamController streamSiswa = HttpController.streamList("/students");
  StreamController streamAttended = HttpController.streamList("/presence");
  RxInt siswa = 0.obs;
  RxDouble percentage = 0.0.obs;

  @override
  void onInit() {
    streamSiswa.stream.listen((siswaList) {
      siswa.value = siswaList.length;
    });
    streamAttended.stream.listen((attendedList) {
      percentage.value = attendedList.where((e) => ["tepat", "telat"].contains(e["status"])).length / siswa.value;
      if(percentage.isNaN || percentage.isInfinite) {
        percentage.value = 0;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    streamSiswa.close();
    streamAttended.close();
    super.onClose();
  }

  void signOut() async {
    final storage = GetStorage();
    try {
      final res = await HttpController.delete("/user/signout");
      if(res["code"] != 200) {
        Get.snackbar("Failed to logout", "");
        return;
      }
      await storage.remove("user");
      await storage.remove("token");
      Get.offAllNamed(Routes.AUTH);
    } catch(e) {
      Get.snackbar("Failed to logout", "");
      return;
    }
  }
}
