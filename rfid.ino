String readCardTag() {
  String content = "";
  if (!(!mfrc522.PICC_IsNewCardPresent() || !mfrc522.PICC_ReadCardSerial())) {
    for(byte i = 0; i < mfrc522.uid.size; i++) {
      content.concat(String(mfrc522.uid.uidByte[i] < 0x10 ? "-0" : "-"));
      content.concat(String(mfrc522.uid.uidByte[i], HEX));
    }
  }
  content.toUpperCase();
  return content;
}
