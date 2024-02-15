import 'package:ez_validator/ez_validator.dart';

class Schedule {
  int id = 0;
  String month = "";
  String date = "";
  bool isActive = false;

  Schedule({
    required this.id,
    required this.date,
    required this.month,
    required this.isActive,
  });

  Schedule.fromJSON(Map<String, dynamic> json)
      : id = json["_id"] ?? 0,
        month = json["month"] ?? "",
        date = json["date"] ?? "",
        isActive = json["isActive"] ?? false;

  Map<String, dynamic> toJSON() => {"_id": id, "month": month, "date": date, "isActive": isActive};
}

EzValidator<String> timeSchema(String label, String fieldName) {
  return EzValidator<String>(label: label)
      .required("Jam $fieldName wajib di-isi")
      .matches(RegExp(r'^([01][0-9]|2[0-3]):([0-5][0-9])$'),
          'Jam $fieldName tidak valid!');
}

int compareTime(List time1, List time2) {
  if(time1[0] < time2[0]) return -1;
  if(time1[0] == time2[0]) {
    if(time1[1] < time2[1]) return -1;
    else if(time1[1] > time2[1]) return 1;
    else return 0;
  }
  if(time1[0] > time2[0]) return 1;
  return 0;
}


class ScheduleDetail {
  String masukStart = "";
  String masukEnd = "";
  String pulangStart = "";
  String pulangEnd = "";

  final schema = EzSchema.shape({
    "masukStart": timeSchema("masukStart", "masuk mulai"),
    "masukEnd": timeSchema("masukEnd", "masuk selesai"),
    "pulangStart": timeSchema("pulangStart", "pulang mulai"),
    "pulangEnd": timeSchema("pulangEnd", "pulang selesai"),
  });

  ScheduleDetail({
    required this.masukStart,
    required this.masukEnd,
    required this.pulangStart,
    required this.pulangEnd,
  });

  ScheduleDetail.fromJSON(Map<String, dynamic> json)
      : masukStart = json["masukStart"] as String,
        masukEnd = json["masukEnd"] as String,
        pulangStart = json["pulangStart"] as String,
        pulangEnd = json["pulangEnd"] as String;

  Map<String, dynamic> toJSON() => {
        "masukStart": masukStart,
        "masukEnd": masukEnd,
        "pulangStart": pulangStart,
        "pulangEnd": pulangEnd
      };

  validate() {
    final (data, errors) = schema.validateSync(toJSON());
    if (errors.keys.toList().isNotEmpty) {
      return {"errors": errors};
    } else {
      int errCount = 0;
      Map<String, dynamic> error = {};
      final keys = data.keys.toList();
      for(var i = 0; i < keys.length; i++) {
        if(i == 0) {
          final time1 = data[keys[i]].split(":").map(int.parse).toList().map((time) => time as int).toList();
          final time2 = data[keys[i + 1]].split(":").map(int.parse).toList().map((time) => time as int).toList();
          if(compareTime(time2, time1) < 1) {
            errCount++;
            if(error[keys[i]] == null) {
              error[keys[i]] = "${keys[i]} equal or more than ${keys[i + 1]}";
            }
          }
        } else if(i == keys.length-1) {
          final time1 = data[keys[i - 1]].split(":").map(int.parse).toList().map((time) => time as int).toList();
          final time2 = data[keys[i]].split(":").map(int.parse).toList().map((time) => time as int).toList();
          if(compareTime(time2, time1) < 1) {
            errCount++;
            if(error[keys[i]] == null) {
              error[keys[i]] = "${keys[i]} equal or less than ${keys[i - 1]}";
            }
          }
        } else {
          final time0 = data[keys[i - 1]].split(":").map(int.parse).toList().map((time) => time as int).toList();
          final time1 = data[keys[i]].split(":").map(int.parse).toList().map((time) => time as int).toList();
          final time2 = data[keys[i + 1]].split(":").map(int.parse).toList().map((time) => time as int).toList();
          if(compareTime(time1, time0) < 1) {
            errCount++;
            if(error[keys[i]] == null) {
              error[keys[i]] = "${keys[i]} equal or less than ${keys[i - 1]}";
            }
          } else if(compareTime(time1, time2) > -1) {
            errCount++;
            if(error[keys[i]] == null) {
              error[keys[i]] = "${keys[i]} equal or more than ${keys[i + 1]}";
            }
          }
        }
      }
      if(errCount > 0) return {"error": error};
      return data;
    }
  }
}
