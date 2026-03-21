class User {
  final String taiKhoanId;
  final String soDienThoai;
  final bool laAdmin;
  final String token;

  final String nguoiDungId;
  final String? tenND;
  final bool profileCompleted;

  User({
    required this.taiKhoanId,
    required this.soDienThoai,
    required this.laAdmin,
    required this.token,
    required this.nguoiDungId,
    this.tenND,
    this.profileCompleted = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final nestedNguoiDung = json['nguoidung'] is Map<String, dynamic>
        ? json['nguoidung'] as Map<String, dynamic>
        : <String, dynamic>{};

    final nguoiDungIdValue =
        json['NguoiDung_ID'] ?? json['nguoiDungId'] ?? nestedNguoiDung['nguoidung_id'];
    final soDienThoaiValue = json['SoDienThoai'] ?? json['sodienthoai'] ?? '';
    final tenNdValue = json['TenND'] ?? json['tenND'] ?? nestedNguoiDung['tennd'];

    return User(
      taiKhoanId: (json['TaiKhoan_ID'] ??
              json['taiKhoanId'] ??
              json['taikhoan_id'] ??
              '')
          .toString(),
      soDienThoai: soDienThoaiValue.toString(),
      laAdmin: json['LaAdmin'] == true || json['laadmin'] == true,
      token: json['token'] ?? '',
      nguoiDungId: nguoiDungIdValue?.toString() ?? '',
      tenND: tenNdValue?.toString(),
      profileCompleted: json['profileCompleted'] == true,
    );
  }
}
