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
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  ipn.PhoneNumber? _phone;
  String _rawNumber = '';
  String _completePhone = '';

  String _buildE164(ipn.PhoneNumber p) {
    final raw = p.number.trim();
    final iso = p.countryISOCode;
    final dial = p.countryCode;

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
    if (!ok || _phone == null) return;

    _completePhone = _buildE164(_phone!);
    if (_completePhone.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterOtpScreen(
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
    const errorMsg = 'Please check and enter valid phone number !';

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
          'Register',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D459F),
          ),
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
                const SizedBox(height: 20),

                /// ===== PHONE FIELD (BO TRÒN ĐÚNG NHƯ HÌNH) =====
                FormField<ipn.PhoneNumber>(
                  validator: (value) {
                    if (value == null) return errorMsg;

                    final raw = value.number.trim();
                    final iso = value.countryISOCode;

                    if (raw.isEmpty) return errorMsg;

                    if (iso == 'VN') {
                      final vn = raw.startsWith('0') ? raw.substring(1) : raw;
                      if (!RegExp(r'^\d{9}$').hasMatch(vn)) return errorMsg;
                      return null;
                    }

                    if (!value.isValidNumber()) return errorMsg;
                    return null;
                  },
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: fieldBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: state.hasError
                                  ? Colors.red
                                  : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: IntlPhoneField(
                            initialCountryCode: 'VN',
                            disableLengthCheck: true,
                            dropdownIcon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Phone number',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            onChanged: (p) {
                              _phone = p;
                              _rawNumber = p.number.trim();
                              state.didChange(p);
                            },
                          ),
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

                /// ===== CONTINUE BUTTON =====
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// ===== TERMS TEXT =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 0, 0, 0),
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: 'By registering you agree to '),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            color: Color(0xFF1F6BFF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: '\nand '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Color(0xFF1F6BFF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: ' of the Care AI'),
                      ],
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
