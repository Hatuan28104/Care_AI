import 'package:flutter/material.dart';
import 'package:Care_AI/screens/home/home.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'profile_store.dart'; // ✅ thêm

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  // ===== CONSTANTS =====
  static const _blue = Color(0xFF1F6BFF);
  static const _bg = Color(0xFFF3F5F9);
  static const _fieldBg = Color(0xFFF3F5FF);

  // ===== FORM =====
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String? _gender;
  final _picker = ImagePicker();
  File? _avatarFile;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  // ===== INPUT DECORATION =====
  InputDecoration _dec(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: _fieldBg,
      prefixIcon: Icon(icon, size: 20, color: Colors.black54),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _blue, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.4),
      ),
    );
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
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() {
      _avatarFile = File(picked.path);
    });
  }

  void _onContinue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // ✅ Lưu tạm profile (không cần backend)
    ProfileStore.profile.value = UserProfile(
      fullName: _nameCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      gender: _gender ?? '',
      height: _heightCtrl.text.trim(),
      weight: _weightCtrl.text.trim(),
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
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _profileCard(),
                const SizedBox(height: 20),
                _sectionTitle(),
                const SizedBox(height: 10),
                _formFields(),
                const SizedBox(height: 24),
                _continueButton(),
              ],
            ),
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
        'Create Profile',
        style: TextStyle(
            fontWeight: FontWeight.w800, fontSize: 24, color: Colors.black),
      ),
    );
  }

  // ===== HEADER =====
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

            // ✅ giữ UI như cũ, chỉ thay icon -> ảnh nếu có
            child: ClipOval(
              child: _avatarFile == null
                  ? const Icon(Icons.person, size: 40)
                  : Image.file(
                      _avatarFile!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Username',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: OutlinedButton(
              onPressed: _pickAvatar,
              child: const Text('Upload Avatar'),
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
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 17,
          color: Colors.black.withOpacity(.75),
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
          controller: _nameCtrl,
        ),
        _profileField(
          label: 'Date of Birth',
          icon: Icons.calendar_today_outlined,
          controller: _dobCtrl,
          readOnly: true,
          onTap: _pickDob,
        ),
        _genderField(),
        _profileField(
          label: 'Height',
          icon: Icons.height_rounded,
          controller: _heightCtrl,
          keyboardType: TextInputType.number,
        ),
        _profileField(
          label: 'Weight',
          icon: Icons.monitor_weight_outlined,
          controller: _weightCtrl,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _profileField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
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
            color: Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: _blue),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: TextFormField(
                controller: controller,
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
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Please enter $label' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.wc_outlined, size: 18, color: _blue),
                SizedBox(width: 4),
                Text(
                  'Gender',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: DropdownButtonFormField<String>(
                value: _gender,
                isExpanded: true,
                isDense: true,
                iconSize: 20,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
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
                onChanged: (v) => setState(() => _gender = v),
                validator: (v) => v == null ? 'Please choose gender' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== BUTTON =====
  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
