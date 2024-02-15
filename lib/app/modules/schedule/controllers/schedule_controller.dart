import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:attendance_app/app/data/schedules.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleController extends GetxController {
  final scheduleStream = HttpController.streamList("/schedule");
  final scheduleDetailStream = HttpController.streamMap("/schedule-detail");
  final modeStream = HttpController.streamMap("/mode");
  final scheduleDetailLabel = {
    "masukStart": "masuk mulai",
    "masukEnd": "masuk selesai",
    "pulangStart": "pulang mulai",
    "pulangEnd": "pulang selesai",
  };

  @override
  void onClose() {
    scheduleStream.close();
    scheduleDetailStream.close();
    super.onClose();
  }

  void showAlert(String title, String text, ArtSweetAlertType type, Function onDispose) {
    ArtSweetAlert.show(
      context: Get.context as BuildContext,
      artDialogArgs: ArtDialogArgs(
        type: type,
        title: title,
        text: text,
        onDispose: onDispose,
      ),
    );
  }

  List<List<Map<String, dynamic>>> chunkingSchedule(List<Map<String, dynamic>> schedule) {
    List<List<Map<String, dynamic>>> result = [];
    for(int i = 0; i < schedule.length; i += 7) {
      final end = i + 7;
      result.add(schedule.sublist(i, end > schedule.length ? schedule.length : end));
    }
    return result;
  }

  Map<String, List<List<Map<String, dynamic>>>> groupingSchedule(List<Map<String, dynamic>> schedule) {
    Map<String, List<List<Map<String, dynamic>>>> result = {};
    final months = schedule.map((schedule) => schedule["month"]).toSet().toList();
    for(final month in months) {
      final date = schedule.where((student) => student["month"] == month).toList();
      result[month] = chunkingSchedule(date);
    }

    return result;
  }

  void updateMode(bool mode) async {
    try {
      final data = {"mode": mode ? "add" : "presence" };
      final response = await HttpController.put("/mode", data);
      if(response["code"] != 200) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlert("Failed update schedule", response["error"]["message"], ArtSweetAlertType.danger, () {});
        });
      }
    } catch(err) {
      logger.e("Error update mode: $err");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert("Failed update mode", err.toString(), ArtSweetAlertType.danger, () {});
      });
    }
  }

  void updateScheduleDetail(Map<String, dynamic> scheduleDetail, String field) async {
    try {
      final [initialHour, initialTime] = scheduleDetail[field].split(":");
      final selectedTime = await showTimePicker(
        context: Get.context  as BuildContext,
        initialTime: TimeOfDay(
          hour: int.parse(initialHour),
          minute: int.parse(initialTime),
        ),
      );
      if(selectedTime == null) return;
      final hour = selectedTime.hour.toString().padLeft(2, '0');
      final minute = selectedTime.minute.toString().padLeft(2, '0');
      final scheduleData = ScheduleDetail.fromJSON({...scheduleDetail, field: "$hour:$minute"});
      final validated = scheduleData.validate();
      
      if(validated["error"] != null) {
        final List<String> message = validated["error"][field].split(" ");
        final String targetField = scheduleDetailLabel[field] ?? "";
        final String refField = scheduleDetailLabel[message.last] ?? "";
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlert(
            "Failed update schedule detail",
            "Jam $targetField ${message.sublist(1, message.length - 1).join(" ")} Jam $refField",
            ArtSweetAlertType.danger,
            () {},
          );
        });
        return;
      }

      final response = await HttpController.put("/schedule-detail", scheduleData.toJSON());
      if(response["code"] != 200) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlert("Failed update schedule detail", response["error"]["message"], ArtSweetAlertType.danger, () {});
        });
      }
    } catch(err) {
      logger.e("Error update schedule detail: $err");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert("Failed update schedule detail", err.toString(), ArtSweetAlertType.danger, () {});
      });
    }
  }

  void updateSchedule(Map<String, dynamic> schedule) async {
    try {
      final data = {
        "month": schedule["month"],
        "date": schedule["date"],
        "isActive": "${!schedule["isActive"]}"
      };
      final response = await HttpController.put("/schedule", data);
      if(response["code"] != 200) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlert("Failed update schedule", response["error"]["message"], ArtSweetAlertType.danger, () {});
        });
      }
    } catch(err) {
      logger.e("Error update schedule: $err");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlert("Failed update schedule", err.toString(), ArtSweetAlertType.danger, () {});
      });
    }
  }
}
