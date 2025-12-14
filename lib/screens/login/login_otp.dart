import 'dart:async';
import 'package:flutter/material.dart';

import 'package:Care_AI/widgets/success_dialog.dart';
import 'package:Care_AI/screens/profile/create_profile.dart';

class LoginOtpScreen extends StatefulWidget {
  final String phoneE164; // +84...
  final String displayPhone; // 0...

  const LoginOtpScreen({
    super.key,
    required this.phoneE164,
    required this.displayPhone,
  });

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();

  Timer? _timer;
  int _secondsLeft = 90;

  bool _submitted = false;
  bool _loading = false;

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

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 90);

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

  Future<void> _onContinue() async {
    setState(() => _submitted = true);

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_loading) return;
    setState(() => _loading = true);

    final otp = _otpCtrl.text.trim();

    try {
      // ✅ TODO: LOGIN verify OTP (API/Firebase)
      // await AuthApi.verifyLoginOtp(phone: widget.phoneE164, otp: otp);

      if (!mounted) return;

      // ✅ Popup thành công
      await SuccessDialog.show(
        context,
        title: 'Successful Login',
      );

      if (!mounted) return;

      // ✅ qua Create Profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Verify failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onResend() async {
    if (_secondsLeft > 0) return;

    // ✅ TODO: resend OTP
    // await AuthApi.resendLoginOtp(phone: widget.phoneE164);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP resent to ${widget.phoneE164}')),
    );

    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1F6BFF);
    const bg = Color(0xFFF3F5F9);
    const fieldBg = Color(0xFFF3F5FF);

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
                const SizedBox(height: 6),
                const Text(
                  "Welcome back you've\nbeen missed!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter the OTP sent ${widget.displayPhone}',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: 'OTP',
                    filled: true,
                    fillColor: fieldBg,
                    counterText: '',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    suffixIcon: IconButton(
                      onPressed: () => _otpCtrl.clear(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: blue, width: 1.2),
                    ),
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Please enter OTP';
                    if (!RegExp(r'^\d{6}$').hasMatch(s)) {
                      return 'OTP must be 6 digits';
                    }
                    return null;
                  },
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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
                ),

                const SizedBox(height: 14),

                GestureDetector(
                  onTap: _onResend,
                  child: Text(
                    _secondsLeft > 0
                        ? 'Resend OTP in ${_mmss(_secondsLeft)}'
                        : 'Resend OTP',
                    style: TextStyle(
                      fontSize: 12,
                      color: _secondsLeft > 0 ? Colors.black54 : blue,
                      fontWeight: FontWeight.w700,
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
