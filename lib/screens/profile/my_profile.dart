import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_store.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // ===== COLORS =====
  static const _blue = Color(0xFF1F6BFF);
  static const _bg = Color(0xFFF3F5F9);
  static const _borderBlue = Color(0xFF1F41BB);

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

  bool _isEditing = false;

  // ===== CONTROLLERS =====
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _gender;

  // ===== AVATAR =====
  final _picker = ImagePicker();
  File? _avatarFile;

  // ===== BACKUP =====
  late String _bkName, _bkDob, _bkHeight, _bkWeight;
  String? _bkGender;
  File? _bkAvatar;

  late String _bkPhone, _bkEmail, _bkAddress;

  @override
  void initState() {
    super.initState();
    _loadFromStore();
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

  Color get _borderColor => _isEditing ? _borderBlue : Colors.grey.shade400;

  void _loadFromStore() {
    final p = ProfileStore.profile.value;
    if (p == null) {
      _nameCtrl.text = 'Username';
      _dobCtrl.text = '';
      _gender = null;
      _heightCtrl.text = '';
      _weightCtrl.text = '';
      _avatarFile = null;

      _phoneCtrl.text = '';
      _emailCtrl.text = '';
      _addressCtrl.text = '';
      return;
    }

    _nameCtrl.text = p.fullName;
    _dobCtrl.text = p.dob;
    _gender = p.gender.isEmpty ? null : p.gender;
    _heightCtrl.text = p.height;
    _weightCtrl.text = p.weight;
    _avatarFile = p.avatarFile;

    _phoneCtrl.text = p.phone;
    _emailCtrl.text = p.email;
    _addressCtrl.text = p.address;
  }

  // ===== ACTIONS =====
  void _startEdit() {
    _bkName = _nameCtrl.text;
    _bkDob = _dobCtrl.text;
    _bkGender = _gender;
    _bkHeight = _heightCtrl.text;
    _bkWeight = _weightCtrl.text;
    _bkAvatar = _avatarFile;

    _bkPhone = _phoneCtrl.text;
    _bkEmail = _emailCtrl.text;
    _bkAddress = _addressCtrl.text;

    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    _nameCtrl.text = _bkName;
    _dobCtrl.text = _bkDob;
    _gender = _bkGender;
    _heightCtrl.text = _bkHeight;
    _weightCtrl.text = _bkWeight;
    _avatarFile = _bkAvatar;

    _phoneCtrl.text = _bkPhone;
    _emailCtrl.text = _bkEmail;
    _addressCtrl.text = _bkAddress;

    setState(() => _isEditing = false);
  }

  Future<void> _saveEdit() async {
    final ok = await showConfirmSaveDialog(context);
    if (!ok) return;

    final old = ProfileStore.profile.value;

    ProfileStore.profile.value = UserProfile(
      fullName: _nameCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      gender: (_gender ?? '').trim(),
      height: _heightCtrl.text.trim(),
      weight: _weightCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isNotEmpty
          ? _phoneCtrl.text.trim()
          : (old?.phone ?? ''),
      email: _emailCtrl.text.trim().isNotEmpty
          ? _emailCtrl.text.trim()
          : (old?.email ?? ''),
      address: _addressCtrl.text.trim().isNotEmpty
          ? _addressCtrl.text.trim()
          : (old?.address ?? ''),
      avatarFile: _avatarFile,
    );

    setState(() => _isEditing = false);
    await showSaveSuccessDialog(context);
  }

  Future<void> _pickAvatar() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() => _avatarFile = File(picked.path));
  }

  Future<void> _pickDob() async {
    if (!_isEditing) return;

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
                      required: true,
                      controller: _nameCtrl,
                      hint: 'Enter full name',
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 10),
                    _input(
                      label: 'Date of Birth',
                      required: true,
                      controller: _dobCtrl,
                      hint: 'dd/mm/yyyy',
                      readOnly: true,
                      onTap: _isEditing ? _pickDob : null,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child:
                            Icon(Icons.calendar_month, color: _blue, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _genderDropdown(required: true),
                    const SizedBox(height: 10),
                    _input(
                      label: 'Height',
                      required: true,
                      controller: _heightCtrl,
                      hint: '160',
                      readOnly: !_isEditing,
                      keyboardType: TextInputType.number,
                      suffixText: 'cm',
                    ),
                    const SizedBox(height: 10),
                    _input(
                      label: 'Weight',
                      required: true,
                      controller: _weightCtrl,
                      hint: '45',
                      readOnly: !_isEditing,
                      keyboardType: TextInputType.number,
                      suffixText: 'kg', // ✅ luôn hiện
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
                      hint: '',
                      readOnly: !_isEditing, // muốn lock phone luôn -> true
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _input(
                      label: 'Email',
                      controller: _emailCtrl,
                      hint: '',
                      readOnly: !_isEditing,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    _input(
                      label: 'Address',
                      controller: _addressCtrl,
                      hint: '',
                      readOnly: !_isEditing,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ===== APP BAR =====
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
        'My Profile',
        style: TextStyle(
            fontWeight: FontWeight.w800, fontSize: 24, color: Colors.black),
      ),
      actions: _isEditing ? _editActions() : _viewActions(),
    );
  }

  List<Widget> _viewActions() => [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: _blue),
          onPressed: _startEdit,
        ),
      ];

  List<Widget> _editActions() => [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: _cancelEdit,
        ),
        IconButton(
          icon: const Icon(Icons.save_outlined, color: _blue),
          onPressed: _saveEdit,
        ),
      ];

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
          Text(
            _nameCtrl.text.isEmpty ? 'Username' : _nameCtrl.text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 25,
            child: OutlinedButton(
              onPressed: _pickAvatar,
              child: const Text('Change Avatar'),
            ),
          ),
        ],
      ),
    );
  }

  // ===== SECTION CARD (GIỐNG CreateProfile) =====
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

  // ===== INPUT (GIỐNG CreateProfile: dấu * đỏ + suffix cm/kg luôn hiện) =====
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
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
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

            // ✅ ưu tiên suffixIcon nếu truyền, còn không thì hiện suffixText (cm/kg)
            suffixIcon: suffixIcon ??
                ((suffixText == null || suffixText.isEmpty)
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

            enabledBorder: _outline(_borderColor, 1.2),
            focusedBorder: _outline(_borderColor, 1.6),
            errorBorder: _outline(Colors.red, 1.2),
            focusedErrorBorder: _outline(Colors.red, 1.6),
          ),
        ),
      ],
    );
  }

  // ===== GENDER (GIỐNG CreateProfile: icon xanh + padding gộp) =====
  Widget _genderDropdown({bool required = true}) {
    const genders = ['Male', 'Female', 'Other'];

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
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ✅ KHÓA TƯƠNG TÁC nhưng KHÔNG làm mờ
        AbsorbPointer(
          absorbing: !_isEditing, // false => cho bấm, true => khóa
          child: DropdownButtonFormField<String>(
            value: _gender,
            isExpanded: true,
            style: _fieldTextStyle,
            icon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.arrow_drop_down, color: _blue, size: 22),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: _fieldPadding,
              enabledBorder: _outline(_borderColor, 1.2),
              focusedBorder: _outline(_borderColor, 1.6),
              errorBorder: _outline(Colors.red, 1.2),
              focusedErrorBorder: _outline(Colors.red, 1.6),
            ),
            hint: Text('Select', style: _hintStyle),

            items: genders
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),

            // ✅ luôn có onChanged để không bị “disabled/mờ”
            onChanged: (v) => setState(() => _gender = v),

            validator: required
                ? (v) => v == null ? 'The Gender field is required.' : null
                : null,
          ),
        ),
      ],
    );
  }
}

// ===== DIALOGS =====
Future<bool> showConfirmSaveDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Confirm Saving Information',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Do you want to save the information?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                _dialogButton(context, 'Confirm', true),
                const SizedBox(height: 10),
                _dialogButton(context, 'Cancel', false, isCancel: true),
              ],
            ),
          ),
        ),
      ) ??
      false;
}

Widget _dialogButton(BuildContext context, String text, bool value,
    {bool isCancel = false}) {
  return SizedBox(
    width: double.infinity,
    height: 44,
    child: ElevatedButton(
      onPressed: () => Navigator.pop(context, value),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isCancel ? Colors.grey.shade300 : const Color(0xFF1F6BFF),
        foregroundColor: isCancel ? Colors.black54 : Colors.white,
        elevation: 0,
      ),
      child: Text(text),
    ),
  );
}

Future<void> showSaveSuccessDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (c) {
      Future.delayed(const Duration(seconds: 1), () {
        if (Navigator.of(c).canPop()) Navigator.of(c).pop();
      });

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 56),
              SizedBox(height: 16),
              Text(
                'Profile Updated Successfully',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      );
    },
  );
}
