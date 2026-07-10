import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../provider/user_provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'notifications_settings_screen.dart';
import 'privacy_security_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navyBlue,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppTheme.navyBlue,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Account'),
            _buildCard([
              _buildTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your name, bio, skills & links',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            _sectionLabel('Preferences'),
            _buildCard([
              _buildTile(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Manage alerts and push notifications',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsSettingsScreen()),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildTile(
                icon: Icons.lock_outline,
                title: 'Privacy & Security',
                subtitle: 'Password, account visibility',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PrivacySecurityScreen()),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            _sectionLabel('Danger Zone'),
            _buildCard([
              _buildTile(
                icon: Icons.logout,
                title: 'Log Out',
                isDestructive: true,
                onTap: () => _confirmLogout(context),
              ),
            ]),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Arah v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey.shade300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: Colors.blueGrey.shade400,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final color = isDestructive ? const Color(0xFFEF4444) : AppTheme.navyBlue;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey.shade400,
              ),
            )
          : null,
      trailing: isDestructive
          ? null
          : const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: Colors.blueGrey.shade500)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authService = FirebaseAuthService();
              await authService.signOut();
              context.read<UserProvider>().clearUser();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
