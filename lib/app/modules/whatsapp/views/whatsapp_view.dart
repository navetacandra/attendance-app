import 'package:attendance_app/app/controllers/http_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/whatsapp_controller.dart';

class WhatsappView extends GetView<WhatsappController> {
  WhatsappView({super.key});
  final selfC = Get.find<WhatsappController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: StreamBuilder(
            stream: selfC.whatsappStream.stream,
            builder: (context, snapshot) {
              if(snapshot.connectionState != ConnectionState.active) return Container();
              if(!snapshot.hasData || (snapshot.data?["qrcode"] ?? snapshot.data?["user"]) == null) return Container();

              String formatJid2Phone(String jid) {
                final regex = RegExp(r'^(\d{2})(\d{3})(\d{4})(\d+)$');
                final match = regex.stringMatch(jid);
  
                if(match == null) {
                  return jid;
                } else {
                  return jid.replaceAllMapped(regex, (match) => "+${match.group(1)} ${match.group(2)}-${match.group(3)}-${match.group(4)}");
                }
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: !snapshot.data?["isReady"]  ? <Widget>[
                  Center(
                    child: Image.network(
                      "${HttpController.apiUrl}/whatsapp/qrcode?${snapshot.data?["qrcode"] ?? ""}",
                      fit: BoxFit.cover,
                      width: 300,
                      height: 300,
                    ),
                  ),
                ] : <Widget>[
                  Container(
                    width: Get.width / 3,
                    height: Get.width / 3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        )
                      ]
                    ),
                    child: snapshot.data?["imgUrl"] != null
                      ? Image.network(snapshot.data?["imgUrl"]) 
                      : Icon(
                          Icons.person,
                          size: Get.width / 4,
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 75),
                  Text(
                    "Loged in as ${snapshot.data?["user"]["name"] ?? "-"}",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    formatJid2Phone((snapshot.data?["user"]["id"] ?? "0").toString().split(RegExp(r':')).first),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async => await selfC.logout(),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "Log Out",
                          style: TextStyle(
                           color: Colors.white,
                           fontSize: 20,
                           fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              );
            }
          )
        ),
      ),
    );
  }
}
