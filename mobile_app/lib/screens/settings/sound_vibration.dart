import 'package:flutter/material.dart';

class SoundVibrationScreen extends StatefulWidget {
  const SoundVibrationScreen({super.key});

  @override
  State<SoundVibrationScreen> createState() => _SoundVibrationScreenState();
}

class _SoundVibrationScreenState extends State<SoundVibrationScreen> {
  static const _cardBg = Color(0xFFF2F2F2);
  static const _primary = Color(0xFF1877F2);

  bool _soundOn = true;
  bool _vibrationOn = true;

  double _volume = 0.60;
  String _soundStyle = 'Âm thanh 2';
  String _vibrationLevel = 'Trung bình';

  static const _sounds = [
    'Âm thanh 1',
    'Âm thanh 2',
    'Âm thanh 3',
    'Âm thanh 4',
    'Âm thanh 5',
  ];

  static const _vibrations = ['Thấp', 'Trung bình', 'Cao'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: _appBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 17),
        children: [
          const SizedBox(height: 12),
          const _BigSectionTitle('Âm thanh thông báo'),
          const SizedBox(height: 6),
          _notificationCard(),
          const SizedBox(height: 24),
          const _BigSectionTitle('Rung'),
          const SizedBox(height: 6),
          _vibrationCard(),
        ],
      ),
    );
  }

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
        'Âm thanh & Rung',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _notificationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _switchRow(
            icon: Icons.volume_up_outlined,
            title: 'Âm thanh',
            value: _soundOn,
            onChanged: (v) => setState(() => _soundOn = v),
          ),
          if (_soundOn) ...[
            const SizedBox(height: 4),
            const _LabelText('Kiểu âm thanh'),
            const SizedBox(height: 4),
            ..._sounds.map((s) => _checkRow(
                  icon: Icons.music_note_outlined,
                  title: s,
                  selected: _soundStyle == s,
                  onTap: () => setState(() => _soundStyle = s),
                )),
            const SizedBox(height: 6),
            const _LabelText('Âm lượng'),
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
            title: 'Rung',
            value: _vibrationOn,
            onChanged: (v) => setState(() => _vibrationOn = v),
          ),
          if (_vibrationOn) ...[
            const SizedBox(height: 4),
            const _LabelText('Mức độ rung'),
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

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
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
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
        Transform.scale(
          scale: 0.8,
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
                  fontSize: 17,
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

class _BigSectionTitle extends StatelessWidget {
  final String text;
  const _BigSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
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
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    );
  }
}
