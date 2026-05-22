import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/biometric_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BiometricService _bioService = BiometricService();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: AppTheme.warmText, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.warmText),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface1,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.gold.withOpacity(0.15),
                        child: Text(
                          '${user.firstName?.characters.first ?? "U"}',
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user.firstName ?? ""} ${user.lastName ?? ""}',
                              style: const TextStyle(
                                color: AppTheme.warmText,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email ?? '',
                              style: const TextStyle(
                                color: AppTheme.dimText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.dimText,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              _buildGrid([
                _GridItem(
                  icon: Icons.lock_outline_rounded,
                  label: 'Password',
                  sub: 'Change your password',
                  color: AppTheme.gold,
                  onTap: () => _showChangePasswordDialog(context),
                ),
                _GridItem(
                  icon: Icons.fingerprint_rounded,
                  label: 'Biometric',
                  sub: 'Setup fingerprint',
                  color: const Color(0xFFCE93D8),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.biometricSetup),
                ),
              ]),
              const SizedBox(height: 24),
              const Text(
                'PREFERENCES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.dimText,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              _buildGrid([
                _GridItem(
                  icon: Icons.flag_rounded,
                  label: 'Monthly Goal',
                  sub: 'Set listening target',
                  color: AppTheme.gold,
                  onTap: () => _editGoal(context),
                ),
                _GridItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  sub: 'Manage alerts',
                  color: const Color(0xFFBA68C8),
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 24),
              const Text(
                'SUPPORT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.dimText,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              _buildGrid([
                _GridItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help',
                  sub: 'FAQs & support',
                  color: AppTheme.gold,
                  onTap: () {},
                ),
                _GridItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About',
                  sub: 'Version 1.0.0',
                  color: const Color(0xFF7E57C2),
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _handleSignOut(context),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E57C2).withOpacity(0.15),
                    foregroundColor: const Color(0xFFCE93D8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: const Color(0xFFCE93D8).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<_GridItem> items) {
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: items.indexOf(item) > 0 ? 6 : 0,
              right: items.indexOf(item) < items.length - 1 ? 6 : 0,
            ),
            child: _GridTile(item: item),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _editGoal(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getDouble(AppConstants.monthlyGoalKey) ??
        AppConstants.defaultMonthlyGoalHours;
    final controller = TextEditingController(text: current.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.cardBorder),
        ),
        title: const Text('Monthly Goal',
            style: TextStyle(color: AppTheme.warmText, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppTheme.warmText),
          decoration: const InputDecoration(labelText: 'Hours per month'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(controller.text);
              if (v != null && v > 0) Navigator.of(ctx).pop(v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      final p = await SharedPreferences.getInstance();
      await p.setDouble(AppConstants.monthlyGoalKey, result);
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPwCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();
    final confirmPwCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.cardBorder),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(color: AppTheme.warmText, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPwCtrl,
                  obscureText: true,
                  style: const TextStyle(color: AppTheme.warmText),
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPwCtrl,
                  obscureText: true,
                  style: const TextStyle(color: AppTheme.warmText),
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPwCtrl,
                  obscureText: true,
                  style: const TextStyle(color: AppTheme.warmText),
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPwCtrl.text != confirmPwCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              if (newPwCtrl.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters')),
                );
                return;
              }
              final auth = context.read<AuthProvider>();
              await auth.updatePassword(newPwCtrl.text);
              final success = true;
              if (ctx.mounted) Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Password changed successfully'
                      : 'Failed to change password. Check your current password.'),
                  backgroundColor: success ? const Color(0xFF00BFA6) : const Color(0xFFFF5370),
                ),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.cardBorder),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: AppTheme.warmText, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppTheme.dimText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E57C2).withOpacity(0.15),
              foregroundColor: const Color(0xFFCE93D8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: const Color(0xFFCE93D8).withOpacity(0.3),
                ),
              ),
              elevation: 0,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.authWrapper,
          (route) => false,
        );
      }
    }
  }
}

class _GridItem {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  const _GridItem({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });
}

class _GridTile extends StatelessWidget {
  final _GridItem item;
  const _GridTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              item.label,
              style: const TextStyle(
                color: AppTheme.warmText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.sub,
              style: const TextStyle(color: AppTheme.dimText, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
