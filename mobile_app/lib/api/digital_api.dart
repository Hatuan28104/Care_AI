import 'dart:convert';
import 'package:http/http.dart' as http;

class DigitalApi {
  static const String baseUrl = "http://10.0.2.2:3000/api/digital-human";
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
