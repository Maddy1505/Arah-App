import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../app/widgets/bottom_nav_bar.dart';
import '../request/create_request_screen.dart';
import 'seller_home_screen.dart';
import 'task_detail_screen.dart';
import '../../provider/home_provider.dart';
import '../../provider/user_provider.dart';
import '../../provider/order_provider.dart';
import '../../models/task_model.dart';

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

    final profileImage = userProvider.profileImageFile;
    final filteredTasks = homeProvider.filteredTasks;
    final role = userProvider.role;
    final canSwitchToSeller = role == 'Both';

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  image: profileImage != null
                      ? DecorationImage(
                          image: FileImage(profileImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profileImage == null
                    ? Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset(
                          "assets/images/Arah_bg.png",
                          fit: BoxFit.contain,
                        ),
                      )
                    : null,
              ),
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
          if (canSwitchToSeller)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ModeToggle(isBuyerMode: true),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar:
          const ArahBottomNavBar(currentIndex: 0, isSeller: false),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
          );
        },
        backgroundColor: AppTheme.arahPurple,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF8FAFC),
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
                  onChanged: (value) {
                    context.read<HomeProvider>().updateSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: "Search tasks...",
                    hintStyle: TextStyle(
                      color: Colors.blueGrey.shade300,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.blueGrey.shade300,
                    ),
                    suffixIcon: homeProvider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon:
                                Icon(Icons.clear, color: Colors.blueGrey.shade300),
                            onPressed: () =>
                                context.read<HomeProvider>().updateSearchQuery(''),
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
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
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    GestureDetector(
                      onTap: () => _showBudgetModal(context),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: homeProvider.maxBudget != null
                              ? AppTheme.navyBlue
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_alt_outlined,
                              size: 16,
                              color: homeProvider.maxBudget != null
                                  ? Colors.white
                                  : Colors.blueGrey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              homeProvider.maxBudget != null
                                  ? "Up to ₹${homeProvider.maxBudget!.toInt()}"
                                  : "Budget",
                              style: TextStyle(
                                color: homeProvider.maxBudget != null
                                    ? Colors.white
                                    : Colors.blueGrey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (homeProvider.maxBudget != null) ...[
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => context
                                    .read<HomeProvider>()
                                    .updateMaxBudget(null),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              )
                            ]
                          ],
                        ),
                      ),
                    ),
                    _buildCategoryChip(context, "All"),
                    _buildCategoryChip(context, "Design"),
                    _buildCategoryChip(context, "Development"),
                    _buildCategoryChip(context, "Writing"),
                    _buildCategoryChip(context, "Video"),
                    _buildCategoryChip(context, "Marketing"),
                  ],
                ),
              ),
              Expanded(
                child: homeProvider.isLoadingTasks && filteredTasks.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.arahPurple))
                    : filteredTasks.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            color: AppTheme.arahPurple,
                            onRefresh: () async {
                              final uid = context.read<UserProvider>().uid;
                              context
                                  .read<HomeProvider>()
                                  .subscribeToOpenTasks(excludeUserId: uid);
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) {
                                return _buildTaskCard(
                                    context, filteredTasks[index]);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    final currentUid = context.read<UserProvider>().uid;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(task: task, isSeller: false),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                    color: AppTheme.arahPurple,
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
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.blueGrey.shade500,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
            if (task.isBeginnerFriendly) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Color(0xFFFBC02D), size: 14),
                    SizedBox(width: 4),
                    Text(
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
            if (task.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: task.tags
                    .take(3)
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blueGrey.shade600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 14, color: Colors.blueGrey.shade300),
                const SizedBox(width: 6),
                Text(
                  task.postedTime.isNotEmpty ? task.postedTime : 'Just now',
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 12.5,
                  ),
                ),
                const Spacer(),
                if (task.buyerName.isNotEmpty)
                  Text(
                    'by ${task.buyerName}',
                    style: TextStyle(
                      color: Colors.blueGrey.shade400,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            if (task.buyerId == currentUid && task.orderTakerNames.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.people_alt_outlined, size: 16, color: Color(0xFF16A34A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Takers',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            task.orderTakerNames.join(', '),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.blueGrey.shade200),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or post a task',
            style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade300),
          ),
        ],
      ),
    );
  }

  void _showBudgetModal(BuildContext context) {
    double currentBudget =
        context.read<HomeProvider>().maxBudget ?? 5000.0;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Set Maximum Budget",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Max Price:",
                          style: TextStyle(color: Colors.grey)),
                      Text(
                        "₹${currentBudget.toInt()}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.arahPurple,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: currentBudget,
                    min: 500,
                    max: 50000,
                    divisions: 99,
                    activeColor: AppTheme.arahPurple,
                    onChanged: (val) {
                      setState(() {
                        currentBudget = val;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<HomeProvider>()
                            .updateMaxBudget(currentBudget);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.arahPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Apply Filter"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryChip(BuildContext context, String title) {
    final homeProvider = context.watch<HomeProvider>();
    bool isActive = homeProvider.selectedCategory == title;

    return GestureDetector(
      onTap: () {
        context.read<HomeProvider>().selectCategory(title);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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

/// Shared mode toggle for "Both" role users
class _ModeToggle extends StatelessWidget {
  final bool isBuyerMode;
  const _ModeToggle({required this.isBuyerMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleChip(context, 'Buyer', isBuyerMode, () async {
            if (!isBuyerMode) {
              await context.read<UserProvider>().switchMode('Buyer');
              final uid = context.read<UserProvider>().uid;
              context
                  .read<HomeProvider>()
                  .subscribeToOpenTasks(excludeUserId: uid);
              context
                  .read<OrderProvider>()
                  .subscribeToOrders(uid, isSeller: false);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BuyerHomeScreen()),
                  (route) => false,
                );
              }
            }
          }),
          _toggleChip(context, 'Seller', !isBuyerMode, () async {
            if (isBuyerMode) {
              await context.read<UserProvider>().switchMode('Seller');
              final uid = context.read<UserProvider>().uid;
              context
                  .read<HomeProvider>()
                  .subscribeToOpenTasks(excludeUserId: uid);
              context
                  .read<OrderProvider>()
                  .subscribeToOrders(uid, isSeller: true);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SellerHomeScreen()),
                  (route) => false,
                );
              }
            }
          }),
        ],
      ),
    );
  }

  Widget _toggleChip(
      BuildContext context, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.arahPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.blueGrey.shade500,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
