import 'package:attendance_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});
  final selfC = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: Get.height * .33,
              width: double.infinity,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: const Alignment(0, -1),
                    child: Container(
                      width: double.infinity,
                      height: Get.height * .32,
                      color: Colors.blue,
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, 1),
                    child: Container(
                      width: double.infinity,
                      height: Get.height * .025,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(Get.width * .5),
                          topRight: Radius.circular(Get.width * .5)
                        ),
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  height: Get.height * .20,
                  // color: Colors.red,
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  width: Get.width * .9,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(.5),
                        spreadRadius: 5,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: Get.width*.4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "Jumlah Siswa/i",
                              softWrap: true,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Obx(() =>
                              Text(
                                "${selfC.siswa.value}",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Siswa/i Terdaftar",
                              softWrap: true,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              )
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: Get.width*.4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "Persentase Kehadiran",
                              softWrap: true,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Obx(() =>
                              Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: const Alignment(0, 0),
                                    child: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: CircularProgressIndicator(
                                        value: selfC.percentage.value,
                                        color: Colors.blue,
                                        backgroundColor: Colors.grey,
                                        strokeWidth: 5,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: const Alignment(0, 0),
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 19),
                                      child: Text(
                                        "${selfC.percentage.value * 100}%",
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        )
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                  width: Get.width * .9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(.5),
                        spreadRadius: 5,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.start,
                    runSpacing: 20,
                    children: <Widget>[
                      menuItem(
                        label: "Students",
                        iconPath: "assets/users.png",
                        navigation: Routes.STUDENTS,
                      ),
                      menuItem(
                        label: "Cards", 
                        iconPath: "assets/card.png", 
                        navigation: Routes.CARDS,
                      ),
                      menuItem(
                        label: "Download Report", 
                        iconPath: "assets/note.png", 
                        navigation: Routes.REPORT,
                      ),
                      menuItem(
                        label: "Schedule Management",
                        iconPath: "assets/calendar-clock.png", 
                        navigation: Routes.SCHEDULE,
                      ),
                      menuItem(
                        label: "WhatsApp",
                        iconPath: "assets/phone.png",
                        navigation: Routes.WHATSAPP,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container menuItem({
    required String label,
    required String iconPath, 
    required String navigation
  }) {
    return Container(
      width: Get.width * .17,
      margin: EdgeInsets.symmetric(horizontal: Get.width * .024),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(3),
            margin: const EdgeInsets.only(bottom: 5),
            child: InkWell(
              onTap: () => Get.toNamed(navigation),
              child: Container(
                width: Get.width*.12,
                height: Get.width*.12,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.withOpacity(.5),
                      spreadRadius: 2,
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Image.asset(
                  iconPath,
                  width: Get.width*.12,
                  height: Get.width*.12,
                ),
              ),
            ),
          ),
          Text(
            label,
            softWrap: true,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
