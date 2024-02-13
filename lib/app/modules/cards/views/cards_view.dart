import 'package:attendance_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../controllers/cards_controller.dart';

class CardsView extends GetView<CardsController> {
  CardsView({super.key});
  final selfC = Get.find<CardsController>();
  final addStudentPressed = false.obs;
  final pickStudentPressed = false.obs;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final action = selfC.panelController.isPanelOpen
            ? selfC.panelController.close
            : Get.back;
        action();
      },
      child: SlidingUpPanel(
        controller: selfC.panelController,
        defaultPanelState: PanelState.CLOSED,
        isDraggable: false,
        minHeight: 0,
        maxHeight: Get.height / 4,
        backdropEnabled: true,
        onPanelClosed: () => selfC.selectedCard.value = {},
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 8,
            color: Colors.black38,
            offset: Offset(0, 0),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        panel: panelWidget(),
        body: Scaffold(
          appBar: AppBar(
            title: const Text('Cards'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: StreamBuilder(
                  stream: selfC.cardsStream.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      final cards = snapshot.data
                          ?.where((card) => card["removeContent"] != true)
                          .toList();
                      if (cards!.isNotEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: cards
                              .map((card) => InkWell(
                                    onTap: () {
                                      selfC.selectedCard.value = card;
                                      selfC.panelController.open();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 100,
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        boxShadow: const <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.black38,
                                            blurRadius: 4,
                                            spreadRadius: 4,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "TAG: ${card["tag"] ?? "-"}",
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "No Cards",
                            style: TextStyle(fontSize: 25),
                          ),
                        );
                      }
                    } else {
                      return Container();
                    }
                  }),
            ),
          ),
        ),
      ),
    );
  }

  Container panelWidget() {
    return Container(
      height: Get.height / 4,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      decoration: const BoxDecoration(
        color: Color.fromARGB(250, 255, 255, 255),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Material(
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.green,
              hoverDuration: const Duration(milliseconds: 225),
              onTap: () async {
                addStudentPressed.value = true;
                await Future.delayed(const Duration(milliseconds: 225));
                addStudentPressed.value = false;
                selfC.panelController.close();
                Get.toNamed(
                  Routes.ADD_STUDENT,
                  arguments: {"card": selfC.selectedCard["tag"]},
                );
              },
              child: Obx(
                () => Container(
                  width: double.infinity,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: addStudentPressed.isTrue
                        ? Colors.green
                        : Colors.transparent,
                    border: Border.all(
                      color: Colors.green,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Add New Student",
                      style: TextStyle(
                        color: addStudentPressed.isTrue
                            ? Colors.white
                            : Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Material(
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.blue,
              hoverDuration: const Duration(milliseconds: 225),
              onTap: () async {
                pickStudentPressed.value = true;
                await Future.delayed(const Duration(milliseconds: 225));
                pickStudentPressed.value = false;
                selfC.panelController.close();
                Get.toNamed(
                  Routes.PICK_STUDENT,
                  arguments: {"card": selfC.selectedCard["tag"]},
                );
              },
              child: Obx(
                () => Container(
                  width: double.infinity,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: pickStudentPressed.isTrue
                        ? Colors.blue
                        : Colors.transparent,
                    border: Border.all(
                      color: Colors.blue,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Choose Exists Student",
                      style: TextStyle(
                        color: pickStudentPressed.isTrue
                            ? Colors.white
                            : Colors.blue,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
