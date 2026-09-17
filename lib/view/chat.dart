// lib/view/chat.dart
import 'package:domus/controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:domus/view/component/color.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            height: h * 0.20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: h * 0.03),
                const Text(
                  "Chats",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: "Nunito",
                  ),
                ),
                const SizedBox(height: 8),
                GetBuilder<ChatController>(
                  id: 'chat_count', // ⭐ ID للتحديث المستهدف
                  builder: (controller) {
                    return Text(
                      "${controller.chats.length} conversation(s)",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontFamily: "Nunito",
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      onChanged: (value) => controller.searchChats(value),
                      decoration: InputDecoration(
                        hintText: 'Search conversations...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Section
          Expanded(
            child: GetBuilder<ChatController>(
              id: 'chats_list', // ⭐ ID للتحديث المستهدف
              builder: (controller) {
                if (controller.isLoading.value && controller.chats.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.chats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No conversations yet",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontFamily: "Nunito",
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => controller.refreshChats(),
                          child: const Text(
                            "Refresh",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontFamily: "Nunito",
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.refreshChats(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.chats.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final chat = controller.chats[index];
                      return _buildChatItem(chat, controller);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button for new chat
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar(
            'Info',
            'New chat feature coming soon',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat, ChatController controller) {
    return Dismissible(
      key: Key('chat_${chat['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: Get.context!,
          builder:
              (context) => AlertDialog(
                title: const Text("Delete Conversation"),
                content: const Text(
                  "Are you sure you want to delete this conversation?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) => controller.deleteChat(chat['id']),
      child: InkWell(
        onTap: () {
          controller.markAsRead(chat['id']);
          // Get.to(() => SingleChatPage(chatId: chat['id']));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child:
                  chat['other_user_image'] != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          chat['other_user_image'],
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      )
                      : Icon(Icons.person, size: 25, color: AppColors.primary),
            ),
            title: Text(
              chat['other_user_name'] ?? 'User',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Nunito",
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  chat['last_message'] ?? 'No messages yet',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: "Nunito",
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(chat['last_message_time']),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontFamily: "Nunito",
                  ),
                ),
              ],
            ),
            trailing:
                chat['unread_count'] > 0
                    ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        chat['unread_count'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : null,
          ),
        ),
      ),
    );
  }

  String _formatTime(String? timeString) {
    if (timeString == null) return '';

    try {
      final time = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(time);

      if (difference.inDays > 7) {
        return '${time.day}/${time.month}/${time.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timeString;
    }
  }
}
