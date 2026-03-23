import 'dart:io';
import 'dart:convert';
import 'package:Care_AI/models/tr.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:Care_AI/api/profile_api.dart' as profile_api;
import 'package:Care_AI/models/current_user.dart';
import 'package:Care_AI/config/api_config.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String _toAbsoluteImageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '${ApiConfig.baseUrl}$cleanPath';
  }

  // ===== COLORS =====
  static const _blue = Color(0xFF1877F2);
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

  static const _fieldPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );

  // ===== STATE =====
  bool _isEditing = false;

  // ===== CONTROLLERS =====
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  String? _avatarNetworkUrl;
  Map<String, String> _formErrors = {};

  String? _gender;

  final _picker = ImagePicker();
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _fetchProfileFromBE();
    _nameCtrl.addListener(() => setState(() {}));
  }

  Future<void> _fetchProfileFromBE() async {
    try {
      final user = CurrentUser.user;
      if (user == null) return;

      final data = await profile_api.ProfileApi.getProfile(user.nguoiDungId);

      if (data == null) return;

      _nameCtrl.text = data['tenND'] ?? '';

      final dob = data['ngaySinh'];
      _dobCtrl.text =
          dob != null && dob.length >= 10 ? dob.substring(0, 10) : '';

      _gender = data['gioiTinh'] == 1
          ? context.tr.male
          : data['gioiTinh'] == 0
              ? context.tr.female
              : null;

      _genderCtrl.text = _gender ?? '';

      _heightCtrl.text = data['chieuCao']?.toString() ?? '';
      _weightCtrl.text = data['canNang']?.toString() ?? '';

      _emailCtrl.text = data['email'] ?? '';
      _addressCtrl.text = data['diaChi'] ?? '';

      _phoneCtrl.text = user.soDienThoai ?? '';

      final avatar = data['avatarUrl'];

      if (avatar != null && avatar.isNotEmpty) {
        _avatarFile = null;
        _avatarNetworkUrl = _toAbsoluteImageUrl(avatar);
      }

      setState(() {});
    } catch (e, s) {
      debugPrint('❌ Load profile error: $e');
      debugPrint('$s');
    }
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
  String _mapLabelToKey(String label) {
    if (label == context.tr.fullName) return 'tenND';
    if (label == context.tr.birthDate) return 'ngaySinh';
    if (label == context.tr.height) return 'chieuCao';
    if (label == context.tr.weight) return 'canNang';
    if (label == context.tr.email) return 'email';
    if (label == context.tr.address) return 'diaChi';
    return '';
  }

  // ===== ACTIONS =====
  Future<void> _pickAvatar() async {
    if (!_isEditing) return;
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _avatarFile = File(picked.path));
  }

  void _pickDob() {
    if (!_isEditing) return;

    final now = DateTime.now();
    final minAgeDate = DateTime(now.year - 16, now.month, now.day);

    DatePicker.showDatePicker(
      context,
      minTime: DateTime(1900),
      maxTime: minAgeDate,
      onConfirm: (d) {
        _dobCtrl.text =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        setState(() {});
      },
    );
  }

  Future<void> _save() async {
    try {
      final user = CurrentUser.user;
      if (user == null) return;

      final height = double.tryParse(_heightCtrl.text);
      final weight = double.tryParse(_weightCtrl.text);

      if (height == null || weight == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.tr.invalidHeightWeight)));
        return;
      }

      final gioiTinh = _gender == context.tr.male
          ? 1
          : _gender == context.tr.female
              ? 0
              : null;

      if (gioiTinh == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.tr.invalidGender)));
        return;
      }

      await profile_api.ProfileApi.updateProfile(
        nguoiDungId: user.nguoiDungId,
        tenND: _nameCtrl.text.trim(),
        ngaySinh: _dobCtrl.text.trim(),
        gioiTinh: gioiTinh,
        chieuCao: height,
        canNang: weight,
        email: _emailCtrl.text.trim(),
        diaChi: _addressCtrl.text.trim(),
        avatarFile: _avatarFile,
      );

      setState(() => _isEditing = false);
      await _fetchProfileFromBE();
    } catch (e) {
      final raw = e.toString().replaceFirst("Exception: ", "");

      try {
        final errorData = jsonDecode(raw);
        final errors = Map<String, dynamic>.from(errorData["errors"] ?? {});

        setState(() {
          _formErrors = {};
          errors.forEach((key, value) {
            _formErrors[key] = value.toString();
          });
        });
      } catch (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.tr.errorOccurred)));
      }
    }
  }

  Future<void> _cancelEdit() async {
    setState(() => _isEditing = false);
    await _fetchProfileFromBE();
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: _appBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _profileCard(),
              const SizedBox(height: 14),
              _cardSection(
                title: context.tr.personalInfo,
                child: Column(
                  children: [
                    _input(
                      label: context.tr.fullName,
                      controller: _nameCtrl,
                      required: true,
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 10),
                    _input(
                      label: context.tr.birthDate,
                      controller: _dobCtrl,
                      required: true,
                      readOnly: true,
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
                    ),
                    const SizedBox(height: 10),
                    _genderDropdown(),
                    const SizedBox(height: 10),
                    _input(
                      label: context.tr.height,
                      controller: _heightCtrl,
                      required: true,
                      readOnly: !_isEditing,
                      keyboardType: TextInputType.number,
                      suffixText: 'cm',
                    ),
                    const SizedBox(height: 10),
                    _input(
                      label: context.tr.weight,
                      controller: _weightCtrl,
                      required: true,
                      readOnly: !_isEditing,
                      keyboardType: TextInputType.number,
                      suffixText: 'kg',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _cardSection(
                title: context.tr.contactInfo,
                child: Column(
                  children: [
                    _input(
                      label: context.tr.phoneNumber,
                      controller: _phoneCtrl,
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    _input(
                      label: context.tr.email,
                      controller: _emailCtrl,
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 10),
                    _input(
                      label: context.tr.address,
                      controller: _addressCtrl,
                      readOnly: !_isEditing,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== APPBAR =====
  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        context.tr.profile,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _isEditing
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _cancelEdit,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close, color: Colors.red, size: 22),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _save,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.save, color: _blue, size: 22),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() => _isEditing = true);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.edit, color: _blue, size: 22),
                  ),
                ),
        ),
      ],
    );
  }

  // ===== PROFILE CARD (GIỐNG CREATE 100%) =====
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
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: ClipOval(
                  child: _avatarFile != null
                      ? Image.file(_avatarFile!, fit: BoxFit.cover)
                      : (_avatarNetworkUrl != null
                          ? Image.network(
                              _avatarNetworkUrl!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.person, size: 60)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _nameCtrl.text.isEmpty ? context.tr.fullName : _nameCtrl.text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 25,
            child: OutlinedButton(
              onPressed: _pickAvatar,
              child: Text(context.tr.updatePhoto),
            ),
          ),
        ],
      ),
    );
  }

  // ===== SECTION =====
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
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ===== INPUT (GIỐNG CREATE) =====
  Widget _input({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
    Widget? suffixIcon,
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
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: _fieldTextStyle,
          decoration: InputDecoration(
            errorText: _formErrors[_mapLabelToKey(label)],

            isDense: true,

            // 🔒 KHÓA CHIỀU CAO — CỰC KỲ QUAN TRỌNG
            constraints: const BoxConstraints(minHeight: 44),

            contentPadding: _fieldPadding,

            // ✅ TEXT: cm / kg → DÙNG suffix
            suffix: suffixText == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      suffixText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _blue,
                      ),
                    ),
                  ),

            // ✅ ICON: calendar / dropdown → DÙNG suffixIcon
            suffixIcon: suffixIcon,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),

            enabledBorder: _outline(_borderBlue, 1.2),
            focusedBorder: _outline(_borderBlue, 1.6),
          ),
          onChanged: (_) {
            final key = _mapLabelToKey(label);
            if (_formErrors.containsKey(key)) {
              setState(() {
                _formErrors.remove(key);
              });
            }
          },
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
            text: context.tr.gender,
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
                hintText: context.tr.chooseGender,
                hintStyle: _hintStyle,
                isDense: true,
                contentPadding: _fieldPadding,
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(Icons.arrow_drop_down, color: _blue),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                enabledBorder: _outline(_borderBlue, 1.2),
                focusedBorder: _outline(_borderBlue, 1.6),
                errorBorder: _outline(Colors.red, 1.2),
                focusedErrorBorder: _outline(Colors.red, 1.6),
              ),
              validator: required
                  ? (v) => (v == null || v.isEmpty)
                      ? context.tr.genderRequired
                      : null
                  : null,
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
      items: [
        PopupMenuItem(
          value: context.tr.male,
          height: 32,
          child: Text(context.tr.male),
        ),
        PopupMenuItem(
          value: context.tr.female,
          height: 32,
          child: Text(context.tr.female),
        ),
        PopupMenuItem(
          value: context.tr.other,
          height: 32,
          child: Text(context.tr.other),
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
}
