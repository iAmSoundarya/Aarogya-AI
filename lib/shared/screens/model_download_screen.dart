import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../services/model_service.dart';


class ModelDownloadScreen extends StatefulWidget {
  const ModelDownloadScreen({super.key});

  @override
  State<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends State<ModelDownloadScreen> {
  double _progress = 0;
  String _status = 'Ready to download';
  bool _downloading = false;
  bool _error = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkExistingModel());
  }

  Future<void> _checkExistingModel() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyDone = prefs.getBool(AppConstants.keyModelDownloaded) ?? false;
    if (alreadyDone) {
      if (mounted) context.go(AppRoutes.home);
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${AppConstants.modelFileName}');
    if (file.existsSync()) {
      await prefs.setBool(AppConstants.keyModelDownloaded, true);
      if (mounted) context.go(AppRoutes.home);
    }
  }

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
      _error = false;
    });

    try {
      await sl<ModelService>().downloadModel(
        onProgress: (progress, status) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _status = status;
            });
          }
        },
      );
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _error = true;
          _errorMessage = 'Download failed. Check your connection and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Icon(Icons.health_and_safety_rounded,
                  size: 56, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Download AI Model',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'AarogyaAI needs to download its AI model once (~1.5 GB). '
                    'After this, everything works offline — no internet needed.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(icon: Icons.wifi_off, label: 'Works offline after'),
                  _InfoChip(icon: Icons.lock_outline, label: 'Private on-device'),
                  _InfoChip(icon: Icons.storage_outlined, label: '~1.5 GB storage'),
                ],
              ),
              const Spacer(),

              if (_downloading) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_status,
                        style: const TextStyle(color: Colors.white, fontSize: 14)),
                    Text('${(_progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (_error)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13)),
                      ),
                    ],
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _downloading ? null : _startDownload,
                  child: _downloading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black54),
                  )
                      : Text(
                    _error ? 'Retry Download' : 'Download & Get Started',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Requires Wi-Fi or mobile data once only',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}