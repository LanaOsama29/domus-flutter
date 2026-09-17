import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';

class SettingsController extends GetxController {
  final box = GetStorage();

  var role = "".obs;
  var firstName = "".obs;
  var lastName = "".obs;
  var profileImage = "".obs;
  var userId = "".obs;

  var isDarkMode = false.obs;
  var languageCode = "en".obs;
  var isLoading = true.obs; 

  @override
  void onInit() {
    super.onInit();
    print("🔄 SettingsController initialized");
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    isLoading.value = true;

    print("📦 Loading user data from storage...");

    final storedFirstName = box.read("first_name");
    final storedLastName = box.read("last_name");
    final storedProfileImage = box.read("profile_image");
    final storedRole = box.read("role");
    final storedUserId = box.read("user_id");

    print("📦 Storage data:");
    print("   first_name: $storedFirstName");
    print("   last_name: $storedLastName");
    print("   profile_image: $storedProfileImage");
    print("   role: $storedRole");
    print("   user_id: $storedUserId");

    if (storedFirstName != null && storedLastName != null) {
      firstName.value = storedFirstName;
      lastName.value = storedLastName;
      profileImage.value = storedProfileImage ?? "";
      role.value = storedRole ?? "renter";
      userId.value = storedUserId ?? "";

      print("✅ Loaded from storage");
    } else {

      print("⚠️ Data missing, fetching from API...");
      await _fetchUserProfileFromAPI();
    }

    isDarkMode.value = box.read("darkMode") ?? false;
    languageCode.value = box.read("lang") ?? "en";

    _applyThemeAndLanguage();

    isLoading.value = false;
    update(); 

    print("✅ User data loaded:");
    print("   Name: ${firstName.value} ${lastName.value}");
    print("   Image: ${profileImage.value}");
    print("   Role: ${role.value}");
  }

  Future<void> _fetchUserProfileFromAPI() async {
    try {
      print("📡 Fetching user profile from API...");
      final userData = await ApiService.getUserProfile();

      if (userData.isNotEmpty) {
        print("✅ API response: $userData");

        firstName.value = userData['first_name']?.toString() ?? "User";
        lastName.value = userData['last_name']?.toString() ?? "";
        profileImage.value = userData['profile_image']?.toString() ?? "";
        role.value = userData['role']?.toString() ?? "renter";
        userId.value = userData['id']?.toString() ?? "";

        box.write("first_name", firstName.value);
        box.write("last_name", lastName.value);
        box.write("profile_image", profileImage.value);
        box.write("role", role.value);
        box.write("user_id", userId.value);

        print("✅ Saved to storage");
      } else {

        print("⚠️ No data from API, using defaults");
        _setDefaultData();
      }
    } catch (e) {
      print("❌ Error fetching user profile: $e");
      _setDefaultData();
    }
  }

  void _setDefaultData() {
    firstName.value = "User";
    lastName.value = "";
    profileImage.value = "";
    role.value = box.read("role") ?? "renter";
    userId.value = "";
  }

  void _applyThemeAndLanguage() {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isDarkMode.value) {
        Get.changeThemeMode(ThemeMode.dark);
      } else {
        Get.changeThemeMode(ThemeMode.light);
      }

      Get.updateLocale(Locale(languageCode.value));
    });
  }

  bool get isOwner => role.value == "owner";

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    box.write("darkMode", value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    update();
  }

  void changeLanguage(String code) {
    languageCode.value = code;
    box.write("lang", code);
    Get.updateLocale(Locale(code));
    update();
  }

  Future<void> refreshUserData() async {
    print("🔄 Manually refreshing user data...");
    await _loadUserData();
  }

  void logout() {
    print("🚪 Logging out...");

    box.remove("token");
    box.remove("isLoggedIn");
    box.remove("first_name");
    box.remove("last_name");
    box.remove("profile_image");
    box.remove("role");
    box.remove("user_id");

    firstName.value = "";
    lastName.value = "";
    profileImage.value = "";
    role.value = "";
    userId.value = "";

    Get.offAllNamed("/login");
  }
}
