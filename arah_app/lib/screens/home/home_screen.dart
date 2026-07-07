import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../app/widgets/bottom_nav_bar.dart';
import '../request/create_request_screen.dart';
import 'seller_home_screen.dart';
import '../../provider/home_provider.dart';
import '../../provider/user_provider.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final userProvider = context.watch<UserProvider>();
    
    final _profileImage = userProvider.profileImage;
    final _filteredTasks = homeProvider.filteredTasks;

    return Scaffold(
      backgroundColor: AppTheme.pureWhite, // Background matching design
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back arrow
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 0, // Removes the default leading space
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                image: _profileImage != null
                    ? DecorationImage(
                        image: FileImage(_profileImage),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _profileImage == null
                  ? Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(
                        "assets/images/Arah_bg.png",
                        fit: BoxFit.contain,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            const Text(
              "Discover",
              style: TextStyle(
                color: AppTheme.navyBlue,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SellerHomeScreen()),
              );
            },
            child: const Text(
              "Switch to Seller",
              style: TextStyle(
                color: Color(0xFF835CFF), // Soft purple matching design
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: const ArahBottomNavBar(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
        ),
        backgroundColor: const Color(0xFF755BFF), // Purple FAB
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF8FAFC), // subtle background under the list
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                  top: 4.0,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "What do you need help with?",
                    hintStyle: TextStyle(
                      color: Colors.blueGrey.shade300,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.blueGrey.shade300,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9), // Light gray search bar
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 12.0),
                height: 44, // Container for scroll view
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_alt_outlined,
                            size: 16,
                            color: Colors.blueGrey.shade500,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Budget",
                            style: TextStyle(
                              color: Colors.blueGrey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildCategoryChip(context, "All"),
                    _buildCategoryChip(context, "Design"),
                    _buildCategoryChip(context, "Development"),
                    _buildCategoryChip(context, "Writing"),
                    _buildCategoryChip(context, "Video"),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemCount: _filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = _filteredTasks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  task.category,
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                task.price,
                                style: const TextStyle(
                                  color: Color(0xFF6A4BFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            task.title,
                            style: const TextStyle(
                              color: AppTheme.navyBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              height: 1.3,
                            ),
                          ),
                          if (task.isBeginnerFriendly) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EFFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xFFFBC02D),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "Beginner Friendly",
                                    style: TextStyle(
                                      color: Color(0xFF835CFF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.blueGrey.shade300,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                task.postedTime,
                                style: TextStyle(
                                  color: Colors.blueGrey.shade400,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String title) {
    final homeProvider = context.watch<HomeProvider>();
    bool isActive = homeProvider.selectedCategory == title;
    
    return GestureDetector(
      onTap: () {
        context.read<HomeProvider>().selectCategory(title);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.navyBlue : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.blueGrey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
