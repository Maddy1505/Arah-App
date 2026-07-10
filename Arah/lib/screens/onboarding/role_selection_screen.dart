import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../auth/login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  int selectedRole = -1; // 0: Buyer, 1: Seller, 2: Both

  final List<Map<String, String>> roles = [
    {
      "title": "Buyer - Hire talent",
      "desc": "I want to post tasks and find skilled students.",
      "icon": "🛒",
    },
    {
      "title": "Seller - Offer skills",
      "desc": "I want to offer my skills and find freelance tasks.",
      "icon": "💼",
    },
    {"title": "Both", "desc": "I want to both hire and work.", "icon": "⚡"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/Arah.png",
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Choose your workspace",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "How do you plan to use Arah? You can change\nthis later.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey.shade400,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedRole == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedRole = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.arahPurple.withOpacity(0.04)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.arahPurple
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppTheme.arahPurple.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                          
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    roles[index]["title"]!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: isSelected
                                          ? AppTheme.arahPurple
                                          : AppTheme.navyBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    roles[index]["desc"]!,
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade400,
                                      fontSize: 13.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: AppTheme.arahPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 14),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedRole != -1
                      ? () async {
                          final roleTitle = roles[selectedRole]["title"]!
                              .split(" - ")[0]; // "Buyer", "Seller", or "Both"

                          // Persist selected role so LoginScreen/SignupScreen can read it
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('selected_role', roleTitle);

                          if (!context.mounted) return;
                          // Flow: RoleSelection → Login → (Signup) → ProfileSetup → Home
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.arahPurple,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    disabledForegroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
}
