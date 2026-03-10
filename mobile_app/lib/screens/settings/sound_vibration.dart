import 'package:flutter/material.dart';
import '../../models/tr.dart';
import '../../api/settings_api.dart';

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
  double _volume = 0.6;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// LOAD SETTINGS FROM API

  Future<void> _loadSettings() async {
    try {
      final data = await SettingsApi.getSettings();

      setState(() {
        _soundOn = data["soundOn"] ?? true;
        _vibrationOn = data["vibrationOn"] ?? true;
        _volume = data["volume"] ?? 0.6;
        _loading = false;
      });
    } catch (e) {
      _loading = false;
    }
  }

  /// UPDATE SOUND

  void _updateSound(bool value) {
    setState(() => _soundOn = value);
    SettingsApi.updateSetting("SoundOn", value);
  }

  /// UPDATE VIBRATION

  void _updateVibration(bool value) {
    setState(() => _vibrationOn = value);
    SettingsApi.updateSetting("VibrationOn", value);
  }

  /// UPDATE VOLUME

  void _updateVolume(double value) {
    SettingsApi.updateSetting("Volume", value);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _appBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 17),
        children: [
          const SizedBox(height: 12),
          _BigSectionTitle(context.tr.soundNotification),
          const SizedBox(height: 6),
          _notificationCard(),
          const SizedBox(height: 24),
          _BigSectionTitle(context.tr.vibration),
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
      title: Text(
        context.tr.soundVibration,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
    );
  }

  /// SOUND CARD

  Widget _notificationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _switchRow(
            icon: Icons.volume_up_outlined,
            title: context.tr.sound,
            value: _soundOn,
            onChanged: _updateSound,
          ),
          if (_soundOn) ...[
            const SizedBox(height: 6),
            _LabelText(context.tr.volume),
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
                      overlayColor: _primary.withOpacity(.1),
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: _volume,
                      onChanged: (v) => setState(() => _volume = v),
                      onChangeEnd: _updateVolume,
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

  /// VIBRATION CARD

  Widget _vibrationCard() {
    return _card(
      child: _switchRow(
        icon: Icons.vibration,
        title: context.tr.vibration,
        value: _vibrationOn,
        onChanged: _updateVibration,
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
