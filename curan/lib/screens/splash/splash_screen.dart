import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/biometric_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _disposed = false;
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_disposed) {
        _runStartupSequence();
      }
    });
  }

  Future<void> _runStartupSequence() async {
    try {
      // Force logout on startup so the user always has to log in manually
      // after the fingerprint authentication (project requirement).
      if (mounted) {
        await context.read<AuthProvider>().signOut();
      }
      
      await _biometricService
          .authenticate(reason: 'Authenticate to access Curan')
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
    if (_disposed) return;
    _navigateToAuthWrapper();
  }

  void _navigateToAuthWrapper() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/authWrapper');
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0F16),
              AppTheme.darkBg,
              const Color(0xFF0F1923),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.gold.withOpacity(0.1),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.gold.withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 100,
                          color: AppTheme.gold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'CURAN',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your spiritual journey',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.dimText.withOpacity(0.7),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
