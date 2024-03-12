import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AttendedTableController extends GetxController {
  final streamAttended = HttpController.streamList("/presence");
  final streamStudents = HttpController.streamList("/students");
  final panelController = PanelController();
  final students = <Map<String, dynamic>>[].obs;
  final attended = <Map<String, dynamic>>[].obs;
  final selectedId = "".obs;

  @override
  void onInit() {
    streamAttended.stream.listen((data) {
      attended.value = data;
    });
    streamStudents.stream.listen((data) {
      students.value = data;
    });
    super.onInit();
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


  void updateStatus(String status) async {
    try {
      final res = await HttpController.put("/presence-update", {"studentId": selectedId.value, "status": status});
      if(res["code"] != 200) return showAlert("Failed to updating status", res["error"]["message"], ArtSweetAlertType.danger, () {});
      return showAlert("Status updated", "", ArtSweetAlertType.success, () {});
    } catch(e) {
      return showAlert("Failed to updating status", e.toString(), ArtSweetAlertType.danger, () {});
    } finally {
      panelController.close();
    }
  }
}
