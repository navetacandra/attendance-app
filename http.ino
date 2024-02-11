void httpRequest(String tag, String serverUrl) {
  WiFiClient client;
  HTTPClient http;

  timeClient.update();
  time_t epochTime = timeClient.getEpochTime();
  struct tm *ptm = gmtime((time_t *)&epochTime);
  String currentMonth = months[ptm->tm_mon];
  String monthDate = String(ptm->tm_mday);
  String currentHour = String(timeClient.getHours());
  String currentMinute = String(timeClient.getMinutes());
  String time = padString(currentHour, 2, '0') + ":" + padString(currentMinute, 2, '0');
  String requestData = "{\"time\": \"" + time + "\", \"month\": \"" + currentMonth + "\", \"date\": \"" + monthDate + "\", \"tag\": \"" + tag + "\"}";

  http.setReuse(false);
  http.begin(client, serverUrl.c_str());
  http.addHeader("Content-Type", "application/json");
  int httpResponseCode = http.POST(requestData);
  
  if(httpResponseCode > 0) {
    lcd.clear();
    lcdPrintWrap(parseResponse(http.getString()));
  } else {
    Serial.println("Error post: " + String(httpResponseCode));
    lcd.clear();
    lcdPrintWrap("Terjadi Kesalahan Pada Sistem");
  }

  http.end();
}

String parseResponse(String _payload) {
  JSONVar payload = JSON.parse(_payload);
  
  if(payload.hasOwnProperty("data")) {
    if(JSON.typeof(payload["data"]["tag"]) == "string") return "Kartu Berhasil Ditambahkan";

    String action = payload["data"]["action"];
    String status = payload["data"]["status"];
    status.toUpperCase();
    if(action == "masuk") return "Berhasil Absen Hadir Status " + status;
    else if(action == "pulang") return "Berhasil Absen Pulang";
  }

  if(payload.hasOwnProperty("error")) {
    String code = payload["error"]["code"];
    if(code == "CARD_NOT_REGISTERED") return "Kartu Belum Terdaftar";
    else if(code == "CARD_ALREADY_REGISTERED") return "Kartu Sudah Terdaftar";
    else if(code == "CARD_ALREADY_ADDED") return "Kartu Sudah Ditambahkan";
    else if(code == "PRESENCE_INACTIVE") return "Bukan Jadwal Absen";
    else if(code == "NO_SCHEDULE") return "Bukan Waktu Absen";
    else if(code == "STUDENT_ALREADY_ATTENDED") return "Sudah Melakukan Absen Kehadiran";
    else if(code == "STUDENT_ALREADY_HOME") return "Sudah Melakukan Absen Pulang";
    else return "Terjadi Kesalahan Pada Sistem";
  }
  return "";
}
