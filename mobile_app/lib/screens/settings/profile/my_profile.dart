import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'profile_store.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // ===== COLORS =====
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

  // ===== STATE =====
  bool _isEditing = false;
  UserProfile? _backupProfile;

  // ===== CONTROLLERS =====
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _gender;

  final _picker = ImagePicker();
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _nameCtrl.addListener(() => setState(() {}));
  }

  void _loadProfile() {
    final p = ProfileStore.profile.value;
    if (p == null) return;

    _nameCtrl.text = p.fullName;
    _dobCtrl.text = p.dob;
    _gender = p.gender.isEmpty ? null : p.gender;
    _heightCtrl.text = p.height;
    _weightCtrl.text = p.weight;
    _phoneCtrl.text = p.phone;
    _emailCtrl.text = p.email;
    _addressCtrl.text = p.address;
    _avatarFile = p.avatarFile;
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
    super.dispose();
  }

  OutlineInputBorder _outline(Color c, double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c, width: w),
      );

  // ===== ACTIONS =====
  Future<void> _pickAvatar() async {
    if (!_isEditing) return;
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
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
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
        setState(() {});
      },
    );
  }

  void _save() {
    ProfileStore.profile.value = UserProfile(
      fullName: _nameCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      gender: _gender ?? '',
      height: _heightCtrl.text.trim(),
      weight: _weightCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      avatarFile: _avatarFile,
    );
    setState(() => _isEditing = false);
  }

  void _cancelEdit() {
    if (_backupProfile == null) return;

    final p = _backupProfile!;
    _nameCtrl.text = p.fullName;
    _dobCtrl.text = p.dob;
    _gender = p.gender.isEmpty ? null : p.gender;
    _heightCtrl.text = p.height;
    _weightCtrl.text = p.weight;
    _phoneCtrl.text = p.phone;
    _emailCtrl.text = p.email;
    _addressCtrl.text = p.address;
    _avatarFile = p.avatarFile;

    setState(() => _isEditing = false);
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
                title: 'Thông tin cá nhân',
                child: Column(
                  children: [
                    _input(
                      label: 'Họ và tên',
                      controller: _nameCtrl,
                      required: true,
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 10),
                    _input(
                      label: 'Ngày sinh',
                      controller: _dobCtrl,
                      required: true,
                      readOnly: true,
                      suffixIcon: GestureDetector(
                        onTap: _pickDob,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(Icons.calendar_month,
                              color: _blue, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _genderDropdown(),
                    const SizedBox(height: 10),
                    _input(
                      label: 'Chiều cao',
                      controller: _heightCtrl,
                      required: true,
                      readOnly: !_isEditing,
                      keyboardType: TextInputType.number,
                      suffixText: 'cm',
                    ),
                    const SizedBox(height: 10),
                    _input(
                      label: 'Cân nặng',
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
                title: 'Thông tin liên hệ',
                child: Column(
                  children: [
                    _input(
                      label: 'Số điện thoại',
                      controller: _phoneCtrl,
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    _input(
                      label: 'Email',
                      controller: _emailCtrl,
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 10),
                    _input(
                      label: 'Địa chỉ',
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
      title: const Text(
        'Hồ sơ cá nhân',
        style: TextStyle(
          fontWeight: FontWeight.w800,
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
                    _backupProfile = ProfileStore.profile.value;
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
                  child: _avatarFile == null
                      ? const Icon(Icons.person, size: 60)
                      : Image.file(_avatarFile!, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _nameCtrl.text.isEmpty ? 'Họ và tên' : _nameCtrl.text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 25,
            child: OutlinedButton(
              onPressed: _pickAvatar,
              child: const Text('Thêm ảnh'),
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
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
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
            isDense: true,

            // 🔒 KHÓA CHIỀU CAO — CỰC KỲ QUAN TRỌNG
            constraints: const BoxConstraints(
              minHeight: 44,
            ),

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
            suffixIconConstraints:
                const BoxConstraints(minWidth: 36, minHeight: 36),

            enabledBorder: _outline(_borderBlue, 1.2),
            focusedBorder: _outline(_borderBlue, 1.6),
          ),
        ),
      ],
    );
  }

  // ===== GENDER (GIỐNG CREATE 100%) =====
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
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTapDown: !_isEditing
              ? null
              : (d) async {
                  final v = await showMenu<String>(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      d.globalPosition.dx + 200,
                      d.globalPosition.dy + 40,
                      12,
                      0,
                    ),
                    items: const [
                      PopupMenuItem(value: 'Nam', child: Text('Nam')),
                      PopupMenuItem(value: 'Nữ', child: Text('Nữ')),
                      PopupMenuItem(value: 'Khác', child: Text('Khác')),
                    ],
                  );
                  if (v != null) setState(() => _gender = v);
                },
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(text: _gender),
              style: _fieldTextStyle,
              decoration: InputDecoration(
                hintText: 'Chọn giới tính',
                hintStyle: _hintStyle,
                isDense: true,
                contentPadding: _fieldPadding,
                enabledBorder: _outline(_borderBlue, 1.2),
                focusedBorder: _outline(_borderBlue, 1.6),
                suffixIcon: Icon(Icons.arrow_drop_down, color: _blue),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
