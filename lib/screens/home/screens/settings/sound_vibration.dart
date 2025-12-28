import 'package:flutter/material.dart';

class SoundVibrationScreen extends StatefulWidget {
  const SoundVibrationScreen({super.key});

  @override
  State<SoundVibrationScreen> createState() => _SoundVibrationScreenState();
}

class _SoundVibrationScreenState extends State<SoundVibrationScreen> {
  // ===== CONSTANTS =====
  static const _bg = Color(0xFFF3F5F9);

  // ===== STATE =====
  bool _soundOn = true;
  bool _vibrationOn = true;

  double _volume = 0.6;
  String _soundStyle = 'Sound 2';
  String _vibrationLevel = 'Medium';

  static const _sounds = ['Sound 1', 'Sound 2', 'Sound 3', 'Sound 4'];
  static const _vibrations = ['Low', 'Medium', 'High'];

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _soundSection(),
            const SizedBox(height: 16),
            _vibrationSection(),
          ],
        ),
      ),
    );
  }

  // ===== APP BAR =====
  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Sound & Vibration',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  // ===== SOUND =====
  Widget _soundSection() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Sound'),
            value: _soundOn,
            onChanged: (v) => setState(() => _soundOn = v),
          ),
          if (_soundOn) ...[
            const Divider(),
            ..._sounds.map(
              (s) => RadioListTile<String>(
                value: s,
                groupValue: _soundStyle,
                onChanged: (v) => setState(() => _soundStyle = v!),
                title: Text(s),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Volume'),
              subtitle: Slider(
                value: _volume,
                onChanged: (v) => setState(() => _volume = v),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===== VIBRATION =====
  Widget _vibrationSection() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Vibration'),
            value: _vibrationOn,
            onChanged: (v) => setState(() => _vibrationOn = v),
          ),
          if (_vibrationOn) ...[
            const Divider(),
            ..._vibrations.map(
              (v) => RadioListTile<String>(
                value: v,
                groupValue: _vibrationLevel,
                onChanged: (x) => setState(() => _vibrationLevel = x!),
                title: Text(v),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
