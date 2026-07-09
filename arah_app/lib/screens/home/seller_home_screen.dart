import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../app/widgets/bottom_nav_bar.dart';
import '../../provider/home_provider.dart';
import '../../provider/user_provider.dart';
import '../../provider/order_provider.dart';
import '../../models/task_model.dart';
import '../../services/firestore_service.dart';
import 'home_screen.dart';
import 'task_detail_screen.dart';
import '../chat/chat_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final homeProvider = context.watch<HomeProvider>();

    final profileImage = userProvider.profileImageFile;
    final role = userProvider.role;
    final canSwitchToBuyer = role == 'Both';

    // Filter from the real Firestore tasks (already excludes own tasks)
    List<TaskModel> tasks = homeProvider.allTasks;
    if (_selectedCategory != 'All') {
      tasks = tasks.where((t) => t.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      tasks = tasks
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.tags.any((tag) =>
                  tag.toLowerCase().contains(_searchQuery.toLowerCase())))
          .toList();
    }

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 0,
        title: Row(
          children: [
            Container(
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
            const SizedBox(width: 12),
            const Text(
              "Find Work",
              style: TextStyle(
                color: AppTheme.navyBlue,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          if (canSwitchToBuyer)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ModeToggle(isBuyerMode: false),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar:
          const ArahBottomNavBar(currentIndex: 0, isSeller: true),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF8FAFC),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: "Search tasks by skill or keyword...",
                    hintStyle: TextStyle(
                        color: Colors.blueGrey.shade300, fontSize: 14),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.blueGrey.shade300),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: Colors.blueGrey.shade300),
                            onPressed: () =>
                                setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // Category filter
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 12),
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    'All', 'Design', 'Development', 'Writing', 'Video',
                    'Marketing'
                  ]
                      .map((cat) => _buildCategoryChip(cat))
                      .toList(),
                ),
              ),
              // Task count info bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      '${tasks.length} task${tasks.length == 1 ? '' : 's'} available',
                      style: TextStyle(
                        color: Colors.blueGrey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (homeProvider.isLoadingTasks)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.arahPurple,
                        ),
                      ),
                  ],
                ),
              ),
              // Task list
              Expanded(
                child: homeProvider.isLoadingTasks && tasks.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.arahPurple))
                    : tasks.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            color: AppTheme.arahPurple,
                            onRefresh: () async {
                              final uid =
                                  context.read<UserProvider>().uid;
                              context
                                  .read<HomeProvider>()
                                  .subscribeToOpenTasks(
                                      excludeUserId: uid);
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                return _buildSellerCard(
                                    context, tasks[index]);
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

  Widget _buildCategoryChip(String cat) {
    final isActive = _selectedCategory == cat;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
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
          cat,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.blueGrey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, TaskModel task) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(task: task, isSeller: true),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.category,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.title,
                        style: const TextStyle(
                          color: AppTheme.navyBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  task.price,
                  style: const TextStyle(
                    color: AppTheme.arahPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
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
            const SizedBox(height: 12),
            if (task.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children:
                    task.tags.map((tag) => _buildTag(tag)).toList(),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 14, color: Colors.blueGrey.shade400),
                const SizedBox(width: 4),
                Text(
                  task.buyerName.isNotEmpty ? task.buyerName : 'Anonymous',
                  style: TextStyle(
                    color: Colors.blueGrey.shade500,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time,
                    size: 14, color: Colors.blueGrey.shade400),
                const SizedBox(width: 4),
                Text(
                  task.postedTime.isNotEmpty ? task.postedTime : 'Open',
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (task.orderTakerNames.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4), // light green bg
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
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _messageToBid(context, task),
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text(
                  "Message to Bid",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.arahPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _messageToBid(BuildContext context, TaskModel task) async {
    final userProvider = context.read<UserProvider>();
    final currentUid = userProvider.uid;
    final otherUid = task.buyerId;

    if (otherUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cannot start a chat: task has no buyer ID.')),
      );
      return;
    }

    if (otherUid == currentUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This is your own task.')),
      );
      return;
    }

    try {
      final firestoreService = FirestoreService();
      final chatId = await firestoreService.createOrGetChatRoom(
        currentUid,
        otherUid,
        taskId: task.id,
      );
      final otherInfo = await firestoreService.getUserBasicInfo(otherUid);

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            otherUserId: otherUid,
            otherUserName: otherInfo['name'] ?? task.buyerName,
            taskId: task.id,
            taskTitle: task.title,
            taskPrice: task.price,
            isBuyer: false, // Seller cannot assign
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open chat: $e')),
        );
      }
    }
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: Colors.blueGrey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.arahPurple.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline,
              size: 36,
              color: AppTheme.arahPurple.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tasks available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.navyBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New tasks will appear here.\nPull down to refresh.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blueGrey.shade400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reuse the _ModeToggle from home_screen.dart
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
