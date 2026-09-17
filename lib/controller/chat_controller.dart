import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:domus/services/api_service.dart';

class ChatController extends GetxController {
  final box = GetStorage();
  
  final isLoading = false.obs;
  final chats = <Map<String, dynamic>>[].obs;
  final selectedChat = <String, dynamic>{}.obs;
  
  int get chatCount => chats.length;
  
  @override
  void onInit() {
    super.onInit();
    print('🚀 ChatController initialized');
    loadChats();
  }
  
  @override
  void onClose() {
    print('🔒 ChatController closed');
    super.onClose();
  }
  
  Future<void> loadChats() async {
    try {
      isLoading.value = true;
      
      // تحقق من التخزين المحلي أولاً
      if (box.hasData('cached_chats')) {
        final cachedData = box.read('cached_chats');
        if (cachedData is List) {
          chats.value = List<Map<String, dynamic>>.from(cachedData);
          print('📂 Loaded ${chats.length} chats from cache');
        }
      }
      
      // جلب من API
      final response = await ApiService.getChats();
      
      if (response['success'] == true) {
        final newChats = List<Map<String, dynamic>>.from(response['data'] ?? []);
        chats.value = newChats;
        
        // حفظ في التخزين المحلي
        box.write('cached_chats', newChats);
        print('✅ Loaded ${chats.length} chats from API');
      }
      
    } catch (e) {
      print('❌ Error loading chats: $e');
      Get.snackbar(
        'Error',
        'Failed to load conversations',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> sendMessage(int chatId, String message) async {
    try {
      final response = await ApiService.sendMessage(chatId, message);
      
      if (response['success'] == true) {
        // تحديث الـ chat المحلي
        final index = chats.indexWhere((chat) => chat['id'] == chatId);
        if (index != -1) {
          chats[index]['last_message'] = message;
          chats[index]['last_message_time'] = DateTime.now().toIso8601String();
          chats.refresh();
        }
        
        // تحديث التخزين المحلي
        box.write('cached_chats', chats);
      }
    } catch (e) {
      print('❌ Error sending message: $e');
    }
  }
  
  void markAsRead(int chatId) {
    final index = chats.indexWhere((chat) => chat['id'] == chatId);
    if (index != -1) {
      chats[index]['unread_count'] = 0;
      chats.refresh();
      
      // تحديث التخزين المحلي
      box.write('cached_chats', chats);
    }
  }
  
  Future<void> deleteChat(int chatId) async {
    try {
      final response = await ApiService.deleteChat(chatId);
      
      if (response['success'] == true) {
        chats.removeWhere((chat) => chat['id'] == chatId);
        
        // تحديث التخزين المحلي
        box.write('cached_chats', chats);
        
        Get.snackbar(
          'Success',
          'Conversation deleted',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Error deleting chat: $e');
    }
  }
  
  // البحث في المحادثات
  void searchChats(String query) {
    if (query.isEmpty) {
      loadChats();
      return;
    }
    
    final filtered = chats.where((chat) {
      final name = chat['other_user_name']?.toString().toLowerCase() ?? '';
      final lastMessage = chat['last_message']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) || 
             lastMessage.contains(query.toLowerCase());
    }).toList();
    
    chats.value = filtered;
  }
  
  // إعادة تحميل
  Future<void> refreshChats() async {
    box.remove('cached_chats'); // مسح الكاش
    await loadChats();
  }
}