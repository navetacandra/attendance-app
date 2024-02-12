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
      : id = json["_id"] as int,
        month = json["month"] as String,
        date = json["date"] as String,
        isActive = json["isActive"] as bool;

  Map<String, dynamic> toJSON() => {"_id": id, "month": month, "date": date, "isActive": isActive};
}

EzValidator<String> timeSchema(String label, String fieldName) {
  return EzValidator<String>(label: label)
      .required("Jam $fieldName wajib di-isi")
      .matches(RegExp(r'^([01][0-9]|2[0-3]):([0-5][0-9])$'),
          'Jam $fieldName tidak valid!');
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
      return data;
    }
  }
}
