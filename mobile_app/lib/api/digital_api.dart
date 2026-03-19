import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class DigitalApi {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/digital-human";
  static Future<List<dynamic>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));

    print("===== DIGITAL API RESPONSE =====");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    } else {
      throw Exception("Không tải được Digital Humans");
    }
  }
}
