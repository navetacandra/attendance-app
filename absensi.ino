#include <ESP8266WebServer.h>
#include <DNSServer.h>
#include <Arduino_JSON.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>
#include <LiquidCrystal_I2C.h>
#include <LittleFS.h>
#include <MFRC522.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <SPI.h>

const uint8_t SDA_PIN = D4;
const uint8_t RST_PIN = D3;
String months[12] = { "januari", "februari", "maret", "april", "mei", "juni", "juli", "agustus", "september", "oktober", "november", "desember" };
String serverUrl = "http://192.168.100.3:3000/api/v1/presence";
String ssid, pass, ipaddress;
bool connected, welcomeMessage;

IPAddress apIp(192, 168, 50, 50);
IPAddress subnet(255, 255, 255, 0);
LiquidCrystal_I2C lcd(0x27, 16, 2);
MFRC522 mfrc522(SDA_PIN, RST_PIN);
ESP8266WebServer server(80);
DNSServer dnsServer;
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");

String padString(String str, int targetLength, char padChar) {
  String result = "";
  for (int i = 0; i < targetLength - str.length(); i++) {
    result += padChar;
  }
  result += str;
  return result;
}

void lcdPrintCenter(int cursorY, String text) {
  int leftSpaces = (16 - text.length()) / 2;
  lcd.setCursor(leftSpaces, cursorY);
  lcd.print(text);
}

void lcdPrintWrap(String text) {
  int startIndex = 0;
  int cursorY = 0;
  for(int i = 0; i < text.length(); i++) {
    if(i - startIndex >= 16) {
      lcd.setCursor(0, cursorY+1);
      startIndex = i;
      cursorY += 1;
    }
    lcd.print(text[i]);
  }
}

void setup() {
  Serial.begin(115200);

  pinMode(D8, OUTPUT);
  lcd.begin();
  lcd.backlight();

  if (!LittleFS.begin()) {
    Serial.println("An error has occurred while mounting LittleFS");
    lcdPrintWrap("LittleFS not mounted");
  } else {
    Serial.println("LittleFS mounted successfully");
  }

  SPI.begin();
  mfrc522.PCD_Init();
  mfrc522.PCD_DumpVersionToSerial();

  ssid = readFile(LittleFS, "/ssid.txt");
  pass = readFile(LittleFS, "/pass.txt");

  lcd.clear();
  lcdPrintCenter(0, "Menghubungkan");
  if (!initWiFi()) {
    handleNetworkConnecting();
  }
  if(connected){
    handleNetworkConnection();
  }

  server.on("/file-state", HTTP_GET, []() {
    String content = "{";
    content += "\"ssid\": \"";
    content += ssid;
    content += "\",";
    content += "\"password\": \"";
    content += pass;
    content += "\"}";
    server.send(200, "application/json", content);
  });

  server.on("/is-esp", HTTP_GET, []() {
    server.send(200, "application/json", "{\"isEsp\": true}");
  });

  server.on("/is-connected", HTTP_GET, []() {
    server.send(200, "application/json", connected ? "{\"isConnected\": true}" : "{\"isConnected\": false}");
  });

  server.begin();
  dnsServer.start(53, "connection.config", apIp);
}

void loop() {
  server.handleClient();
  dnsServer.processNextRequest();
  if(connected) {
    if(WiFi.status() != WL_CONNECTED) {
      lcd.clear();
      lcd.print("Connection lost");
      delay(1000);
      ESP.reset();
    }
  
    if(!welcomeMessage) {
      welcomeMessage = true;
      lcd.clear();
      lcdPrintCenter(0, "Tap Kartu");
    }

    String tag = readCardTag(); 
    if(tag.length() < 1) return;

    welcomeMessage = false;
    lcd.clear();
    lcdPrintCenter(0, "Memproses");

    BEEP(100, 1);
    int startFetch = millis();
    httpRequest(tag, serverUrl + "?nocache=" + String(startFetch));
    int timeUsed = millis() - startFetch;
    delay(800 - timeUsed < 200 ? 200 : 800 - timeUsed);
    BEEP(300, 2);
  }
}

void BEEP(int duration, int time) {
  int delayDuration = duration/time/2;
  for(int x = 0; x < time; x++) {
    digitalWrite(D8, 1);
    delay(delayDuration);
    digitalWrite(D8, 0);
    delay(delayDuration);
  }
}
