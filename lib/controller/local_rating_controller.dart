// lib/controllers/local_rating_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocalRatingController extends GetxController {
  // Storage box
  final box = GetStorage();

  // Main storage key
  final String storageKey = 'user_apartment_ratings';

  // ====================== Helper Functions ======================

  // Get current user ID
  int getCurrentUserId() {
    final userData = box.read('userData');
    print('🔍 Reading userData from GetStorage: $userData');
    print('🔍 Data type: ${userData.runtimeType}');

    if (userData is Map) {
      print('🔍 userData contents: $userData');
      final userId = userData['id'];
      print('🔍 userData["id"] value: $userId');
      print('🔍 userData["id"] type: ${userId.runtimeType}');

      if (userId != null) {
        final intUserId = int.tryParse(userId.toString()) ?? 0;
        print('✅ Current user ID: $intUserId');
        return intUserId;
      }
    }

    print('⚠️ User ID not found, using default ID 0');
    return 0; // Default ID for unregistered users
  }

  // Create user-specific storage key
  String getUserStorageKey(int userId) {
    return '${storageKey}_user_$userId';
  }

  // ====================== Core Functions ======================

  // 1. Save apartment rating
  void saveRating(int apartmentId, int rating) {
    final userId = getCurrentUserId();
    final userKey = getUserStorageKey(userId);

    print(
      '💾 Attempting to save rating: Apartment $apartmentId = $rating stars for user $userId',
    );

    // Get all previous ratings
    Map<String, dynamic> allRatings = {};

    if (box.hasData(userKey)) {
      final data = box.read(userKey);
      if (data is Map) {
        allRatings = Map<String, dynamic>.from(data);
      }
    }

    // Update this apartment's rating
    allRatings[apartmentId.toString()] = {
      'rating': rating,
      'date': DateTime.now().toIso8601String(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Save to storage
    box.write(userKey, allRatings);

    print('✅ Successfully saved!');
    print('📊 Current ratings: $allRatings');

    // Update UI
    update();
  }

  // 2. Get rating for a specific apartment
  int getRating(int apartmentId) {
    final userId = getCurrentUserId();
    final userKey = getUserStorageKey(userId);

    if (!box.hasData(userKey)) {
      return 0;
    }

    final data = box.read(userKey);
    if (data is! Map) {
      return 0;
    }

    final ratingData = data[apartmentId.toString()];
    if (ratingData is Map) {
      return ratingData['rating'] ?? 0;
    }

    return 0;
  }

  // 3. Has this apartment been rated?
  bool hasRated(int apartmentId) {
    return getRating(apartmentId) > 0;
  }

  // 4. Get rating date
  DateTime? getRatingDate(int apartmentId) {
    final userId = getCurrentUserId();
    final userKey = getUserStorageKey(userId);

    if (!box.hasData(userKey)) {
      return null;
    }

    final data = box.read(userKey);
    if (data is! Map) {
      return null;
    }

    final ratingData = data[apartmentId.toString()];
    if (ratingData is Map && ratingData['date'] != null) {
      try {
        return DateTime.parse(ratingData['date']);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  // 5. Delete apartment rating
  void deleteRating(int apartmentId) {
    final userId = getCurrentUserId();
    final userKey = getUserStorageKey(userId);

    if (!box.hasData(userKey)) {
      return;
    }

    final data = box.read(userKey);
    if (data is! Map) {
      return;
    }

    Map<String, dynamic> allRatings = Map<String, dynamic>.from(data);
    allRatings.remove(apartmentId.toString());

    box.write(userKey, allRatings);
    print('🗑️ Deleted rating for apartment $apartmentId for user $userId');

    update();
  }

  // 6. Get all ratings for current user
  Map<String, dynamic> getAllRatings() {
    final userId = getCurrentUserId();
    final userKey = getUserStorageKey(userId);

    if (!box.hasData(userKey)) {
      return {};
    }

    final data = box.read(userKey);
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  // 7. Number of rated apartments
  int get totalRatedApartments {
    return getAllRatings().length;
  }

  // 8. Delete all ratings for current user
  void clearAllRatings() {
    final userId = getCurrentUserId();
    final userKey = getUserStorageKey(userId);

    box.remove(userKey);
    print('🧹 Cleared all ratings for user $userId');
    update();
  }
}
