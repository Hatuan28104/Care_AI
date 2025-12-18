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
  // ===== CONSTANTS =====
  static const _blue = Color(0xFF1F6BFF);
  static const _bg = Color(0xFFF3F5F9);
  static const _fieldBg = Color(0xFFF3F5FF);

  bool _isEditing = false;

  // ===== CONTROLLERS =====
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  // Gender
  String? _gender;

  // ===== AVATAR =====
  final _picker = ImagePicker();
  File? _avatarFile;

  // ===== BACKUP =====
  late String _bkName, _bkDob, _bkHeight, _bkWeight;
  String? _bkGender;
  File? _bkAvatar;

  @override
  void initState() {
    super.initState();
    _loadFromStore();
  }

  void _loadFromStore() {
    final p = ProfileStore.profile.value;
    if (p == null) {
      _nameCtrl.text = 'Username';
      _dobCtrl.text = '';
      _gender = null;
      _heightCtrl.text = '';
      _weightCtrl.text = '';
      _avatarFile = null;
      return;
    }

    _nameCtrl.text = p.fullName;
    _dobCtrl.text = p.dob;
    _gender = p.gender.isEmpty ? null : p.gender;
    _heightCtrl.text = p.height;
    _weightCtrl.text = p.weight;
    _avatarFile = p.avatarFile;
  }

  // ===== ACTIONS =====
  void _startEdit() {
    _bkName = _nameCtrl.text;
    _bkDob = _dobCtrl.text;
    _bkGender = _gender;
    _bkHeight = _heightCtrl.text;
    _bkWeight = _weightCtrl.text;
    _bkAvatar = _avatarFile;

    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    _nameCtrl.text = _bkName;
    _dobCtrl.text = _bkDob;
    _gender = _bkGender;
    _heightCtrl.text = _bkHeight;
    _weightCtrl.text = _bkWeight;
    _avatarFile = _bkAvatar;

    setState(() => _isEditing = false);
  }

  Future<void> _saveEdit() async {
    final ok = await showConfirmSaveDialog(context);
    if (!ok) return;

    ProfileStore.profile.value = UserProfile(
      fullName: _nameCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      gender: (_gender ?? '').trim(),
      height: _heightCtrl.text.trim(),
      weight: _weightCtrl.text.trim(),
      avatarFile: _avatarFile,
    );

    setState(() => _isEditing = false);
    await showSaveSuccessDialog(context);
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _profileCard(),
              const SizedBox(height: 20),
              _sectionTitle(),
              const SizedBox(height: 10),
              _formFields(),
              const SizedBox(height: 24),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: 350,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
            child: ClipOval(
              child: _avatarFile == null
                  ? const Icon(Icons.person, size: 40)
                  : Image.file(_avatarFile!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _nameCtrl.text.isEmpty ? 'Username' : _nameCtrl.text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 8),
          if (_isEditing)
            SizedBox(
              height: 30,
              child: OutlinedButton(
                onPressed: _pickAvatar,
                child: const Text('Change Avatar'),
              ),
            ),
        ],
      ),
    );
  }

  // ===== SECTION TITLE =====
  Widget _sectionTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Basic Information',
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 17,
          color: Colors.black,
        ),
      ),
    );
  }

  // ===== FORM FIELDS =====
  Widget _formFields() {
    return Column(
      children: [
        _profileField(
          label: 'Full Name',
          icon: Icons.person_outline,
          ctrl: _nameCtrl,
          readOnly: !_isEditing,
        ),
        _profileField(
          label: 'Date of Birth',
          icon: Icons.calendar_today_outlined,
          ctrl: _dobCtrl,
          readOnly: true,
          onTap: _isEditing ? _pickDob : null,
        ),
        _genderField(),
        _profileField(
          label: 'Height',
          icon: Icons.height_rounded,
          ctrl: _heightCtrl,
          readOnly: !_isEditing,
          keyboardType: TextInputType.number,
        ),
        _profileField(
          label: 'Weight',
          icon: Icons.monitor_weight_outlined,
          ctrl: _weightCtrl,
          readOnly: !_isEditing,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  // ===== FIELD (ĐỒNG BỘ STYLE) =====
  Widget _profileField({
    required String label,
    required IconData icon,
    required TextEditingController ctrl,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isEditing ? _blue : Colors.grey.shade300,
            width: _isEditing ? 2 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: _blue),
                const SizedBox(width: 4), // ✅ đồng bộ
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500, // ✅ đồng bộ
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: TextField(
                controller: ctrl,
                readOnly: readOnly,
                onTap: onTap,
                keyboardType: keyboardType,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== GENDER (ĐỒNG BỘ 4 Ý) =====
  Widget _genderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isEditing ? _blue : Colors.grey.shade300,
            width: _isEditing ? 2 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.wc_outlined, size: 18, color: _blue),
                SizedBox(width: 4), // ✅ đồng bộ (trước là 6)
                Text(
                  'Gender',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500, // ✅ đồng bộ (trước w700)
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: IgnorePointer(
                ignoring: !_isEditing, // view mode: không bấm, nhưng không mờ
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _gender,
                    isExpanded: true,
                    isDense: true,
                    iconSize: 20,
                    onChanged: (v) {
                      if (!_isEditing) return;
                      setState(() => _gender = v);
                    },
                    style: const TextStyle(
                      fontSize: 16, // ✅ đồng bộ (trước 15.5)
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: Colors.black,
                    ),
                    hint: const Text(
                      'Select',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black38,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
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
