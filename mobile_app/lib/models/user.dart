class User {
  final String taiKhoanId;
  final String soDienThoai;
  final bool laAdmin;
  final String nguoiDungId;
  final String? tenND;

  User({
    required this.taiKhoanId,
    required this.soDienThoai,
    required this.laAdmin,
    required this.nguoiDungId,
    this.tenND,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      taiKhoanId: json['TaiKhoan_ID'].toString(),
      soDienThoai: json['SoDienThoai'].toString(),
      laAdmin: json['LaAdmin'] == true,
      nguoiDungId: json['NguoiDung_ID'].toString(),
      tenND: json['TenND'],
    );
  }
}
