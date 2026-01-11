import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart' as ipn;

class RegisterForm extends StatefulWidget {
  final void Function(String phoneE164, String displayPhone) onOtp;

  const RegisterForm({
    super.key,
    required this.onOtp,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  // ===== CONSTANTS =====
  static const _primaryColor = Color(0xFF1F41BB);
  static const _buttonColor = Color(0xFF1877F2);
  static const _fieldBg = Color(0xFFF6F6F6);
  static const _errorMsg = 'Vui lòng kiểm tra và nhập đúng số điện thoại!';

  static const _borderSide = BorderSide(
    color: Color(0xFFCFCECE),
    width: 1,
  );

  static const _hintStyle = TextStyle(
    fontSize: 16,
    color: Color(0xFFD1D1D1),
    fontWeight: FontWeight.w400,
  );

  // ===== FORM =====
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  ipn.PhoneNumber? _phone;
  String _rawNumber = '';

  // ===== HELPERS =====
  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: _borderSide,
    );
  }

  String _buildE164(ipn.PhoneNumber p) {
    if (p.countryISOCode == 'VN') {
      final n = p.number.startsWith('0') ? p.number.substring(1) : p.number;
      return '+${p.countryCode}$n';
    }
    return p.completeNumber;
  }

  void _onContinue() {
    setState(() => _submitted = true);

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_phone == null) return;

    final phone = _buildE164(_phone!);

    // ✅ CHỈ BÁO AUTH – KHÔNG PUSH
    widget.onOtp(phone, _rawNumber);
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Đăng ký',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tạo tài khoản Care AI',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Bắt đầu chăm sóc sức khoẻ cùng trợ lý AI',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        const SizedBox(height: 18),

        // ===== FORM =====
        Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: FormField<ipn.PhoneNumber>(
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
                  decoration: InputDecoration(
                    hintText: 'Số điện thoại',
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: _fieldBg,
                    enabledBorder: _border(),
                    focusedBorder: _border(),
                    errorBorder: _border(),
                    focusedErrorBorder: _border(),
                  ),
                  onChanged: (p) {
                    _phone = p;
                    _rawNumber = p.number.trim();
                    state.didChange(p);
                  },
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 6),
                    child: Text(
                      state.errorText ?? '',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // ===== BUTTON =====
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: _buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Tiếp tục',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        _termsText(),
      ],
    );
  }

  // ===== TERMS =====
  Widget _termsText() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          children: [
            TextSpan(text: 'Khi đăng ký, bạn xác nhận đã đồng ý với các\n'),
            TextSpan(
              text: 'điều khoản',
              style: TextStyle(color: Color(0xFF1877F2)),
            ),
            TextSpan(text: ' và '),
            TextSpan(
              text: 'chính sách bảo mật',
              style: TextStyle(color: Color(0xFF1877F2)),
            ),
            TextSpan(text: ' của Care AI.'),
          ],
        ),
      ),
    );
  }
}
