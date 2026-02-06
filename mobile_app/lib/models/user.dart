class User {
  final String taiKhoanId;
  final String soDienThoai;
  final bool laAdmin;
  final String token;

  final String nguoiDungId;
  final String? tenND;

  User({
    required this.taiKhoanId,
    required this.soDienThoai,
    required this.laAdmin,
    required this.token,
    required this.nguoiDungId,
    this.tenND,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      taiKhoanId: json['TaiKhoan_ID'].toString(),
      soDienThoai: json['SoDienThoai'].toString(),
      laAdmin: json['LaAdmin'] == true,
      token: json['token'] ?? '',
      nguoiDungId: json['NguoiDung_ID'].toString(),
      tenND: json['TenND'],
    );
  }
}
