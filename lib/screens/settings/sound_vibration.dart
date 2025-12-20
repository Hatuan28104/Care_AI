import 'package:flutter/material.dart';

class SoundVibrationScreen extends StatefulWidget {
  const SoundVibrationScreen({super.key});

  @override
  State<SoundVibrationScreen> createState() => _SoundVibrationScreenState();
}

class _SoundVibrationScreenState extends State<SoundVibrationScreen> {
  // ===== COLORS =====
  static const _pageBg = Color(0xFFFFFFFF);
  static const _cardBg = Color(0xFFF2F2F2);
  static const _primary = Color(0xFF1F6BFF);
  static const _muted = Color.fromARGB(255, 189, 189, 189);

  // ===== STATE =====
  bool _soundOn = true;
  bool _vibrationOn = true;

  double _volume = 0.60;
  String _soundStyle = 'Sound 2';
  String _vibrationLevel = 'Medium';

  static const _sounds = [
    'Sound 1',
    'Sound 2',
    'Sound 3',
    'Sound 4',
    'Sound 5'
  ];
  static const _vibrations = ['Low', 'Medium', 'High'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _appBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 17),
        children: [
          const SizedBox(height: 12),
          const _BigSectionTitle('Notification Sound'),
          const SizedBox(height: 6),
          _notificationCard(),
          const SizedBox(height: 24),
          const _BigSectionTitle('Vibration'),
          const SizedBox(height: 6),
          _vibrationCard(),
        ],
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
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Sound & Vibration',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 24, // 👈 to như ảnh
          color: Colors.black,
        ),
      ),
    );
  }

  // ===== CARDS =====
  Widget _notificationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _switchRow(
            icon: Icons.volume_up_outlined,
            title: 'Sound',
            value: _soundOn,
            onChanged: (v) => setState(() => _soundOn = v),
          ),
          if (_soundOn) ...[
            const SizedBox(height: 4),
            const _LabelText('Sound Style'),
            const SizedBox(height: 4),
            ..._sounds.map((s) => _checkRow(
                  icon: Icons.music_note_outlined,
                  title: s,
                  selected: _soundStyle == s,
                  onTap: () => setState(() => _soundStyle = s),
                )),
            const SizedBox(height: 6),
            const _LabelText('Volume'),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.volume_off_outlined,
                    color: _primary, size: 20),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: _primary,
                      inactiveTrackColor: Colors.grey.shade400,
                      thumbColor: Colors.white,
                      overlayColor: _primary.withOpacity(.10),
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: _volume,
                      onChanged: (v) => setState(() => _volume = v),
                    ),
                  ),
                ),
                const Icon(Icons.volume_up_outlined, color: _primary, size: 20),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _vibrationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _switchRow(
            icon: Icons.vibration,
            title: 'Vibration',
            value: _vibrationOn,
            onChanged: (v) => setState(() => _vibrationOn = v),
          ),
          if (_vibrationOn) ...[
            const SizedBox(height: 4),
            const _LabelText('Vibration Level'),
            const SizedBox(height: 4),
            ..._vibrations.map((v) => _checkRow(
                  icon: Icons.vibration,
                  title: v,
                  selected: _vibrationLevel == v,
                  onTap: () => setState(() => _vibrationLevel = v),
                )),
          ],
        ],
      ),
    );
  }

  // ===== PIECES =====
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10), // 👈 bo giống ảnh
      ),
      child: child,
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: _primary, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17, // 👈 to như ảnh
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
        Transform.scale(
          scale: 0.8, // 👈 switch to hơn chút
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color.fromARGB(255, 19, 114, 255),
            inactiveTrackColor: Colors.grey.shade500,
            inactiveThumbColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _checkRow({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: _primary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17, // 👈 to như ảnh
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
            if (selected)
              Container(
                width: 24,
                height: 30,
                decoration: const BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

// ===== SMALL TEXTS =====

class _BigSectionTitle extends StatelessWidget {
  final String text;
  const _BigSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17, // 👈 to như ảnh
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }
}

class _LabelText extends StatelessWidget {
  final String text;
  const _LabelText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16, // 👈 label lớn như ảnh
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    );
  }
}
