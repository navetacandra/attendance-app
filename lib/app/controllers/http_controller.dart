import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpController {
  static const apiUrl = 'http://10.0.2.2:3000/api/v1';

  static StreamController<List<Map<String, dynamic>>> streamList(String path) {
    StreamController<List<Map<String, dynamic>>> streamController =
        StreamController();
    http.Client client = http.Client();
    http.Request request = http.Request("GET", Uri.parse(apiUrl + path));
    request.headers.addAll({
      "Accept": "text/event-stream",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive",
    });

    client.send(request).asStream().listen((response) {
      if (response.statusCode != 200) {
        client.close();
        throw Exception('Failed to connect to SSE: ${response.statusCode}');
      }

      response.stream.listen((event) {
        final data = utf8
            .decode(event)
            .replaceFirst(RegExp(r'data: '), '')
            .replaceAll(RegExp(r'\n'), '');
        streamController.sink.add((jsonDecode(data) as List<dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList());
      }, cancelOnError: true);
    }, cancelOnError: true);

    streamController.onCancel = () => client.close();
    return streamController;
  }

  static StreamController<Map<String, dynamic>> streamMap(String path) {
    StreamController<Map<String, dynamic>> streamController =
        StreamController();
    http.Client client = http.Client();
    http.Request request = http.Request("GET", Uri.parse(apiUrl + path));
    request.headers.addAll({
      "Accept": "text/event-stream",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive",
    });

    client.send(request).asStream().listen((response) {
      if (response.statusCode != 200) {
        client.close();
        throw Exception('Failed to connect to SSE: ${response.statusCode}');
      }

      response.stream.listen((event) {
        final data = utf8
            .decode(event)
            .replaceFirst(RegExp(r'data: '), '')
            .replaceAll(RegExp(r'\n'), '');
        streamController.sink.add(jsonDecode(data) as Map<String, dynamic>);
      }, cancelOnError: true);
    }, cancelOnError: true);

    streamController.onCancel = () => client.close();
    return streamController;
  }

  static Future<Map<String, dynamic>> get(String path) async {
    http.Response response = await http
        .get(Uri.parse(apiUrl + path), headers: {"Accept": "application/json"});
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    http.Response response =
        await http.post(Uri.parse(apiUrl + path), body: body);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> put(
      String path, Map<String, dynamic> body) async {
    http.Response response =
        await http.put(Uri.parse(apiUrl + path), body: body);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    try {
      http.Response response = await http.delete(Uri.parse(apiUrl + path));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception(e);
    }
  }
}
