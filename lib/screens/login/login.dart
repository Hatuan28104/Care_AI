import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart' as ipn;

import 'package:Care_AI/ui.dart';
import 'login_otp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ===== CONSTANTS =====
  static const _blue = Color(0xFF1F6BFF);
  static const _fieldBg = Color(0xFFF3F5FF);
  static const _errorMsg = 'Please check and enter valid phone number !';

  // ===== FORM =====
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  ipn.PhoneNumber? _phone;
  String _rawNumber = '';
  String _completePhone = '';

  // ===== HELPERS =====
  String _buildE164(ipn.PhoneNumber p) {
    final raw = p.number.trim();
    if (p.countryISOCode == 'VN') {
      final national = raw.startsWith('0') ? raw.substring(1) : raw;
      return national.isEmpty ? '' : '+${p.countryCode}$national';
    }
    return p.completeNumber;
  }

  void _goOtp(BuildContext context) {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_phone == null) return;

    _completePhone = _buildE164(_phone!);
    if (_completePhone.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginOtpScreen(
          phoneE164: _completePhone,
          displayPhone: _rawNumber,
        ),
      ),
    );
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UI.bg, // ✅ bg chung
      appBar: _appBar(context),
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
                const SizedBox(height: 16),
                _welcomeText(),
                const SizedBox(height: 22),
                _phoneField(),
                const Spacer(),
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
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Log in',
        style: UI.primaryTitle.copyWith(
          color: const Color(0xFF0D459F),
        ),
      ),
    );
  }

  // ===== WELCOME TEXT =====
  Widget _welcomeText() {
    return const Text(
      "Welcome back you've\nbeen missed!",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // ===== PHONE FIELD =====
  Widget _phoneField() {
    return FormField<ipn.PhoneNumber>(
      validator: (value) {
        if (value == null) return _errorMsg;

        final raw = value.number.trim();
        if (raw.isEmpty) return _errorMsg;

        if (value.countryISOCode == 'VN') {
          final vn = raw.startsWith('0') ? raw.substring(1) : raw;
          return RegExp(r'^\d{9}$').hasMatch(vn) ? null : _errorMsg;
        }

        return value.isValidNumber() ? null : _errorMsg;
      },
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntlPhoneField(
            initialCountryCode: 'VN',
            disableLengthCheck: true,
            dropdownIcon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: InputDecoration(
              hintText: 'Phone number',
              filled: true,
              fillColor: _fieldBg,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _blue, width: 1.4),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.4),
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
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

  // ===== CONTINUE BUTTON =====
  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _goOtp(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }
}
