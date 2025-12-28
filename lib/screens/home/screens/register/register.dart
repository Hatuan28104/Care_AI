import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart' as ipn;

import 'register_otp.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ===== CONSTANTS =====
  static const _primary = Color(0xFF1F6BFF);
  static const _bg = Color(0xFFF3F5F9);
  static const _fieldBg = Color(0xFFF3F5FF);
  static const _errorMsg = 'Please check and enter valid phone number !';

  // ===== FORM =====
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  ipn.PhoneNumber? _phone;
  String _rawNumber = '';
  String _completePhone = '';

  // ===== LOGIC =====
  String _buildE164(ipn.PhoneNumber p) {
    if (p.countryISOCode == 'VN') {
      final n = p.number.startsWith('0') ? p.number.substring(1) : p.number;
      return n.isEmpty ? '' : '+${p.countryCode}$n';
    }
    return p.completeNumber;
  }

  void _onContinue() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);

    if (!(_formKey.currentState?.validate() ?? false) || _phone == null) return;

    _completePhone = _buildE164(_phone!);
    if (_completePhone.isEmpty) return;

    _go(
      context,
      RegisterOtpScreen(
        phoneE164: _completePhone,
        displayPhone: _rawNumber,
      ),
    );
  }

  // ===== NAVIGATION =====
  static void _go(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ===== CONTENT =====
                _phoneField(),

                const Spacer(),

                // ===== ACTION =====
                _primaryButton(
                  text: 'Continue',
                  onPressed: _onContinue,
                ),

                const SizedBox(height: 12),
                _termsText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== APP BAR =====
  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
        'Register',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0D459F),
        ),
      ),
    );
  }

  // ===== PHONE FIELD =====
  Widget _phoneField() {
    return FormField<ipn.PhoneNumber>(
      validator: (v) {
        if (v == null || v.number.trim().isEmpty) return _errorMsg;

        if (v.countryISOCode == 'VN') {
          final n = v.number.startsWith('0') ? v.number.substring(1) : v.number;
          return RegExp(r'^\d{9}$').hasMatch(n) ? null : _errorMsg;
        }

        return v.isValidNumber() ? null : _errorMsg;
      },
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntlPhoneField(
            initialCountryCode: 'VN',
            disableLengthCheck: true,
            dropdownIcon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: _phoneDecoration(state.hasError),
            onChanged: (p) {
              _phone = p;
              _rawNumber = p.number.trim();
              state.didChange(p);
            },
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12),
              child: Text(
                state.errorText ?? '',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _phoneDecoration(bool hasError) {
    return InputDecoration(
      hintText: 'Phone number',
      filled: true,
      fillColor: _fieldBg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      enabledBorder: _outline(Colors.grey.shade300),
      focusedBorder: _outline(_primary, 1.4),
      errorBorder: _outline(Colors.red),
      focusedErrorBorder: _outline(Colors.red, 1.4),
    );
  }

  OutlineInputBorder _outline(Color color, [double w = 1.2]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: w),
    );
  }

  // ===== BUTTON =====
  static Widget _primaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ===== TERMS =====
  Widget _termsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            height: 1.4,
          ),
          children: const [
            TextSpan(text: 'By registering you agree to '),
            TextSpan(
              text: 'Terms & Conditions',
              style: TextStyle(
                color: _primary, // ✅ HẾT ĐỎ
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: '\nand '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                color: _primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: ' of the Care AI'),
          ],
        ),
      ),
    );
  }
}
