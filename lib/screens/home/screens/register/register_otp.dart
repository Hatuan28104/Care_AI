import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Care_AI/widgets/success_dialog.dart';

class RegisterOtpScreen extends StatefulWidget {
  final String phoneE164;
  final String displayPhone;

  const RegisterOtpScreen({
    super.key,
    required this.phoneE164,
    required this.displayPhone,
  });

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  // ===== CONST =====
  static const _blue = Color(0xFF1F6BFF);
  static const _bg = Color(0xFFF3F5F9);
  static const _fieldBg = Color(0xFFF3F5FF);

  // ===== STATE =====
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();

  Timer? _timer;
  int _secondsLeft = 90;
  bool _submitted = false;
  bool _loading = false;

  // ===== LIFECYCLE =====
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
      if (!mounted) return;
      setState(() => _secondsLeft = _secondsLeft > 0 ? _secondsLeft - 1 : 0);
      if (_secondsLeft == 0) t.cancel();
    });
  }

  String _mmss(int s) => '${(s ~/ 60)}:${(s % 60).toString().padLeft(2, '0')}';

  // ===== ACTION =====
  Future<void> _onContinue() async {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_loading) return;
    setState(() => _loading = true);

    try {
      // TODO: verify OTP
      await SuccessDialog.show(
        context,
        title: 'Successful Registrated',
        onClosed: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onResend() {
    if (_secondsLeft > 0) return;
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
                _headerText(),
                const SizedBox(height: 8),
                _otpField(),
                const Spacer(),
                _continueButton(),
                const SizedBox(height: 14),
                _resendText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== WIDGETS =====
  PreferredSizeWidget _appBar(BuildContext context) => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Register',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D459F),
          ),
        ),
      );

  Widget _headerText() => Text(
        'Enter the OTP sent ${widget.displayPhone}',
        style: const TextStyle(
          fontSize: 20,
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _otpField() => TextFormField(
        controller: _otpCtrl,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: InputDecoration(
          hintText: 'OTP',
          filled: true,
          fillColor: _fieldBg,
          counterText: '',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _otpCtrl.clear,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _blue, width: 1.4),
          ),
        ),
        validator: (v) {
          final s = (v ?? '').trim();
          if (s.isEmpty) return 'Please enter OTP';
          if (!RegExp(r'^\d{6}$').hasMatch(s)) return 'OTP must be 6 digits';
          return null;
        },
      );

  Widget _continueButton() => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _loading ? null : _onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            foregroundColor: Colors.white,
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

  Widget _resendText() {
    final isDisabled = _secondsLeft > 0;

    return Center(
      child: GestureDetector(
        onTap: isDisabled ? null : _onResend,
        child: Text(
          isDisabled ? 'Resend OTP in ${_mmss(_secondsLeft)}' : 'Resend OTP',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDisabled ? Colors.black38 : _blue,
            decoration:
                isDisabled ? TextDecoration.none : TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
