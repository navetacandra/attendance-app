import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:ez_validator/ez_validator.dart';

class Student {
  String? id;
  String nis = "";
  String nama = "";
  String email = "";
  String kelas = "";
  String alamat = "";
  String telSiswa = "";
  String telWaliMurid = "";
  String telWaliKelas = "";
  String? card;

  final schema = EzSchema.shape({
    "_id": EzValidator<String>(label: "_id").minLength(32, "Id tidak valid!"),
    "nis": EzValidator<String>(label: "nis")
        .required("NIS wajib di-isi!")
        .minLength(9)
        .maxLength(9)
        .matches(RegExp(r'^\d{9}$')),
    "nama": EzValidator<String>(label: "nama")
        .required("Nama wajib di-isi!")
        .minLength(3),
    "email": EzValidator<String>(label: "email")
        .required("Email wajib di-isi!")
        .email("Email tidak valid!"),
    "kelas": EzValidator<String>(label: "kelas")
        .required("Kelas wajib di-isi")
        .minLength(6, "Kelas minimal berisi 6 karakter!"),
    "alamat": EzValidator<String>(label: "alamat")
        .required("Alamat wajib di-isi")
        .minLength(3, "Alamat minimal berisi 3 karakter!"),
    "telSiswa": EzValidator<String>(label: "telSiswa")
        .required("Telpon siswa wajib di-isi")
        .phone("Telpon siswa tidak valid!"),
    "telWaliMurid": EzValidator<String>(label: "telWaliMurid")
        .required("Telpon wali murid wajib di-isi")
        .phone("Telpon wali murid tidak valid!"),
    "telWaliKelas": EzValidator<String>(label: "telWaliKelas")
        .required("Telpon wali kelas wajib di-isi")
        .phone("Telpon wali kelas tidak valid!"),
  });

  Student({
    this.id,
    this.card,
    required this.nis,
    required this.nama,
    required this.email,
    required this.kelas,
    required this.alamat,
    required this.telSiswa,
    required this.telWaliMurid,
    required this.telWaliKelas,
  });

  Student.fromJSON(Map<String, dynamic> json)
      : id = json["_id"] as String?,
        nis = json["nis"] ?? "",
        nama = json["nama"] ?? "",
        email = json["email"] ?? "",
        kelas = json["kelas"] ?? "",
        alamat = json["alamat"] ?? "",
        telSiswa = json["telSiswa"] ?? "",
        telWaliMurid = json["telWaliMurid"] ?? "",
        telWaliKelas = json["telWaliKelas"] ?? "",
        card = json["card"] as String?;

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = {
      "nis": nis,
      "nama": nama,
      "email": email,
      "kelas": kelas,
      "alamat": alamat,
      "telSiswa": telSiswa,
      "telWaliMurid": telWaliMurid,
      "telWaliKelas": telWaliKelas,
    };
    if(id != null) {
      data = {...data, "_id": id};
    }
    if(card != null) {
      data = {...data, "card": card};
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
