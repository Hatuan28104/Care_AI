import 'dart:io';
import 'package:flutter/material.dart';
import 'package:Care_AI/screens/home/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateProfileScreen extends StatefulWidget {
  final String nguoiDungId;
  final String phone;
  const CreateProfileScreen({
    super.key,
    required this.nguoiDungId,
    required this.phone,
  });

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  static const _blue = Color(0xFF1877F2);
  static const _bg = Color(0xFFF6F6F6);
  static const _borderBlue = Color(0xFF1F41BB);

  // ===== UI CONSTANTS =====
  static const _labelStyle = TextStyle(
    fontSize: 14,
    color: Colors.black54,
    fontWeight: FontWeight.w400,
  );

  static const _fieldTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: Colors.black,
  );

  static const _hintStyle = TextStyle(
    fontSize: 12,
    color: Colors.black38,
    fontWeight: FontWeight.w400,
  );

  static const _fieldPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 10);

  // ===== FORM =====
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _gender;
  final _genderCtrl = TextEditingController();

  final _picker = ImagePicker();
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = widget.phone;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _genderCtrl.dispose();
    super.dispose();
  }

  OutlineInputBorder _outline(Color c, double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c, width: w),
      );

  void _pickDob() {
    final now = DateTime.now();
    final minAgeDate = DateTime(
      now.year - 16,
      now.month,
      now.day,
    );

    DatePicker.showDatePicker(
      context,
      minTime: DateTime(1900),
      maxTime: minAgeDate,
      onConfirm: (d) {
        _dobCtrl.text =
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
        setState(() {});
      },
    );
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _avatarFile = File(picked.path));
  }

  String toIso(String s) {
    final p = s.split('/');
    return DateTime(
      int.parse(p[2]),
      int.parse(p[1]),
      int.parse(p[0]),
    ).toIso8601String();
  }

  Future<void> _onContinue() async {
    setState(() => _submitted = true);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await ProfileApi.updateProfile(
        nguoiDungId: widget.nguoiDungId,
        tenND: _nameCtrl.text.trim(),
        ngaySinh: toIso(_dobCtrl.text),
        gioiTinh: _gender == 'Nam'
            ? 1
            : _gender == 'Nữ'
                ? 0
                : null,
        chieuCao: double.parse(_heightCtrl.text),
        canNang: double.parse(_weightCtrl.text),
        email: _emailCtrl.text.trim(),
        diaChi: _addressCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dữ liệu không hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              children: [
                const SizedBox(height: 10),
                _profileCard(),
                const SizedBox(height: 14),
                _cardSection(
                  title: 'Thông tin cá nhân',
                  child: Column(
                    children: [
                      _input(
                        label: 'Họ và tên',
                        controller: _nameCtrl,
                        required: true,
                        hint: 'Nguyen Van A',
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return 'Trường Họ và tên là bắt buộc.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _input(
                        label: 'Ngày sinh',
                        controller: _dobCtrl,
                        required: true,
                        hint: 'dd/mm/yyyy',
                        keyboardType: TextInputType.datetime,
                        suffixIcon: GestureDetector(
                          onTap: _pickDob,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.calendar_month,
                              color: _blue,
                              size: 18,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Trường Ngày sinh là bắt buộc.';
                          }
                          final parts = v.split('/');
                          if (parts.length != 3)
                            return 'Ngày sinh không đúng định dạng.';

                          final day = int.tryParse(parts[0]);
                          final month = int.tryParse(parts[1]);
                          final year = int.tryParse(parts[2]);
                          if (day == null || month == null || year == null) {
                            return 'Ngày sinh không hợp lệ.';
                          }

                          final dob = DateTime(year, month, day);
                          final now = DateTime.now();
                          final age = now.year -
                              dob.year -
                              ((now.month < dob.month ||
                                      (now.month == dob.month &&
                                          now.day < dob.day))
                                  ? 1
                                  : 0);

                          if (age < 16) {
                            return 'Bạn phải đủ 16 tuổi trở lên.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _genderDropdown(),
                      const SizedBox(height: 10),
                      _input(
                        label: 'Chiều cao',
                        required: true,
                        controller: _heightCtrl,
                        hint: '160',
                        keyboardType: TextInputType.number,
                        suffixText: 'cm',
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return 'Trường Chiều cao là bắt buộc.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _input(
                        label: 'Cân nặng',
                        controller: _weightCtrl,
                        required: true,
                        hint: '45',
                        keyboardType: TextInputType.number,
                        suffixText: 'kg',
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return 'Trường Cân nặng là bắt buộc.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _cardSection(
                  title: 'Thông tin liên hệ',
                  child: Column(
                    children: [
                      _input(
                        label: 'Số điện thoại',
                        controller: _phoneCtrl,
                        readOnly: true,
                        hint: '',
                      ),
                      const SizedBox(height: 10),
                      _input(
                        label: 'Email',
                        controller: _emailCtrl,
                        hint: '',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty) return null;
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(s)) {
                            return 'Email không hợp lệ.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _input(
                        label: 'Địa chỉ',
                        controller: _addressCtrl,
                        hint: '',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _continueButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.black, size: 20),
      ),
      title: const Text(
        'Hồ sơ cá nhân',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3E2E2), Color(0xFFD1E3F9)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 350,
            height: 90,
            child: Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: _avatarFile == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.black,
                        )
                      : Image.file(
                          _avatarFile!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _nameCtrl.text.isEmpty ? 'Họ và tên' : _nameCtrl.text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 25,
            child: OutlinedButton(
              onPressed: _pickAvatar,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF626262),
                side: const BorderSide(
                  color: Color(0xFF1F41BB),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Thêm ảnh',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(250, 240, 240, 240),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    String hint = '',
    bool readOnly = false,
    bool required = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: _labelStyle,
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          style: _fieldTextStyle,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: _fieldPadding,
            hintText: hint,
            hintStyle: _hintStyle,
            suffixIcon: suffixIcon ??
                (suffixText == null || suffixText.isEmpty
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          suffixText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _blue,
                          ),
                        ),
                      )),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            enabledBorder: _outline(_borderBlue, 1.2),
            focusedBorder: _outline(_borderBlue, 1.6),
            errorBorder: _outline(Colors.red, 1.2),
            focusedErrorBorder: _outline(Colors.red, 1.6),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _genderDropdown({bool required = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Giới tính',
            style: _labelStyle,
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTapDown: (d) => _showGenderMenu(d),
          child: AbsorbPointer(
            child: TextFormField(
              controller: _genderCtrl,
              readOnly: true,
              style: _fieldTextStyle,
              decoration: InputDecoration(
                hintText: 'Chọn giới tính',
                hintStyle: _hintStyle,
                isDense: true,
                contentPadding: _fieldPadding,
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: _blue,
                  ),
                ),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                enabledBorder: _outline(_borderBlue, 1.2),
                focusedBorder: _outline(_borderBlue, 1.6),
                errorBorder: _outline(Colors.red, 1.2),
                focusedErrorBorder: _outline(Colors.red, 1.6),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Trường giới tính là bắt buộc.';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showGenderMenu(TapDownDetails d) async {
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        d.globalPosition.dx,
        d.globalPosition.dy + 20,
        0,
        0,
      ),
      items: const [
        PopupMenuItem(
          value: 'Nam',
          height: 32,
          child: Text('Nam'),
        ),
        PopupMenuItem(
          value: 'Nữ',
          height: 32,
          child: Text('Nữ'),
        ),
        PopupMenuItem(
          value: 'Khác',
          height: 32,
          child: Text('Khác'),
        ),
      ],
    );

    if (selected != null) {
      setState(() {
        _gender = selected;
        _genderCtrl.text = selected;
      });
    }
  }

  // ===== BUTTON =====
  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text(
          'Tiếp tục',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class ProfileApi {
  static const _baseUrl = 'http://10.0.2.2:3000';

  static Future<void> updateProfile({
    required String nguoiDungId,
    required String tenND,
    required String ngaySinh,
    int? gioiTinh,
    required double chieuCao,
    required double canNang,
    String? email,
    String? diaChi,
  }) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/profile/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nguoiDungId': nguoiDungId,
        'tenND': tenND,
        'ngaySinh': ngaySinh,
        'gioiTinh': gioiTinh,
        'chieuCao': chieuCao,
        'canNang': canNang,
        'email': email,
        'diaChi': diaChi,
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Cập nhật thất bại');
    }
  }
}
