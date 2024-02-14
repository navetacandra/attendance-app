import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:get/get.dart';

class WhatsappController extends GetxController {
  final whatsappStream = HttpController.streamMap("/whatsapp"); 

  Future<bool> logout() async {
    try {
      final response = await HttpController.get("/whatsapp/logout");
      
      if(response["code"] == 200) {
        Get.snackbar("Success", "WhatsApp Logout Success");
        return true;
      } else {
        Get.snackbar("Error", response["error"]["message"]);
        return false;
      }
    } catch(err) {
      Get.snackbar("Error", err.toString());
      return false;
    }
  }
}
