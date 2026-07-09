import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../provider/user_provider.dart';
import '../../services/firestore_service.dart';
import '../chat/chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;
  final bool isSeller; // true = shown in seller workspace

  const TaskDetailScreen({
    super.key,
    required this.task,
    this.isSeller = false,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final currentUid = userProvider.uid;
    final isOwnTask = task.buyerId == currentUid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navyBlue,
        elevation: 0,
        title: const Text(
          'Task Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
            // Category & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.category,
                    style: TextStyle(
                      color: Colors.blueGrey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  task.price,
                  style: const TextStyle(
                    color: AppTheme.arahPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              task.title,
              style: const TextStyle(
                color: AppTheme.navyBlue,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Beginner badge
            if (task.isBeginnerFriendly)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),

            // Description
            _sectionTitle('Description'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                task.description.isNotEmpty
                    ? task.description
                    : 'No description provided. Please contact the poster for more details.',
                style: TextStyle(
                  color: Colors.blueGrey.shade700,
                  fontSize: 14.5,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tags
            if (task.tags.isNotEmpty) ...[
              _sectionTitle('Required Skills'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: task.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Attachments
            if (task.attachments.isNotEmpty) ...[
              _sectionTitle('Attachments'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: task.attachments
                    .map(
                      (urlOrPath) {
                        String fileName = urlOrPath.split(RegExp(r'[/\\]')).last;
                        if (fileName.contains('?')) {
                          fileName = fileName.split('?').first;
                        }
                        try {
                          fileName = Uri.decodeFull(fileName);
                        } catch (_) {}
                        
                        return GestureDetector(
                          onTap: () {
                            _showAttachmentOptions(context, fileName, urlOrPath);
                          },
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.attach_file, size: 16, color: Colors.blueAccent),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Info section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _infoRow(
                    icon: Icons.access_time_outlined,
                    label: 'Posted',
                    value: task.postedTime.isNotEmpty ? task.postedTime : 'N/A',
                  ),
                  const Divider(height: 24, color: Color(0xFFE2E8F0)),
                  _infoRow(
                    icon: Icons.flag_outlined,
                    label: 'Status',
                    value: task.status.toUpperCase(),
                    valueColor: task.status == 'open'
                        ? const Color(0xFF10B981)
                        : Colors.blueGrey,
                  ),
                  if (task.buyerName.isNotEmpty) ...[
                    const Divider(height: 24, color: Color(0xFFE2E8F0)),
                    _infoRow(
                      icon: Icons.person_outline,
                      label: 'Posted by',
                      value: task.buyerName,
                    ),
                  ],
                  if (task.budgetType.isNotEmpty) ...[
                    const Divider(height: 24, color: Color(0xFFE2E8F0)),
                    _infoRow(
                      icon: Icons.payments_outlined,
                      label: 'Budget Type',
                      value: task.budgetType,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Button
            if (!isOwnTask) ...[
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _handleAction(context, userProvider),
                  icon: Icon(
                    isSeller
                        ? Icons.chat_bubble_outline
                        : Icons.person_search_outlined,
                    size: 18,
                  ),
                  label: Text(
                    isSeller ? 'Message to Bid' : 'Contact Seller',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.arahPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              if (isSeller) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleTaskOrder(context, userProvider),
                    icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                    label: const Text(
                      'Take Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'This is your task',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(
      BuildContext context, UserProvider userProvider) async {
    final currentUid = userProvider.uid;
    final otherUid = task.buyerId.isNotEmpty ? task.buyerId : 'unknown';

    if (otherUid == currentUid || otherUid == 'unknown') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cannot chat with yourself or unknown user.')),
      );
      return;
    }

    try {
      final firestoreService = FirestoreService();
      // Task-scoped chat room
      final chatId = await firestoreService.createOrGetChatRoom(
        currentUid,
        otherUid,
        taskId: task.id.isNotEmpty ? task.id : null,
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
            isBuyer: !isSeller, // Buyer can assign; Seller cannot
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

  Future<void> _handleTaskOrder(BuildContext context, UserProvider userProvider) async {
    final currentUid = userProvider.uid;
    
    if (task.orderTakers.contains(currentUid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already ordered this task.')),
      );
      return;
    }

    try {
      final firestoreService = FirestoreService();
      await firestoreService.placeTaskOrder(
        task: task,
        sellerId: currentUid,
        sellerName: userProvider.name,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully! 🎉 Check My Orders.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context); // Go back after order
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    }
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppTheme.navyBlue,
        fontSize: 15,
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey.shade400),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.blueGrey.shade500,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.navyBlue,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showAttachmentOptions(BuildContext context, String fileName, String urlOrPath) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navyBlue,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.download, color: AppTheme.arahPurple),
                  title: const Text('Download / Open Attachment', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () async {
                    Navigator.pop(context);
                    
                    final isHttp = urlOrPath.startsWith('http');
                    
                    if (isHttp) {
                      final uri = Uri.tryParse(urlOrPath);
                      if (uri != null) {
                        try {
                          bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                          if (!launched) {
                            launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
                          }
                          if (!launched && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open the web attachment.'),
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open the web attachment.'),
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      }
                    } else {
                      try {
                        final result = await OpenFile.open(urlOrPath);
                        if (result.type != ResultType.done && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not open file: ${result.message}'),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error opening file: $e'),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.blueGrey),
                  title: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
