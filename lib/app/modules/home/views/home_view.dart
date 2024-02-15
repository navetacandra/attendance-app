import 'package:attendance_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});
  final PanelController _pc = PanelController();
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        final action = _pc.isPanelOpen ? _pc.close : Get.back;
        action();
      },
      child: SlidingUpPanel(
        defaultPanelState: PanelState.CLOSED,
        controller: _pc,
        isDraggable: false,
        minHeight: 0,
        maxHeight: Get.height * 0.8,
        panel: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
        body: Scaffold(
          body: SafeArea(
            child: Wrap(
              direction: Axis.horizontal,
              children: <Widget>[
                ElevatedButton(
                  child: const Text("STUDENTS"),
                  onPressed: () {
                    Get.toNamed(Routes.STUDENTS);
                  },
                ),
                ElevatedButton(
                  child: const Text("CARDS"),
                  onPressed: () {
                    Get.toNamed(Routes.CARDS); 
                  },
                ),
                ElevatedButton(
                  child: const Text("WHATSAPP"),
                  onPressed: () {
                    Get.toNamed(Routes.WHATSAPP); 
                  },
                ),
                ElevatedButton(
                  child: const Text("SCHEDULE"),
                  onPressed: () {
                    Get.toNamed(Routes.SCHEDULE); 
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
