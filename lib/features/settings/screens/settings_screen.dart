import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'hi';
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = sl<SharedPreferences>();
    setState(() {
      _language = prefs.getString(AppConstants.keySelectedLanguage) ?? 'hi';
    });
    // Get version
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _appVersion = info.version);
    } catch (_) {
      setState(() => _appVersion = AppConstants.appVersion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Language'),
          RadioListTile<String>(
            title: const Text('हिन्दी (Hindi)'),
            value: 'hi',
            groupValue: _language,
            onChanged: _setLanguage,
          ),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: _language,
            onChanged: _setLanguage,
          ),
          RadioListTile<String>(
            title: const Text('বাংলা (Bengali)'),
            value: 'bn',
            groupValue: _language,
            onChanged: _setLanguage,
          ),
          const Divider(),
          const _SectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App version'),
            trailing: Text(_appVersion,
                style: TextStyle(color: Colors.grey.shade500)),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy policy'),
            subtitle: const Text('Patient data stays on your device'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Future<void> _setLanguage(String? value) async {
    if (value == null) return;
    final prefs = sl<SharedPreferences>();
    await prefs.setString(AppConstants.keySelectedLanguage, value);
    setState(() => _language = value);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 0.5)),
      );
}

// ignore: depend_on_referenced_packages
class PackageInfo {
  static Future<PackageInfo> fromPlatform() async => PackageInfo();
  String get version => AppConstants.appVersion;
}
