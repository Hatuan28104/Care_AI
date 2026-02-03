import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Care_AI/api/auth_api.dart';
import 'package:Care_AI/api/profile_api.dart' as profile_api;
import 'package:Care_AI/models/current_user.dart';
import 'package:Care_AI/screens/home/home.dart';

import 'package:Care_AI/screens/settings/profile/create_profile.dart';

class LoginOtpScreen extends StatefulWidget {
  final String phoneE164;
  final String displayPhone;
  final VoidCallback onBack;

  const LoginOtpScreen({
    super.key,
    required this.phoneE164,
    required this.displayPhone,
    required this.onBack,
  });

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
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
    if (_loading) return; // 🔒 chặn double call

    final otp = _controllers.map((e) => e.text).join();

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      setState(() => _errorText = 'Mã OTP không hợp lệ');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      // 1️⃣ Verify OTP
      final user = await AuthApi.verifyOtp(widget.phoneE164, otp);
      if (!mounted) return;

      // 2️⃣ Lưu user
      CurrentUser.user = user;

      // 3️⃣ Check profile
      Map<String, dynamic>? profile;

      try {
        print('🟡 CHECK PROFILE ID = ${user.nguoiDungId}');

        profile = await profile_api.ProfileApi.getProfile(user.nguoiDungId);

        print('🟢 PROFILE RESULT = $profile');
      } catch (e, s) {
        print('🔴 GET PROFILE ERROR = $e');
        print('📌 STACKTRACE = $s');

        profile = null; // 🔥 coi như chưa có profile
      }

      if (!mounted) return;

      if (profile == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CreateProfileScreen(
              nguoiDungId: user.nguoiDungId,
              phone: user.soDienThoai,
            ),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

      return; // 🔥 BẮT BUỘC
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onResend() async {
    if (_secondsLeft > 0) return;

    try {
      // 🔥 LOGIN resend
      await AuthApi.requestLoginOtp(widget.phoneE164);

      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          e.toString().replaceFirst('Exception: ', ''),
        )),
      );
    }
  }

  // ===== UI (COPY TỪ REGISTER OTP) =====
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Đăng nhập',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Mã OTP đã được gửi đến số điện thoại\n${widget.displayPhone}:',
          textAlign: TextAlign.center,
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

                if (i == 5 && v.isNotEmpty && !_loading) {
                  FocusScope.of(context).unfocus();
                  _onContinue();
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
