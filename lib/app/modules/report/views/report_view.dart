import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/report_controller.dart';

class ReportView extends GetView<ReportController> {
  ReportView({super.key});
  final selfC = Get.find<ReportController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Report'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Obx(() =>
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  height: 60,
                  child: DropdownButton(
                    isExpanded: true,
                    value: selfC.selectedMonth.value,
                    onChanged: (String? val) {
                      selfC.selectedMonth.value = val!;
                      selfC.initDates();
                    },
                    items: selfC.months.map((String month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text("${month[0].toUpperCase()}${month.substring(1)}"),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Obx(() =>
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  height: 60,
                  child: DropdownButton(
                    isExpanded: true,
                    value: selfC.selectedKelas.isEmpty 
                      ? selfC.kelas.first 
                      : selfC.selectedKelas.value,
                    onChanged: (String? val) => selfC.selectedKelas.value = val!,
                    items: selfC.kelas.map((String kelas) {
                      return DropdownMenuItem(
                        value: kelas,
                        child: Text(kelas),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Obx(() => 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for(var wi = 0; wi < selfC.dates.length; wi++) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          for(var di = 0; di < selfC.dates[wi].length; di++) ...[
                            InkWell(
                              onTap: () {
                                selfC.dates[wi][di]["selected"] = !selfC.dates[wi][di]["selected"];
                                selfC.dates.refresh();
                              },
                              child: Container(
                                width: ((Get.width - 40) / 7) - 10,
                                height: ((Get.width - 40) / 7) - 10,
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                decoration: BoxDecoration(
                                  color: selfC.dates[wi][di]["selected"] ? Colors.green : Colors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "${selfC.dates[wi][di]["date"]}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                    ], 
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Obx(() => 
                InkWell(
                  onTap: () => selfC.isLoading.isFalse
                    ? selfC.download()
                    : null,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                        ),
                      ],
                    ),
                    child: Center(
                      child: selfC.isLoading.isFalse
                        ? const Text(
                          "Download",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : const CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
