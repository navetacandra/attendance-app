import 'dart:async';
import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:get/get.dart';

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
      percentage.value = attendedList.length / siswa.value;
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
}
