import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart' as ipn;
import 'package:Care_AI/screens/settings/privacy_security/terms_of_service.dart';
import 'package:Care_AI/screens/settings/privacy_security/privacy_policy.dart';
import 'package:Care_AI/api/auth_api.dart';
import '../../models/tr.dart';

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
  String get _errorMsg => context.tr.invalidPhone;
  String? _serverError;

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

  Future<void> _onContinue() async {
    setState(() => _submitted = true);

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_phone == null) return;

    final phone = _buildE164(_phone!);

    try {
      await AuthApi.requestRegisterOtp(phone);

      widget.onOtp(phone, _rawNumber);
    } catch (e) {
      setState(() {
        _serverError = e.toString().replaceFirst('Exception: ', '');
      });

      _formKey.currentState?.validate();
    }
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.tr.register,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.tr.createAccount,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr.startHealthJourney,
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
              if (_serverError != null) return _serverError;

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
                  searchText: context.tr.searchCountry,
                  decoration: InputDecoration(
                    hintText: context.tr.phoneNumber,
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
                    _serverError = null;
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
            child: Text(
              context.tr.continueButton,
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
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '${context.tr.registerAgree}\n',
            ),
            TextSpan(
              text: context.tr.terms,
              style: const TextStyle(color: Color(0xFF1877F2)),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TermsOfServiceScreen(),
                    ),
                  );
                },
            ),
            TextSpan(
              text: ' ${context.tr.and} ',
            ),
            TextSpan(
              text: context.tr.privacy_Policy,
              style: const TextStyle(color: Color(0xFF1877F2)),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
            ),
            TextSpan(
              text: ' ${context.tr.ofCareAI}',
            ),
          ],
        ),
      ),
    );
  }
}
