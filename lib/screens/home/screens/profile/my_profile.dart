import 'package:flutter/material.dart';

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

  // ===== STATE =====
  bool _isEditing = false;

  // ===== CONTROLLERS =====
  final _nameCtrl = TextEditingController(text: 'Nguyen Thi Mai');
  final _dobCtrl = TextEditingController(text: '28/10/1952');
  final _genderCtrl = TextEditingController(text: 'Female');
  final _heightCtrl = TextEditingController(text: '1m60');
  final _weightCtrl = TextEditingController(text: '45kg');

  // ===== BACKUP =====
  late String _bkName, _bkDob, _bkGender, _bkHeight, _bkWeight;

  // ===== EDIT ACTIONS =====
  void _startEdit() {
    _bkName = _nameCtrl.text;
    _bkDob = _dobCtrl.text;
    _bkGender = _genderCtrl.text;
    _bkHeight = _heightCtrl.text;
    _bkWeight = _weightCtrl.text;

    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    _nameCtrl.text = _bkName;
    _dobCtrl.text = _bkDob;
    _genderCtrl.text = _bkGender;
    _heightCtrl.text = _bkHeight;
    _weightCtrl.text = _bkWeight;

    setState(() => _isEditing = false);
  }

  Future<void> _saveEdit() async {
    final ok = await showConfirmSaveDialog(context);
    if (!ok) return;

    setState(() => _isEditing = false);
    await showSaveSuccessDialog(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _genderCtrl.dispose();
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            children: [
              _avatar(),
              const SizedBox(height: 18),
              _sectionTitle('Basic Information'),
              const SizedBox(height: 10),
              _field('Full Name', _nameCtrl),
              _field('Date of Birth', _dobCtrl),
              _field('Gender', _genderCtrl),
              _field('Height', _heightCtrl),
              _field('Weight', _weightCtrl),
              const SizedBox(height: 24), // 👈 chừa đáy cho keyboard
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
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
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

  // ===== AVATAR =====
  Widget _avatar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
          ),
          const SizedBox(height: 10),
          Text(
            _nameCtrl.text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          if (_isEditing)
            TextButton(
              onPressed: () {},
              child: const Text('Change Avatar'),
            ),
        ],
      ),
    );
  }

  // ===== SECTION TITLE =====
  Widget _sectionTitle(String t) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        t,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.black54,
        ),
      ),
    );
  }

  // ===== FIELD =====
  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        readOnly: !_isEditing,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: _fieldBg,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _blue, width: 1.2),
          ),
        ),
      ),
    );
  }
}

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
