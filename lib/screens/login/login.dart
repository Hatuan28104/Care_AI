import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart' as ipn;

import 'login_otp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _submitted = false;

  // lưu phone đã chọn/nhập
  ipn.PhoneNumber? _phone;

  // hiển thị (0xxx... hoặc số user nhập)
  String _rawNumber = '';

  // E.164 (+84xxxxxxxxx)
  String _completePhone = '';

  String _buildE164(ipn.PhoneNumber p) {
    final raw = p.number.trim();
    final iso = p.countryISOCode;
    final dial = p.countryCode; // "84"

    if (iso == 'VN') {
      final national = raw.startsWith('0') ? raw.substring(1) : raw;
      return national.isEmpty ? '' : '+$dial$national';
    }
    return p.completeNumber;
  }

  void _onContinue() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final p = _phone;
    if (p == null) return;

    _completePhone = _buildE164(p);
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

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1F6BFF);
    const bg = Color(0xFFF3F5F9);
    const fieldBg = Color(0xFFF3F5FF);

    const msg = 'Please check and enter valid phone number !';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
        ),
        title: const Text(
          'Log in',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Welcome back you've\nbeen missed!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 22),

                // ✅ BẮT BUỘC: FormField để validate chắc chắn dù chưa gõ gì
                FormField<ipn.PhoneNumber>(
                  validator: (value) {
                    if (value == null) return msg;

                    final raw = value.number.trim();
                    final iso = value.countryISOCode;

                    if (raw.isEmpty) return msg;

                    if (iso == 'VN') {
                      final vn = raw.startsWith('0') ? raw.substring(1) : raw;
                      if (!RegExp(r'^\d{9}$').hasMatch(vn)) return msg;
                      return null;
                    }

                    // nước khác: dùng validate của package
                    if (!value.isValidNumber()) return msg;
                    return null;
                  },
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntlPhoneField(
                          initialCountryCode: 'VN',
                          keyboardType: TextInputType.phone,
                          disableLengthCheck: true,
                          dropdownIcon:
                              const Icon(Icons.keyboard_arrow_down_rounded),
                          dropdownIconPosition: IconPosition.trailing,
                          decoration: InputDecoration(
                            hintText: 'Phone number',
                            filled: true,
                            fillColor: fieldBg,
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: blue, width: 1.2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 1.2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 1.2),
                            ),
                          ),
                          onChanged: (p) {
                            // cập nhật value cho FormField => validate mới chạy chuẩn
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
                    );
                  },
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
