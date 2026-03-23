import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Care_AI/widgets/success_dialog.dart';
import 'package:Care_AI/screens/welcome_screen.dart';
import 'package:Care_AI/api/auth_api.dart';
import 'package:Care_AI/models/tr.dart';

class RegisterOtp extends StatefulWidget {
  final String phoneE164;
  final String displayPhone;
  final VoidCallback onBack;

  const RegisterOtp({
    super.key,
    required this.phoneE164,
    required this.displayPhone,
    required this.onBack,
  });

  @override
  State<RegisterOtp> createState() => _RegisterOtpState();
}

class _RegisterOtpState extends State<RegisterOtp> {
  // ===== CONSTANTS =====
  static const _primary = Color(0xFF1F41BB);
  static const _button = Color(0xFF1877F2);
  static const _otpBg = Color(0xFFF6F6F6);
  static const _border = Color(0xFFCFCECE);

  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = 90;
  bool _loading = false;
  String? _errorText;

  // ===== LIFECYCLE =====
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ===== TIMER =====
  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 90;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String _mmss(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  // ===== ACTION =====
  Future<void> _onContinue() async {
    final otp = _controllers.map((e) => e.text).join();

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      setState(() {
        _errorText = context.tr.invalidOtp;
      });
      return;
    }

    if (_loading) return;

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      // 🔥 GỌI BACKEND VERIFY OTP
      await AuthApi.verifyOtp(widget.phoneE164, otp);

      if (!mounted) return;

      await SuccessDialog.show(
        context,
        title: context.tr.registerSuccess,
        message: context.tr.startUsingApp,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    } catch (e) {
      setState(() {
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onResend() async {
    if (_secondsLeft > 0) return;

    try {
      // 🔥 GỬI LẠI OTP ĐĂNG KÝ
      await AuthApi.requestRegisterOtp(widget.phoneE164);

      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
            color: _primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          context.tr.otpSentTo(widget.displayPhone),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 32),
        _otpBoxes(),
        if (_errorText != null) ...[
          const SizedBox(height: 10),
          Text(
            _errorText!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const Spacer(),
        _continueButton(),
        const SizedBox(height: 14),
        _resendText(),
      ],
    );
  }

  // ===== OTP BOXES =====
  Widget _otpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: SizedBox(
            width: 45,
            height: 45,
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              maxLength: 1,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 18,
                height: 1.2, // 🔥 QUAN TRỌNG
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: _otpBg,
                contentPadding: EdgeInsets.zero, // 🔥 QUAN TRỌNG
                enabledBorder: _borderStyle(),
                focusedBorder: _borderStyle(),
              ),
              onChanged: (v) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }

                if (v.isNotEmpty && i < 5) {
                  _focusNodes[i + 1].requestFocus();
                }
                if (v.isEmpty && i > 0) {
                  _focusNodes[i - 1].requestFocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }

  OutlineInputBorder _borderStyle() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      );

  Widget _continueButton() => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _loading ? null : _onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: _button,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  context.tr.continueButton,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      );

  Widget _resendText() {
    final disabled = _secondsLeft > 0;
    return GestureDetector(
      onTap: disabled ? null : _onResend,
      child: Text(
        disabled
            ? '${context.tr.resendOtp} ${_mmss(_secondsLeft)}'
            : context.tr.resendOtp,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: disabled ? Colors.black38 : _primary,
        ),
      ),
    );
  }
}
