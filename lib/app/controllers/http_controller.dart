import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(
    printTime: true,
    methodCount: 2,
  ),
);

class HttpController {
  static const apiUrl = 'http://192.168.100.3:3000/api/v1';

  static StreamController<List<Map<String, dynamic>>> streamList(String path) {
    StreamController<List<Map<String, dynamic>>> streamController = StreamController();
    http.Client client = http.Client();
    http.Request request = http.Request("GET", Uri.parse("$apiUrl$path"));
    request.headers.addAll({
      "Accept": "text/event-stream",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive",
    });

    logger.d("Start connection to $apiUrl$path");

    client.send(request).asStream().listen((response) {
      if (response.statusCode != 200) {
        client.close();
        throw Exception('Failed to connect to SSE: ${response.statusCode}');
      }

      response.stream.transform(utf8.decoder).transform(const LineSplitter()).listen((String line) {
        if(line.trim().isEmpty) return;
        if(line.substring(5).trim().isEmpty) return;
        try {
          final data = (jsonDecode(line.substring(5).trim()) as List<dynamic>)
            .map((item) => item as Map<String, dynamic>).toList();
          streamController.sink.add(data);
        } catch(e) {
          logger.e("$e");
        }
      }, cancelOnError: true, onError: (err) => logger.e(err));
    }, cancelOnError: true, onError: (err) => logger.e(err));

    streamController.onCancel = () => client.close();
    return streamController;
  }

  static StreamController<Map<String, dynamic>> streamMap(String path) {
    StreamController<Map<String, dynamic>> streamController = StreamController();
    http.Client client = http.Client();
    http.Request request = http.Request("GET", Uri.parse("$apiUrl$path"));
    request.headers.addAll({
      "Accept": "text/event-stream",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive",
    });
    
    logger.d("Start connection to $apiUrl$path");
    
    client.send(request).asStream().listen((response) {
      if (response.statusCode != 200) {
        client.close();
        throw Exception('Failed to connect to SSE: ${response.statusCode}');
      }

      response.stream.transform(utf8.decoder).transform(const LineSplitter()).listen((String line) {
        if(line.trim().isEmpty) return;
        if(line.substring(5).trim().isEmpty) return;
        try {
          final data = (jsonDecode(line.substring(5).trim()) as Map<String, dynamic>);
          streamController.sink.add(data);
        } catch(e) {
          logger.e("$e");
        }
      }, cancelOnError: true, onError: (err) => logger.e(err)) ;
    }, cancelOnError: true, onError: (err) => logger.e(err));

    streamController.onCancel = () => client.close();
    return streamController;
  }

  static Future<Map<String, dynamic>> get(String path) async {
    try {
      http.Response response = await http.get(Uri.parse("$apiUrl$path"), headers: {"Accept": "application/json"});
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch(err) {
      logger.e("Error GET on $apiUrl$path: $err");
      throw Exception(err);
    }
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    try {
      http.Response response = await http.post(Uri.parse("$apiUrl$path"), body: body);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch(err) {
      logger.e("Error POST on $apiUrl$path: $err");
      throw Exception(err);
    }
  }

  static Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    try {
      http.Response response = await http.put(Uri.parse("$apiUrl$path"), body: body);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch(err) {
      logger.e("Error PUT on $apiUrl$path: $err");
      throw Exception(err);
    }
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    try {
      http.Response response = await http.delete(Uri.parse("$apiUrl$path"));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception(e);
    }
  }
}
