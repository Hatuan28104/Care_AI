import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Care_AI/widgets/success_dialog.dart';
import 'package:Care_AI/screens/welcome_screen.dart';

class RegisterOtp extends StatefulWidget {
  final String displayPhone;
  final VoidCallback onBack;

  const RegisterOtp({
    super.key,
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

  static const _mockOtp = '123456'; // ✅ OTP đúng tạm thời

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

    // ❌ Sai OTP
    if (!RegExp(r'^\d{6}$').hasMatch(otp) || otp != _mockOtp) {
      setState(() {
        _errorText = 'Mã OTP nhập không chính xác!';
      });
      return;
    }

    if (_loading) return;

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await SuccessDialog.show(
        context,
        title: 'Đăng ký thành công',
        message: 'Hãy bắt đầu trải nghiệm Care AI.',
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onResend() {
    if (_secondsLeft > 0) return;

    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    _startTimer();
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
            color: _primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Mã OTP đã được gửi đến số điện thoại\n${widget.displayPhone}:',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
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
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: _otpBg,
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
              : const Text(
                  'Tiếp tục',
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
            ? 'Gửi lại mã OTP trong ${_mmss(_secondsLeft)}'
            : 'Gửi lại mã OTP',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: disabled ? Colors.black38 : _primary,
        ),
      ),
    );
  }
}
