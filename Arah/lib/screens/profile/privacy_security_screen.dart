import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/theme/app_theme.dart';
import '../../provider/user_provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isPublic = userProvider.isProfilePublic;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navyBlue,
        elevation: 0,
        title: const Text(
          'Privacy & Security',
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
            _sectionLabel('Privacy'),
            _buildCard([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.arahPurple.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.visibility_outlined,
                          size: 20, color: AppTheme.arahPurple),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profile Visibility',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          Text(
                            isPublic ? 'Public — Anyone can view' : 'Private — Only you',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isPublic,
                      onChanged: (val) {
                        context.read<UserProvider>().updateProfileVisibility(val);
                      },
                      activeColor: AppTheme.arahPurple,
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 20),
            _sectionLabel('Security'),
            _buildCard([
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.arahPurple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_outline,
                      size: 20, color: AppTheme.arahPurple),
                ),
                title: const Text(
                  'Change Password',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    color: AppTheme.navyBlue,
                  ),
                ),
                subtitle: Text(
                  'Update your account password',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade400),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                onTap: () => _showChangePasswordDialog(context),
              ),
            ]),
            const SizedBox(height: 20),
            _sectionLabel('Danger Zone'),
            _buildCard([
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_forever_outlined,
                      size: 20, color: Color(0xFFEF4444)),
                ),
                title: const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    color: Color(0xFFEF4444),
                  ),
                ),
                subtitle: Text(
                  'Permanently remove your account and data',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade400),
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: Color(0xFFEF4444), size: 20),
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscure1 = true, obscure2 = true, obscure3 = true;
    bool isLoading = false;
    String? errorMsg;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _passField('Current Password', currentPassCtrl, obscure1,
                    () => setDialogState(() => obscure1 = !obscure1)),
                const SizedBox(height: 12),
                _passField('New Password', newPassCtrl, obscure2,
                    () => setDialogState(() => obscure2 = !obscure2)),
                const SizedBox(height: 12),
                _passField('Confirm New Password', confirmPassCtrl, obscure3,
                    () => setDialogState(() => obscure3 = !obscure3)),
                if (errorMsg != null) ...[
                  const SizedBox(height: 10),
                  Text(errorMsg!,
                      style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel',
                    style: TextStyle(color: Colors.blueGrey.shade500)),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (newPassCtrl.text != confirmPassCtrl.text) {
                          setDialogState(() => errorMsg = 'Passwords do not match');
                          return;
                        }
                        if (newPassCtrl.text.length < 6) {
                          setDialogState(
                              () => errorMsg = 'Password must be at least 6 characters');
                          return;
                        }
                        setDialogState(() {
                          isLoading = true;
                          errorMsg = null;
                        });
                        try {
                          final email = FirebaseAuth.instance.currentUser?.email ?? '';
                          await _authService.reauthenticate(
                              email, currentPassCtrl.text);
                          await _authService.updatePassword(newPassCtrl.text);
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password changed successfully!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        } catch (e) {
                          setDialogState(() {
                            isLoading = false;
                            errorMsg = 'Incorrect current password.';
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.arahPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Update'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _passField(
      String hint, TextEditingController ctrl, bool obscure, VoidCallback toggle) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14, color: AppTheme.navyBlue),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.blueGrey.shade300, fontSize: 13),
        suffixIcon: IconButton(
          icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 18, color: Colors.blueGrey.shade400),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueGrey.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueGrey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.arahPurple),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
        ),
        content: const Text(
          'This action is permanent and cannot be undone. All your data, tasks, and messages will be deleted.',
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
              try {
                await _authService.deleteAccount();
                context.read<UserProvider>().clearUser();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Could not delete account. Please re-login and try again. Error: $e'),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete Forever'),
          ),
        ],
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
      ),
      child: Column(children: children),
    );
  }
}
