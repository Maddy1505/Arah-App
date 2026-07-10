import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../provider/user_provider.dart';
import '../../provider/home_provider.dart';
import '../../provider/order_provider.dart';
import '../home/home_screen.dart';
import '../home/seller_home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String role;
  final String name;
  const ProfileSetupScreen({super.key, this.role = 'Buyer', this.name = ''});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  List<String> selectedSkills = [];
  String experienceLevel = "Beginner";
  bool _isSaving = false;

  final List<String> allSkills = [
    "Python",
    "Flutter",
    "Canva",
    "Excel",
    "UI/UX",
    "Content Writing",
    "Video Editing",
    "Figma",
    "React",
    "Data Analysis",
    "Digital Marketing",
    "Node.js",
    "Java",
    "Kotlin",
    "Swift",
  ];

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

  Future<void> _completeSetup() async {
    setState(() => _isSaving = true);
    try {
      final userProvider = context.read<UserProvider>();
      final uid = userProvider.uid;

      if (uid.isEmpty) {
        throw Exception('Not authenticated. Please sign in again.');
      }

      // Update the existing profile with skills and experience
      await userProvider.updateProfile(
        experienceLevel: experienceLevel,
        skills: selectedSkills,
        name: widget.name.isNotEmpty ? widget.name : null,
      );

      // Upload profile photo if selected during setup
      final profileImage = userProvider.profileImageFile;
      if (profileImage != null) {
        try {
          await userProvider.uploadExistingProfileImage(profileImage.path);
        } catch (_) {
          // Non-critical — profile still saved without photo
        }
      }

      if (!mounted) return;

      // Subscribe providers with the user's UID
      final homeProvider = context.read<HomeProvider>();
      homeProvider.subscribeToOpenTasks(excludeUserId: uid);

      final orderProvider = context.read<OrderProvider>();
      final mode = userProvider.currentMode;
      orderProvider.subscribeToOrders(uid, isSeller: mode == 'Seller');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => mode == 'Seller'
              ? const SellerHomeScreen()
              : const BuyerHomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profileImage = userProvider.profileImageFile;

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Set up your profile",
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: AppTheme.navyBlue,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You're all set as a ${widget.role}!\nCustomize your profile to stand out.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey.shade400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Profile Photo Upload
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showPickerOptions(context),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: CustomPaint(
                          painter: DashedCirclePainter(
                            color: Colors.blueGrey.shade300,
                            strokeWidth: 1.2,
                            gap: 4.0,
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: profileImage != null
                                  ? DecorationImage(
                                      image: FileImage(profileImage),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: profileImage == null
                                ? Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.blueGrey.shade300,
                                    size: 32,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Upload Profile Photo",
                      style: TextStyle(
                        color: AppTheme.navyBlue,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Optional — tap to add",
                      style: TextStyle(
                        color: Colors.blueGrey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Skills
              const Text(
                "Select your skills",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyBlue,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Choose all that apply",
                style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade400),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: allSkills.map((skill) {
                  bool isSelected = selectedSkills.contains(skill);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedSkills.remove(skill);
                        } else {
                          selectedSkills.add(skill);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.arahPurple.withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.arahPurple
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.arahPurple
                              : Colors.blueGrey.shade700,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),

              // Experience Level
              const Text(
                "Experience Level",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyBlue,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: ["Beginner", "Intermediate", "Advanced"].map((level) {
                  bool isSelected = experienceLevel == level;
                  return GestureDetector(
                    onTap: () => setState(() => experienceLevel = level),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.arahPurple.withOpacity(0.04)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.arahPurple
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.arahPurple
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 5.5 : 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            level,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.arahPurple
                                  : AppTheme.navyBlue,
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Complete Setup button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _completeSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.arahPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Complete Setup",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final double circumference = 2 * math.pi * radius;
    const double dashLength = 6.0;
    final int dashCount = (circumference / (dashLength + gap)).floor();

    for (int i = 0; i < dashCount; ++i) {
      final double startAngle =
          (i * (dashLength + gap) / circumference) * 2 * math.pi;
      final double sweepAngle = (dashLength / circumference) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
