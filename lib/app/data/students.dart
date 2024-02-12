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
    // "card":
    //     EzValidator<String>(label: "card").matches(RegExp(r'^(-\w{2}){4}$')),
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
        nis = json["nis"] as String,
        nama = json["nama"] as String,
        email = json["email"] as String,
        kelas = json["kelas"] as String,
        alamat = json["alamat"] as String,
        telSiswa = json["telSiswa"] as String,
        telWaliMurid = json["telWaliMurid"] as String,
        telWaliKelas = json["telWaliKelas"] as String,
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
}
