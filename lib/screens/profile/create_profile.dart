import 'package:flutter/material.dart';
import 'package:Care_AI/screens/home/home.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

      // ===== VIỀN XÁM =====
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
            child: const Icon(Icons.person, size: 40),
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
        TextFormField(
          controller: _nameCtrl,
          decoration: _dec('Full Name', Icons.person_outline),
          validator: (v) =>
              (v ?? '').trim().isEmpty ? 'Please enter full name' : null,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _dobCtrl,
          readOnly: true,
          onTap: _pickDob,
          decoration: _dec('Date of Birth', Icons.calendar_today_outlined),
          validator: (v) =>
              (v ?? '').trim().isEmpty ? 'Please select date of birth' : null,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: _dec('Gender', Icons.wc_outlined),
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (v) => setState(() => _gender = v),
          validator: (v) => v == null ? 'Please choose gender' : null,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _heightCtrl,
          keyboardType: TextInputType.number,
          decoration: _dec('Height', Icons.height_rounded),
          validator: (v) =>
              (v ?? '').trim().isEmpty ? 'Please enter height' : null,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _weightCtrl,
          keyboardType: TextInputType.number,
          decoration: _dec('Weight', Icons.monitor_weight_outlined),
          validator: (v) =>
              (v ?? '').trim().isEmpty ? 'Please enter weight' : null,
        ),
      ],
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
