import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../app/widgets/bottom_nav_bar.dart';
import '../../provider/user_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  void _showPickerOptions(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () {
                  userProvider.pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  userProvider.pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final _profileImage = userProvider.profileImage;
    final userName = userProvider.name;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grey background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: AppTheme.navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.gear_alt, color: Colors.blueGrey),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: const ArahBottomNavBar(currentIndex: 3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section with White Background
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showPickerOptions(context),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A4BFF), // Purple
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          image: _profileImage != null
                              ? DecorationImage(
                                  image: FileImage(_profileImage),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: _profileImage == null
                            ? Text(
                                userName.isNotEmpty ? userName[0] : "A",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.navyBlue,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified,
                                color: Colors.blueAccent, // Blue verified icon
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Computer Science Student,\nUI/UX Designer & Python Dev.",
                            style: TextStyle(
                              color: Colors.blueGrey.shade400,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              userProvider.experienceLevel,
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metrics Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            "12",
                            "Tasks Completed",
                            const Color(0xFF10B981),
                          ),
                        ), // Green
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            "98%",
                            "Trust Score",
                            AppTheme.navyBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            "1h",
                            "Response Rate",
                            AppTheme.navyBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            "100%",
                            "Completion Rate",
                            AppTheme.navyBlue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      "My Skills",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navyBlue,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (userProvider.skills.isEmpty 
                          ? ["Python", "Figma", "UI/UX", "Data Analysis", "React"] 
                          : userProvider.skills)
                              .map(
                                (skill) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Text(
                                    skill,
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade600,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      "Portfolio & Links",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navyBlue,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLinkCard(Icons.device_hub_outlined, "GitHub Profile"),
                    const SizedBox(height: 12),
                    _buildLinkCard(
                      Icons.business_center_outlined,
                      "LinkedIn Profile",
                      isLinkedIn: true,
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      "Settings",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navyBlue,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
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
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            Icons.notifications_none_outlined,
                            "Notifications",
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF1F5F9),
                          ),
                          _buildSettingsTile(
                            Icons.lock_outline,
                            "Privacy & Security",
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF1F5F9),
                          ),
                          _buildSettingsTile(
                            Icons.logout,
                            "Log Out",
                            isDestructive: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(
    IconData icon,
    String title, {
    bool isLinkedIn = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      child: Row(
        children: [
          isLinkedIn
              ? Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "in",
                    style: TextStyle(
                      color: Color(0xFF0077B5),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                )
              : Icon(icon, color: AppTheme.navyBlue, size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.navyBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? const Color(0xFFEF4444)
            : AppTheme.navyBlue, // Red for logout
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? const Color(0xFFEF4444) : AppTheme.navyBlue,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: isDestructive
          ? null
          : const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: () {},
    );
  }
}
