import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../provider/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _githubCtrl;
  late TextEditingController _linkedinCtrl;
  late String _experienceLevel;
  late List<String> _skills;
  bool _isSaving = false;

  final List<String> allSkills = [
    "Python", "Flutter", "Canva", "Excel", "UI/UX",
    "Content Writing", "Video Editing", "Figma", "React",
    "Data Analysis", "Digital Marketing", "JavaScript",
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _nameCtrl = TextEditingController(text: user.name);
    _bioCtrl = TextEditingController(text: user.bio);
    _githubCtrl = TextEditingController(text: user.githubUrl);
    _linkedinCtrl = TextEditingController(text: user.linkedinUrl);
    _experienceLevel = user.experienceLevel;
    _skills = List<String>.from(user.skills);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _githubCtrl.dispose();
    _linkedinCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await context.read<UserProvider>().updateProfile(
        name: _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        experienceLevel: _experienceLevel,
        skills: _skills,
        githubUrl: _githubCtrl.text.trim(),
        linkedinUrl: _linkedinCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navyBlue,
        elevation: 0,
        title: const Text(
          'Edit Profile',
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
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isSaving ? Colors.grey : AppTheme.arahPurple,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info
            _sectionLabel('Basic Information'),
            _buildCard([
              _buildField('Full Name', _nameCtrl, hint: 'Enter your full name'),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildField('Bio / Tagline', _bioCtrl,
                  hint: 'e.g. UI/UX Designer & Flutter Dev',
                  maxLines: 3),
            ]),
            const SizedBox(height: 20),

            // Experience Level
            _sectionLabel('Experience Level'),
            _buildCard([
              ...["Beginner", "Intermediate", "Advanced"].map((level) {
                final isSelected = _experienceLevel == level;
                return Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _experienceLevel = level),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
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
                                      : Colors.blueGrey.shade200,
                                  width: isSelected ? 5.5 : 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              level,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: AppTheme.navyBlue,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (level != "Advanced")
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ],
                );
              }),
            ]),
            const SizedBox(height: 20),

            // Skills
            _sectionLabel('Skills'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: allSkills.map((skill) {
                final isSelected = _skills.contains(skill);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _skills.remove(skill);
                      } else {
                        _skills.add(skill);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.arahPurple.withOpacity(0.08)
                          : Colors.white,
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
            const SizedBox(height: 20),

            // Links
            _sectionLabel('Portfolio Links'),
            _buildCard([
              _buildField('GitHub URL', _githubCtrl,
                  hint: 'https://github.com/yourusername',
                  icon: Icons.link),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildField('LinkedIn URL', _linkedinCtrl,
                  hint: 'https://linkedin.com/in/yourusername',
                  icon: Icons.link),
            ]),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.arahPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Save Profile',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
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
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    String hint = '',
    int maxLines = 1,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: const TextStyle(
                fontSize: 14.5, color: AppTheme.navyBlue),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(color: Colors.blueGrey.shade300, fontSize: 14),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              prefixIcon: icon != null
                  ? Icon(icon, size: 18, color: Colors.blueGrey.shade400)
                  : null,
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 28, minHeight: 0),
            ),
          ),
        ],
      ),
    );
  }
}
