import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Care_AI/api/auth_api.dart';
import 'package:Care_AI/api/profile_api.dart' as profile_api;
import 'package:Care_AI/models/current_user.dart';
import 'package:Care_AI/screens/home/home.dart';
import 'package:Care_AI/api/auth_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Care_AI/api/settings_api.dart';
import 'package:Care_AI/screens/settings/profile/create_profile.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/config/api_config.dart';

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

  Future<void> _onContinue() async {
    if (_loading) return;

    final otp = _controllers.map((e) => e.text).join();

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      setState(() => _errorText = context.tr.invalidOtp);
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final user = await AuthApi.verifyOtp(widget.phoneE164, otp);
      if (!mounted) return;

      CurrentUser.user = user;

      _syncUserData(user.nguoiDungId);

      _sendFcmToken();

      Map<String, dynamic>? profile;

      if (user.profileCompleted != true) {
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

      try {
        print('CHECK PROFILE ID = ${user.nguoiDungId}');
        profile = await profile_api.ProfileApi.getProfile(user.nguoiDungId);
        print('PROFILE RESULT = $profile');
      } catch (e, s) {
        print('GET PROFILE ERROR = $e');
        print('STACKTRACE = $s');
        profile = null;
      }

      if (!mounted) return;

      final hasValidProfile = _isProfileCompleted(profile);

      if (!hasValidProfile) {
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
        MaterialPageRoute(builder: (_) => HomeScreen(userId: user.nguoiDungId)),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  void _sendFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final jwt = await AuthStorage.getToken();

      if (fcmToken != null && jwt != null) {
        http
            .post(
          Uri.parse("${ApiConfig.baseUrl}/auth/save-fcm-token"),
          headers: {
            "Authorization": "Bearer $jwt",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"fcmToken": fcmToken}),
        )
            .catchError((e) {
          print(" Lỗi gửi FCM token: $e");
          return http.Response("", 500);
        });

        print(" FCM token gửi ngầm");
      }
    } catch (e) {
      print(" FCM error: $e");
    }
  }

  bool _isProfileCompleted(Map<String, dynamic>? profile) {
    if (profile == null) return false;

    final fullName = (profile['tenND'] ?? '').toString().trim();
    final birthDate = (profile['ngaySinh'] ?? '').toString().trim();
    final gender = profile['gioiTinh'];
    final height = (profile['chieuCao'] as num?)?.toDouble();
    final weight = (profile['canNang'] as num?)?.toDouble();

    final normalizedName = fullName.toLowerCase();
    final hasName = fullName.isNotEmpty &&
        normalizedName != 'người dùng mới' &&
        normalizedName != 'nguoi dung moi';
    final hasBirthDate = birthDate.isNotEmpty;
    final hasGender = gender == 0 || gender == 1;
    final hasHeight = height != null && height > 0;
    final hasWeight = weight != null && weight > 0;

    return hasName && hasBirthDate && hasGender && hasHeight && hasWeight;
  }

  Future<void> _syncUserData(String userId) async {
    try {
      await SettingsApi.getSettings();
      print("🔥 Sync dữ liệu xong");
    } catch (e) {
      print("❌ Sync lỗi: $e");
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
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.tr.login,
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
