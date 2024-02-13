import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CardsController extends GetxController {
  final cardsStream = HttpController.streamList("/cards");
  final panelController = PanelController();
  final selectedCard = {}.obs;

  @override
  void onClose() {
    super.onClose();
    cardsStream.close();
  }
}
