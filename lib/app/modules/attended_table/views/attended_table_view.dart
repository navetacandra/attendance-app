import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../controllers/attended_table_controller.dart';

class AttendedTableView extends GetView<AttendedTableController> {
  AttendedTableView({super.key});
  final selfC = Get.find<AttendedTableController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if(didPop) return;
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
        maxHeight: Get.height / 2,
        backdropEnabled: true,
        onPanelClosed: () => selfC.selectedId.value = "",
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
        panel: Container(
          height: Get.height / 2,
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
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                actionStatus(status: "tepat", label: "Tepat"),
                actionStatus(status: "telat", label: "Telat"),
                actionStatus(status: "sakit", label: "Sakit"),
                actionStatus(status: "izin", label: "Izin"),
                actionStatus(status: "tanpa keterangan", label: "Tanpa Keterangan"),
              ],
            ),
          ),
        ),
        body: Scaffold(
          appBar: AppBar(
            title: const Text('Attendance'),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() =>
                  DataTable(
                    columns: <DataColumn>[
                      headerCell("No"),
                      headerCell("Nama"),
                      headerCell("Kelas"),
                      headerCell("Jam Masuk"),
                      headerCell("Jam Pulang"),
                      headerCell("Status"),
                    ],
                    rows: <DataRow>[
                      ...selfC.students.asMap().entries.map((student) {
                        final Map<String, dynamic>? attendedInfo = selfC.attended.where((at) => at["studentId"] == student.value["_id"]).firstOrNull;

                        return dataRow(
                          index: student.key+1, 
                          id: student.value["_id"], 
                          name: student.value["nama"], 
                          className: student.value["kelas"], 
                          inTime: attendedInfo?["masuk"] ?? "-", 
                          outTime: attendedInfo?["pulang"] ?? "-", 
                          status: attendedInfo?["status"] ?? "-",
                        );
                      }),
                    ],
                  ),
                ),
              ),
            )
          ),
        ),
      ),
    );
  }

  Material actionStatus({ required String status, required String label }) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.black26,
        onTap: () => selfC.updateStatus(status),
        child: Container(
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black38, 
              width: 3,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataColumn headerCell(String title) {
    return DataColumn(
      label: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  DataRow dataRow({
    required int index,
    required String id,
    required String name,
    required String className,
    required String inTime,
    required String outTime,
    required String status
  }) {
    InkWell label(String text) {
      return InkWell(
        onTap: () {
          selfC.selectedId.value = id;
          selfC.panelController.open();
        },
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
      );
    }

    return DataRow(
      cells: <DataCell>[
        DataCell(label('$index')),
        DataCell(label(name)),
        DataCell(label(className)),
        DataCell(label(inTime)),
        DataCell(label(outTime)),
        DataCell(label(status)),
      ],
    );
  }
}
