import 'package:universal_html/html.dart';
import 'dart:io' as io;
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

class ReportController extends GetxController {
  final months = [
    "januari",
    "februari",
    "maret",
    "april",
    "mei",
    "juni",
    "juli",
    "agustus",
    "september",
    "oktober",
    "november",
    "desember"
  ];
  final selectedMonth = "".obs;
  final selectedKelas = "".obs;
  final dates = [].obs;
  final kelas = ["All"].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    initDates();
    getKelas();
    super.onInit();
  }

  void initDates() {
    var selectedMonthIndex = months.indexOf(selectedMonth.value);
    if(selectedMonthIndex < 1 || selectedMonthIndex > months.length-1) {
      selectedMonth.value = months[0];
      selectedMonthIndex = 0;
    }
    final datesInMonth = selectedMonthIndex == 1 
      ? 29
      : selectedMonthIndex < 7
        ? selectedMonthIndex % 2 == 0
          ? 31
          : 30
        : selectedMonthIndex % 2 == 0
          ? 30
          : 31;
    dates.value = [];
    for(var i = 0; i < (datesInMonth/7).ceil(); i++) {
      if(7 + i*7 > datesInMonth) {
        dates.add(
          List.generate(datesInMonth-i*7, (index) => {"date": index + 1 + i*7, "selected": false})
        );
      } else {
        dates.add(
          List.generate(7, (index) => {"date": index + 1 + i*7, "selected": false})
        );
      }
    }
    dates.refresh();
  }

  void getKelas() async {
    try {
      final response = await HttpController.get("/students/kelas");
      if(response["code"] != 200) {
        return showAlert("Failed get available \"kelas\"", response["error"]["message"], ArtSweetAlertType.danger, () {});
      }
      for(final tmpKelas in response["data"]) {
        kelas.add(tmpKelas);
      }
    } catch(err) {
      logger.e(err);
      return showAlert("Failed get available \"kelas\"", "", ArtSweetAlertType.danger, () {});
    }
  }

  void showAlert(String title, String text, ArtSweetAlertType type, Function? onDispose) {
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

  Future<String> downloadPath() async {
    if(kIsWeb) return '';
    if(io.Platform.isAndroid) return '/sdcard/download/';
    return (await getDownloadsDirectory())!.path;
  }

  void downloadInWeb(String apiPath, String filename) {
    final anchor = AnchorElement(
      href: "${HttpController.apiUrl}$apiPath"
    )
    ..setAttribute('download', filename)
    ..style.display = 'none';
    document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  }

  void download() async {
    isLoading.value = true;
    final selectedDates = dates.expand((date) => date).where((date) => date["selected"]).map((date) => date["date"] as int).toList();
    if(selectedDates.isEmpty) {
      showAlert("Failed request download", "No dates selected", ArtSweetAlertType.danger, () {});
      isLoading.value = false;
      return;
    }

    final filename = "${
      selectedKelas.toUpperCase().replaceAll(RegExp(r' '), '')
    }_${selectedMonth.value.toUpperCase()}_${selectedDates.first}-${selectedDates.last}_${
      DateTime.now().millisecondsSinceEpoch
    }.xlsx";
    final path = "/presence-report?month=${selectedMonth.value}&dates=${selectedDates.join(",")}&kelas=${
      Uri.encodeComponent(selectedKelas.isEmpty ? kelas.first : selectedKelas.value)
    }";
    
    try {
      if(kIsWeb) return downloadInWeb(path, filename);
      final filepath = "${await downloadPath()}${io.Platform.pathSeparator}$filename";

      final download = await HttpController.download(path, filepath);
      if(!download) return showAlert("Failed request download", "", ArtSweetAlertType.danger, () {});
      return showAlert("Success request download", "File downloaded\n$filepath", ArtSweetAlertType.success, () {});
    } catch(err) {
      logger.e("Error download request $path");
      return showAlert("Failed request download", err.toString(), ArtSweetAlertType.danger, () {});
    } finally {
      isLoading.value = false;
    }
  }
}
