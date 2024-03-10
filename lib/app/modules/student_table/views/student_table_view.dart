import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/student_table_controller.dart';

class StudentTableView extends GetView<StudentTableController> {
  StudentTableView({super.key});
  final selfC = Get.find<StudentTableController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() =>
              DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Expanded(
                      child: Text("No", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text("NIS", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text("Nama", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text("Kelas", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text("Alamat", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text("Card", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ], 
                rows: <DataRow>[
                  for(var i = 0; i < selfC.students.length; i++) ...[
                    dataStudent(
                      color: selfC.students[i]["card"] == null && (i == 0 || selfC.students[i-1]["card"] != null)
                        ? Colors.blue
                        : Colors.white,
                      no: i+1,
                      nis: selfC.students[i]["nis"] ?? "-",
                      nama: selfC.students[i]["nama"] ?? "-",
                      email: selfC.students[i]["email"] ?? "-",
                      kelas: selfC.students[i]["kelas"] ?? "-",
                      alamat: selfC.students[i]["alamat"] ?? "-",
                      card: selfC.students[i]["card"] ?? "-",
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow dataStudent({
    required Color color,
    required int no,
    required String nis,
    required String nama,
    required String email,
    required String kelas,
    required String alamat,
    required String card,
  }) {
    return DataRow(
      color: MaterialStatePropertyAll(color),
      cells: <DataCell>[
        DataCell(Text("$no")),
        DataCell(Text(nis)),
        DataCell(Text(nama)),
        DataCell(Text(email)),
        DataCell(Text(kelas)),
        DataCell(Text(alamat)),
        DataCell(Text(card)),
      ],
    );
  }
}
