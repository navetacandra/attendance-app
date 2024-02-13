import 'package:attendance_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../controllers/students_controller.dart';

class StudentsView extends GetView<StudentsController> {
  StudentsView({super.key});
  final selfC = Get.find<StudentsController>();
  final RxBool deleteButtonPressed = false.obs;
  final RxBool editButtonPressed = false.obs;

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
        onPanelClosed: () => selfC.selectedStudent.value = {},
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
        panel: panelWidget(context),
        body: Scaffold(
          appBar: AppBar(
            title: const Text('Students'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: StreamBuilder(
                  stream: selfC.studentStream.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      final students = snapshot.data
                          ?.where((student) => student['removeContent'] != true)
                          .toList();
                      selfC.students.value = students ?? [];
                      if (students!.isNotEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: students
                              .map((student) => studentCard(
                                    id: student["_id"],
                                    nama: student["nama"],
                                    kelas: student["kelas"],
                                    nis: student["nis"],
                                    email: student["email"],
                                  ))
                              .toList(),
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "No Students",
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
          floatingActionButton: FloatingActionButton(
            onPressed: () => Get.toNamed(Routes.ADD_STUDENT),
            backgroundColor: Colors.blue.shade400,
            tooltip: 'Add Student',
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  InkWell studentCard(
      {required String id,
      required String nama,
      required String kelas,
      required String nis,
      required String email}) {
    return InkWell(
      onTap: () {
        selfC.selectedStudent.value =
            selfC.students.firstWhereOrNull((student) => student['_id'] == id);
        selfC.panelController.open();
      },
      child: Container(
        width: double.infinity,
        height: 102,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      width: constraints.maxWidth * .6,
                      child: Text(
                        nama,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth * .3,
                      child: Text(
                        kelas,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: constraints.maxWidth * .6,
                  child: Text(
                    "NIS: $nis",
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth * .6,
                  child: Text(
                    "Email: $email",
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container panelWidget(BuildContext context) {
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
              splashColor: Colors.red,
              hoverDuration: const Duration(milliseconds: 225),
              onTap: () async {
                deleteButtonPressed.value = true;
                await Future.delayed(const Duration(milliseconds: 225));
                deleteButtonPressed.value = false;
                selfC.deleteStudent(context);
              },
              child: Obx(
                () => Container(
                  width: double.infinity,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: deleteButtonPressed.isTrue
                        ? Colors.red
                        : Colors.transparent,
                    border: Border.all(
                      color: Colors.red,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Delete Student",
                      style: TextStyle(
                        color: deleteButtonPressed.isTrue
                            ? Colors.white
                            : Colors.red,
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
              splashColor: Colors.amber.shade600,
              hoverDuration: const Duration(milliseconds: 225),
              onTap: () async {
                editButtonPressed.value = true;
                await Future.delayed(const Duration(milliseconds: 225));
                editButtonPressed.value = false;
                selfC.panelController.close();
                Get.toNamed(Routes.EDIT_STUDENT,
                    arguments: {"id": selfC.selectedStudent["_id"]});
              },
              child: Obx(
                () => Container(
                  width: double.infinity,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: editButtonPressed.isTrue
                        ? Colors.amber.shade600
                        : Colors.transparent,
                    border: Border.all(
                      color: Colors.amber.shade600,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Edit Student",
                      style: TextStyle(
                        color: editButtonPressed.isTrue
                            ? Colors.white
                            : Colors.amber.shade600,
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
