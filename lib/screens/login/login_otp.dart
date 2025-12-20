import 'dart:async';
import 'package:flutter/material.dart';

import 'package:Care_AI/widgets/success_dialog.dart';
import 'package:Care_AI/screens/profile/create_profile.dart';

import 'package:Care_AI/app_settings.dart';

class LoginOtpScreen extends StatefulWidget {
  final String phoneE164;
  final String displayPhone;

  const LoginOtpScreen({
    super.key,
    required this.phoneE164,
    required this.displayPhone,
  });

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  // ===== CONSTANTS =====
  static const _blue = Color(0xFF1F6BFF);
  static const _bg = Color(0xFFF3F5F9);
  static const _fieldBg = Color(0xFFF3F5FF);

  // ===== FORM =====
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();

  bool _submitted = false;
  bool _loading = false;

  // ===== TIMER =====
  Timer? _timer;
  int _secondsLeft = 90;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    super.dispose();
  }

  // ===== TIMER =====
  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 90;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        if (mounted) setState(() => _secondsLeft = 0);
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  String _mmss(int s) => '${(s ~/ 60)}:${(s % 60).toString().padLeft(2, '0')}';

  // ✅ format hiển thị giống ảnh: "(+84) 123 456 789"
  String _formatPhoneForUi(String e164) {
    if (e164.startsWith('+84')) {
      final n = e164.substring(3); // phần sau +84
      if (n.length >= 9) {
        final a = n.substring(0, 3);
        final b = n.substring(3, 6);
        final c = n.substring(6);
        return '(+84) $a $b $c';
      }
    }
    return e164;
  }

  // ===== ACTIONS =====
  Future<void> _onContinue() async {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_loading) return;
    setState(() => _loading = true);

    try {
      // TODO: verify login OTP
      // await AuthApi.verifyLoginOtp(phone: widget.phoneE164, otp: _otpCtrl.text);

      if (!mounted) return;

      await SuccessDialog.show(
        context,
        title: 'Successful Login',
      );

      if (!mounted) return;

      // ✅ 1) Lưu phone number để Privacy & Security show
      AppSettings.phoneNumber.value = _formatPhoneForUi(widget.phoneE164);

      // ✅ 2) Demo Login History (sau này backend trả về thì thay)
      AppSettings.loginHistory.value = [
        LoginHistoryItem(
          device: 'iPhone 13',
          location: 'Ho Chi Minh City',
          time: 'Today, 10:30AM',
        ),
        LoginHistoryItem(
          device: 'iPad Pro',
          location: 'Ho Chi Minh City',
          time: '2 days ago, 9:00AM',
        ),
      ];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateProfileScreen(
            phone: _formatPhoneForUi(widget.phoneE164),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Verify failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onResend() async {
    if (_secondsLeft > 0) return;

    // TODO: resend OTP
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP resent to ${widget.phoneE164}')),
    );

    _startTimer();
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _header(),
                const SizedBox(height: 8),
                _otpField(),
                const Spacer(),
                _continueButton(),
                const SizedBox(height: 16),
                _resendText(),
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
        'Log in',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0D459F),
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Welcome back you've \nbeen missed!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter the OTP sent ${widget.displayPhone}',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ===== OTP FIELD =====
  Widget _otpField() {
    return TextFormField(
      controller: _otpCtrl,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        hintText: 'OTP',
        filled: true,
        fillColor: _fieldBg,
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
      ),
      validator: (v) {
        final s = (v ?? '').trim();
        if (s.isEmpty) return 'Please enter OTP';
        if (!RegExp(r'^\d{6}$').hasMatch(s)) return 'OTP must be 6 digits';
        return null;
      },
    );
  }

  // ===== BUTTON =====
  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _loading ? null : _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
      ),
    );
  }

  // ===== RESEND =====
  Widget _resendText() {
    return Center(
      child: GestureDetector(
        onTap: _onResend,
        child: Text(
          _secondsLeft > 0
              ? 'Resend OTP in ${_mmss(_secondsLeft)}'
              : 'Resend OTP',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _secondsLeft > 0 ? Colors.black54 : _blue,
          ),
        ),
      ),
    );
  }
}
