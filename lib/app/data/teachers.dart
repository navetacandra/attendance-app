import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:ez_validator/ez_validator.dart';

class Teacher {
  String? id;
  String nama = "";
  String kelas = "";
  String tel = "";

  final schema = EzSchema.shape({
    "_id": EzValidator<String>(label: "_id").minLength(32, "Id tidak valid!"),
    "nama": EzValidator<String>(label: "nama")
        .required("Nama wajib di-isi!")
        .minLength(3),
    "kelas": EzValidator<String>(label: "kelas")
        .required("Kelas wajib di-isi")
        .minLength(6, "Kelas minimal berisi 6 karakter!"),
    "tel": EzValidator<String>(label: "tel")
        .required("Nomor telpon wajib di-isi")
        .phone("Nomor telpon tidak valid!"),
  });

  Teacher({
    this.id,
    required this.nama,
    required this.kelas,
    required this.tel,
  });

  Teacher.fromJSON(Map<String, dynamic> json)
      : id = json["_id"] as String?,
        nama = json["nama"] ?? "",
        kelas = json["kelas"] ?? "",
        tel = json["tel"] ?? "";

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = {
      "nama": nama,
      "kelas": kelas,
      "tel": tel
    };
    if(id != null) {
      data = {...data, "_id": id};
    }
    return data;
  }

  validate() {
    final (data, errors) = schema.validateSync(toJSON());
    if (errors.keys.toList().isNotEmpty) {
      return {"errors": errors};
    } else {
      return data;
    }
  }

  static Future<String?> validatePhone(String label, String phone) async {
    String? result;
    if(phone.length < 10 || phone.length > 15) result = "$label tidak valid!";
    try {
      final response = await HttpController.get("/on-whatsapp/$phone");
      if(response["code"] == 200) {
        result = null;
      } else if(response["code"] == 400) {
        if(response["error"]["code"] == "WHATSAPP_NOT_READY") {
          result = "WhatsApp tidak tersedia";
        }
        result = "$label tidak valid!";
      } else if(response["code"] == 404) {
        result = "$label tidak ditemukan!";
      } else if(response["code"] == 500) {
        result = "Kesalahan validasi $label";
      }
    } catch (e) {
      logger.e(e);
      result = "Kesalahan validasi $label";
    }
    
    return result;
  }
}
