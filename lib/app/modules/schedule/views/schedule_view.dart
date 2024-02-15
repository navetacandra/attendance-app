import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  ScheduleView({super.key});
  final selfC = Get.find<ScheduleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Management'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  StreamBuilder(
                    stream: selfC.modeStream.stream,
                    builder: (context, snapshot) {
                      if(snapshot.connectionState != ConnectionState.active || !snapshot.hasData) return Container();

                      return InkWell(
                        onTap: () => selfC.updateMode(snapshot.data?["mode"] == "presence"),
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: snapshot.data!["mode"] == "presence" ? Colors.blue : Colors.green,
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
                            child: Text(
                              snapshot.data?["mode"].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ]
              ),
              const SizedBox(height: 30),
              StreamBuilder(
                stream: selfC.scheduleDetailStream.stream,
                builder: (context, snapshot) {
                  if(snapshot.connectionState != ConnectionState.active || !snapshot.hasData) return Container();
  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        width: Get.width / 1,
                        child: Wrap(
                          direction: Axis.horizontal,
                          runAlignment: WrapAlignment.spaceBetween,
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 20,
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                const Text(
                                  "Jam Masuk Mulai",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                InkWell(
                                  onTap: () => selfC.updateScheduleDetail(snapshot.data!, "masukStart"),
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        snapshot.data?["masukStart"],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                const Text(
                                  "Jam Masuk Selesai",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                InkWell(
                                  onTap: () => selfC.updateScheduleDetail(snapshot.data!, "masukEnd"),
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        snapshot.data?["masukEnd"],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(10),
                        width: Get.width / 1,
                        child: Wrap(
                          direction: Axis.horizontal,
                          runAlignment: WrapAlignment.spaceBetween,
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 20,
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                const Text(
                                  "Jam Pulang Mulai",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                InkWell(
                                  onTap: () => selfC.updateScheduleDetail(snapshot.data!, "pulangStart"),
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        snapshot.data?["pulangStart"],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                const Text(
                                  "Jam Pulang Selesai",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                InkWell(
                                  onTap: () => selfC.updateScheduleDetail(snapshot.data!, "pulangEnd"),
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        snapshot.data?["pulangEnd"],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              ),
              const SizedBox(height: 30),
              StreamBuilder(
                stream: selfC.scheduleStream.stream,
                builder: (context, snapshot) {
                  if(
                    snapshot.connectionState != ConnectionState.active ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty
                  ) return Container();
 
                  final monthData = selfC.groupingSchedule(snapshot.data as List<Map<String, dynamic>>);
                  String upperCaseFirst(String text) => text[0].toUpperCase() + text.substring(1);
                  
                  return Column(
                    children: <Widget>[
                      for(final month in monthData.keys) ...[
                        ExpansionTile(
                          title: Text(upperCaseFirst(month)),
                          children: <Widget>[
                            for(final dates in monthData[month]!) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  for(final date in dates) ...[
                                    InkWell(
                                      onTap: () => selfC.updateSchedule(date),
                                      child: Container(
                                        width: ((Get.width-40) / 7) - 10,
                                        height: ((Get.width-40) / 7) - 10,
                                        padding: const EdgeInsets.all(10),
                                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: date["isActive"] ? Colors.green : Colors.red,
                                        ),
                                        child: Center(
                                          child: Text(
                                            date["date"],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                ],
                              )
                            ]
                          ]
                        )
                      ]
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
