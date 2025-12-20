import 'dart:io';
import 'package:flutter/material.dart';
import 'package:Care_AI/screens/home/home.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_store.dart';

class CreateProfileScreen extends StatefulWidget {
  final String phone;
  const CreateProfileScreen({super.key, required this.phone});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  // ===== COLORS =====
  static const _blue = Color(0xFF1F6BFF);
  static const _bg = Color(0xFFF3F5F9);
  static const _borderBlue = Color(0xFF1F41BB);

  // ===== UI CONSTANTS (gộp dùng chung) =====
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

  // ✅ gộp padding dùng chung cho input + gender (không đổi layout, chỉ tái dùng)
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

  final _picker = ImagePicker();
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = _formatPhoneForUi(widget.phone);
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

  // ===== HELPERS =====
  OutlineInputBorder _outline(Color c, double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c, width: w),
      );

  String _formatPhoneForUi(String raw) {
    final s = raw.trim();
    final digitsAll = s.replaceAll(RegExp(r'[^0-9]'), '');

    // 1) Nếu có +84 hoặc bắt đầu 84 -> bỏ 84
    if (s.startsWith('+84') || digitsAll.startsWith('84')) {
      var local = digitsAll;
      if (local.startsWith('84')) local = local.substring(2);
      if (local.startsWith('0')) local = local.substring(1);

      if (local.length >= 9) {
        final a = local.substring(0, 3);
        final b = local.substring(3, 6);
        final c = local.substring(6);
        return '(+84) $a $b $c';
      }
      return '(+84) $local';
    }

    // 2) Nếu bắt đầu bằng 0 -> bỏ 0 rồi gắn (+84)
    if (digitsAll.startsWith('0')) {
      final local = digitsAll.substring(1);
      if (local.length >= 9) {
        final a = local.substring(0, 3);
        final b = local.substring(3, 6);
        final c = local.substring(6);
        return '(+84) $a $b $c';
      }
      return '(+84) $local';
    }

    // 3) khác: để nguyên
    return s;
  }

  // ===== ACTIONS =====
  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;

    _dobCtrl.text =
        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    setState(() {});
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _avatarFile = File(picked.path));
  }

  void _onContinue() {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
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
                  title: 'Basic Information',
                  child: Column(
                    children: [
                      _input(
                        label: 'Full Name',
                        controller: _nameCtrl,
                        required: true,
                        hint: 'Enter full name',
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? 'The Full Name field is required.'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      _input(
                        label: 'Date of Birth',
                        controller: _dobCtrl,
                        required: true,
                        hint: 'dd/mm/yyyy',
                        readOnly: true,
                        onTap: _pickDob,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.calendar_month,
                            color: _blue,
                            size: 20,
                          ),
                        ),
                        validator: (v) => (v ?? '').isEmpty
                            ? 'The Date of Birth field is required.'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      _genderDropdown(),
                      const SizedBox(height: 10),
                      _input(
                        label: 'Height',
                        required: true,
                        controller: _heightCtrl,
                        hint: '160',
                        keyboardType: TextInputType.number,
                        suffixText: 'cm', // ✅ luôn hiện
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? 'The Height field is required.'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      _input(
                        label: 'Weight',
                        controller: _weightCtrl,
                        required: true,
                        hint: '45',
                        keyboardType: TextInputType.number,
                        suffixText: 'kg', // ✅ luôn hiện
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? 'The Weight field is required.'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _cardSection(
                  title: 'Contact Information',
                  child: Column(
                    children: [
                      _input(
                        label: 'Phone',
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
                            return 'Invalid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _input(
                        label: 'Address',
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

  // ===== APPBAR =====
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
        'Create Profile',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
    );
  }

  // ===== PROFILE CARD =====
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
          Container(
            width: 350,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromARGB(255, 0, 0, 0),
                width: 6,
              ),
            ),
            child: ClipOval(
              child: _avatarFile == null
                  ? const Icon(Icons.person,
                      size: 80, color: Color.fromARGB(255, 0, 0, 0))
                  : Image.file(_avatarFile!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Username',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 25,
            child: OutlinedButton(
              onPressed: _pickAvatar,
              child: const Text('Upload Avatar'),
            ),
          ),
        ],
      ),
    );
  }

  // ===== SECTION CARD =====
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

  // ===== INPUT (giữ layout, gọn code) =====
  Widget _input({
    required String label,
    required TextEditingController controller,
    String hint = '',
    bool readOnly = false,
    bool required = false, // ✅ field nào bắt buộc thì truyền true
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
    Widget? suffixIcon, // 👈 THÊM DÒNG NÀY
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

  // ===== GENDER DROPDOWN (giữ layout, gọn code) =====
  Widget _genderDropdown({bool required = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Gender',
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
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _gender,
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(right: 8), // 👈 chỉnh lề icon
            child: Icon(
              Icons.arrow_drop_down,
              color: _blue,
              size: 22,
            ),
          ),
          // style của item đang chọn / text trong ô
          style: _fieldTextStyle,

          decoration: InputDecoration(
            isDense: true,
            contentPadding: _fieldPadding, // ✅ gộp chung giống input
            enabledBorder: _outline(_borderBlue, 1.2),
            focusedBorder: _outline(_borderBlue, 1.6),
            errorBorder: _outline(Colors.red, 1.2),
            focusedErrorBorder: _outline(Colors.red, 1.6),
          ),

          // hint "Select" khi chưa chọn
          hint: Text('Select', style: _hintStyle),

          // style cho từng option (Male/Female/Other) -> sửa ở đây
          items: ['Male', 'Female', 'Other']
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: _fieldTextStyle),
                ),
              )
              .toList(),

          onChanged: (v) => setState(() => _gender = v),

          validator: required
              ? (v) => v == null ? 'The Gender field is required.' : null
              : null,
        ),
      ],
    );
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
          'Continue',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
