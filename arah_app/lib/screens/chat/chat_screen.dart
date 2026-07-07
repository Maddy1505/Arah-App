import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_theme.dart';
import '../../models/message_model.dart';
import '../../provider/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    this.chatId = "user123_seller456",
    this.otherUserId = "seller456",
    this.otherUserName = "Alex Johnson",
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _firestoreService.createOrGetChatRoom(userProvider.uid, widget.otherUserId);
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    final message = Message(
      id: '', // Firestore generates ID
      senderId: userProvider.uid,
      content: text,
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _messageController.clear();

    await _firestoreService.sendMessage(widget.chatId, message, widget.otherUserId);
  }

  void _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'doc'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isUploading = true);
      try {
        final filePath = result.files.single.path!;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        
        String fileUrl = await _storageService.uploadChatAttachment(widget.chatId, filePath);

        final message = Message(
          id: '',
          senderId: userProvider.uid,
          content: fileUrl,
          type: MessageType.file,
          timestamp: DateTime.now(),
          isRead: false,
        );

        await _firestoreService.sendMessage(widget.chatId, message, widget.otherUserId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload file: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<UserProvider>(context).uid;

    return Scaffold(
      backgroundColor: AppTheme.offWhite, 
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite, 
        foregroundColor: AppTheme.navyBlue,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.arahPurple.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppTheme.arahPurple),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "online",
                    style: TextStyle(fontSize: 13, color: AppTheme.successGreen),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text("Report User")),
              const PopupMenuItem(child: Text("Block User")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _firestoreService.fetchMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.arahPurple));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                
                final messages = snapshot.data ?? [];

                return ListView.builder(
                  reverse: true, // Show newest at the bottom
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMe = message.senderId == currentUserId;

                    if (message.type == MessageType.file) {
                      return _buildFileBubble(message.content, isMe, message.timestamp);
                    }
                    return _buildTextBubble(message.content, isMe, message.timestamp);
                  },
                );
              },
            ),
          ),
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: LinearProgressIndicator(color: AppTheme.arahPurple),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildTextBubble(String text, bool isMe, DateTime timestamp) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isMe ? AppTheme.arahPurple : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
              )
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 14, right: 36),
                child: Text(
                  text, 
                  style: TextStyle(
                    color: isMe ? Colors.white : AppTheme.navyBlue,
                    fontSize: 15,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(timestamp),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all, size: 14, color: Colors.white),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileBubble(String url, bool isMe, DateTime timestamp) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isMe ? AppTheme.arahPurple : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insert_drive_file, 
                      color: isMe ? Colors.white : AppTheme.navyBlue,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Attachment Document",
                        style: TextStyle(
                          color: isMe ? Colors.white : AppTheme.navyBlue,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4, top: 4, bottom: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(timestamp),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all, size: 14, color: Colors.white),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        maxLines: 6,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: "Message",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(top: 12, bottom: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.grey),
                      onPressed: _pickAndUploadFile,
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              decoration: const BoxDecoration(
                color: AppTheme.arahPurple,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 22),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
