import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../provider/user_provider.dart';
import '../home/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  List<String> selectedSkills = [];
  String experienceLevel = "Beginner";
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> allSkills = [
    "Python",
    "Flutter",
    "Canva",
    "Excel",
    "UI/UX",
    "Content Writing",
    "Video Editing",
  ];

  @override
  void initState() {
    super.initState();
  }

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

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Title and Subtitle
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
                      "Let's get to know you better",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey.shade400,
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
                            margin: const EdgeInsets.all(4), // Inner padding
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: _profileImage != null
                                  ? DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _profileImage == null
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
                      "Upload Profile Photo / Logo",
                      style: TextStyle(
                        color: AppTheme.navyBlue,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Select your skills
              const Text(
                "Select your skills",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyBlue,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.arahPurple
                              : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.arahPurple
                              : Colors.blueGrey.shade700,
                          fontWeight: FontWeight.w500,
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
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
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
                            style: const TextStyle(
                              color: AppTheme.navyBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
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
                  onPressed: () {
                    final userProvider = context.read<UserProvider>();
                    userProvider.updateExperience(experienceLevel);
                    for (var skill in selectedSkills) {
                      if (!userProvider.skills.contains(skill)) {
                        userProvider.toggleSkill(skill);
                      }
                    }
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const BuyerHomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.arahPurple, // soft light purple
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Complete Setup",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    const double dashLength = 6.0; // length of each dash
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
