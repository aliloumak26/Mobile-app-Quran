import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../services/biometric_service.dart';

class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen>
    with SingleTickerProviderStateMixin {
  final BiometricService _biometricService = BiometricService();
  bool _isLoading = false;
  bool _isAvailable = true;
  bool _isSetupComplete = false;
  String? _errorMessage;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _checkAvailability();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    _isAvailable = await _biometricService.isBiometricAvailable();
    if (mounted) setState(() {});
  }

  Future<void> _setupBiometric() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final success = await _biometricService.authenticate(
      reason: 'Set up biometric for secure access',
    );
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.biometricSetupKey, true);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (success) {
          _isSetupComplete = true;
        } else {
          _errorMessage = 'Authentication failed. Try again.';
        }
      });
      if (success) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pushReplacementNamed('/authWrapper');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D1A), AppTheme.darkBg, Color(0xFF120A28)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                if (_isSetupComplete)
                  _buildSuccessState()
                else
                  _buildSetupState(),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupState() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) => Transform.scale(
            scale: _pulseAnim.value,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.gold.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                size: 80,
                color: AppTheme.gold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Secure Your App',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.warmText,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Set up fingerprint to protect\nyour account',
          style: TextStyle(color: AppTheme.dimText, fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF5370).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFFF5370), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Color(0xFFFF5370), fontSize: 13)),
                ),
              ],
            ),
          ),
        if (!_isAvailable)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.gold, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No biometric setup found on your device.\nEnable fingerprint in your phone settings first.',
                    style: TextStyle(color: AppTheme.dimText, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading || !_isAvailable ? null : _setupBiometric,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: AppTheme.darkBg,
              disabledBackgroundColor: AppTheme.gold.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppTheme.darkBg,
                    ),
                  )
                : const Text(
                    'Enable Fingerprint',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed('/authWrapper'),
          style: TextButton.styleFrom(foregroundColor: AppTheme.gold),
          child: const Text('Skip for now', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00BFA6).withOpacity(0.15),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 64,
            color: Color(0xFF00BFA6),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Fingerprint Enabled!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.warmText,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your app is now secured',
          style: TextStyle(color: AppTheme.dimText, fontSize: 14),
        ),
      ],
    );
  }
}
