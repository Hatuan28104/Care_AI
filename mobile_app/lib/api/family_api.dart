import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

class FamilyApi {
  static String get _baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();

    if (token == null || token.isEmpty) {
      throw ApiException('Token null trước khi gọi API');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

/* =========================
   GỬI LỜI MỜI BẰNG SĐT
========================= */
  static Future<void> sendInviteByPhone(String phone) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/family/invite/by-phone'),
          headers: await _authHeaders(),
          body: jsonEncode({'phone': phone}),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? 'Gửi lời mời thất bại');
    }
  }

  /* =========================
     DANH SÁCH LỜI MỜI ĐẾN
  ========================= */
  static Future<List<dynamic>> getIncomingInvites() async {
    final url = Uri.parse(
      '$_baseUrl/family/invite/incoming',
    );

    final response = await http
        .get(
          url,
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException('Không lấy được danh sách lời mời');
    }

    return data['data'];
  }

  /* =========================
     CHẤP NHẬN
  ========================= */
  static Future<Map<String, dynamic>> acceptInvite(String loiMoiId) async {
    final url = Uri.parse('$_baseUrl/family/invite/accept');

    final response = await http
        .post(
          url,
          headers: await _authHeaders(),
          body: jsonEncode({
            'loiMoiId': loiMoiId,
          }),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? 'Accept thất bại');
    }

    return data['data']; // 🔥 QUAN TRỌNG
  }

  /* =========================
     TỪ CHỐI
  ========================= */
  static Future<void> rejectInvite(String loiMoiId) async {
    final url = Uri.parse('$_baseUrl/family/invite/reject');

    final response = await http
        .post(
          url,
          headers: await _authHeaders(),
          body: jsonEncode({
            'loiMoiId': loiMoiId,
          }),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? 'Reject thất bại');
    }
  }

  /* =========================
   DANH SÁCH NGƯỜI GIÁM HỘ
========================= */
  static Future<List<dynamic>> getMyGuardians() async {
    final url = Uri.parse('$_baseUrl/family/relationship/guardians');

    final response = await http
        .get(
          url,
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException('Không lấy được danh sách người giám hộ');
    }

    return data['data'];
  }

/* =========================
   DANH SÁCH NGƯỜI ĐƯỢC GIÁM HỘ
========================= */
  static Future<List<dynamic>> getMyDependents() async {
    final url = Uri.parse('$_baseUrl/family/relationship/dependents');

    final response = await http
        .get(
          url,
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException('Không lấy được danh sách người được giám hộ');
    }

    return data['data'];
  }

/* =========================
   KẾT THÚC QUAN HỆ GIÁM HỘ
========================= */
  static Future<void> endRelationship(String quanHeId) async {
    final url = Uri.parse('$_baseUrl/family/relationship/end');

    final response = await http
        .post(
          url,
          headers: await _authHeaders(),
          body: jsonEncode({
            'quanHeId': quanHeId,
          }),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? 'Không thể kết thúc quan hệ');
    }
  }

/* =========================
   DANH SÁCH QUYỀN
========================= */
  static Future<List<dynamic>> getPermissions() async {
    final url = Uri.parse('$_baseUrl/family/permission');

    final response = await http
        .get(
          url,
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException('Không lấy được danh sách quyền');
    }

    return data['data'];
  }

/* =========================
   QUYỀN THEO QUAN HỆ
========================= */
  static Future<List<dynamic>> getPermissionConfigs(String quanHeId) async {
    final url = Uri.parse('$_baseUrl/family/permission/config/$quanHeId');
    final response = await http
        .get(
          url,
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException('Không lấy được cấu hình quyền');
    }

    return data['data'];
  }

/* =========================
   BẬT / TẮT QUYỀN
========================= */
  static Future<void> savePermission({
    required String quanHeId,
    required String quyenId,
    required bool active,
  }) async {
    final url = Uri.parse('$_baseUrl/family/permission/save');

    final response = await http
        .post(
          url,
          headers: await _authHeaders(),
          body: jsonEncode({
            'quanHeId': quanHeId,
            'quyenId': quyenId,
            'active': active,
          }),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? 'Không lưu được quyền');
    }
  }

/* =========================
   LẤY CONVERSATION ĐƯỢC SHARE
========================= */
  static Future<List<dynamic>> getSharedConversation(String quanHeId) async {
    final url = Uri.parse(
      '$_baseUrl/family/permission/shared/$quanHeId',
    );

    final response = await http
        .get(
          url,
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException('Không lấy được danh sách hội thoại');
    }

    final list = data['data'] is List ? data['data'] as List : <dynamic>[];
    return list.map((item) {
      final row = item is Map<String, dynamic>
          ? item
          : (item is Map
              ? Map<String, dynamic>.from(item)
              : <String, dynamic>{});
      return <String, dynamic>{
        "hoithoai_id": row["hoithoai_id"]?.toString() ?? "",
        "tendigitalhuman": row["tendigitalhuman"]?.toString() ?? "Conversation",
        "imageurl": row["imageurl"]?.toString() ?? "",
        "lancuoituongtac": row["lancuoituongtac"]?.toString() ?? "",
      };
    }).toList();
  }

  /* =========================
   TÌM USER THEO SĐT
========================= */
  static Future<List<dynamic>> findUserByPhone(String phone) async {
    final url = Uri.parse(
      '$_baseUrl/family/invite/find-by-phone?phone=$phone',
    );

    final response = await http
        .get(
          url,
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException('Không tìm được user');
    }

    return data['data'] ?? [];
  }

/* =========================
   PROFILE QUAN HỆ (GIÁM HỘ / PHỤ THUỘC)
========================= */
  static Future<Map<String, dynamic>> getRelationshipProfile(
      String quanHeId) async {
    final url = Uri.parse(
      '$_baseUrl/family/relationship/profile/$quanHeId',
    );

    final response = await http
        .get(
          url,
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? 'Không lấy được profile quan hệ');
    }

    return data['data'];
  }

/* =========================
   HỦY LỜI MỜI
========================= */
  static Future<void> cancelInvite(String loiMoiId) async {
    final url = Uri.parse('$_baseUrl/family/invite/cancel');

    final response = await http
        .post(
          url,
          headers: await _authHeaders(),
          body: jsonEncode({
            'loiMoiId': loiMoiId,
          }),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? 'Không thể hủy lời mời');
    }
  }

/* =========================
   LẤY HEALTH REPORT
========================= */
  static Future<Map<String, dynamic>> getHealthReport(
    String deviceId,
    String type,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/health/report/$deviceId?type=$type',
    );

    final response = await http
        .get(
          url,
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? 'Không lấy được báo cáo');
    }

    return data['data'];
  }

  /* =========================
   NORMALIZE AVATAR URL
========================= */
  static String? normalizeAvatar(String? avatar) {
    if (avatar == null || avatar.isEmpty) return null;
    if (avatar.startsWith('http')) return avatar;
    return '$_baseUrl$avatar';
  }
}
