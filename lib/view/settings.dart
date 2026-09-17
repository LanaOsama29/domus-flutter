import 'package:domus/view/posting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/settings_controller.dart';
import '../services/api_service.dart';
import '../view/component/color.dart';
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
     // backgroundColor: AppColors.lightBackground,
      body: Column(
        children: [
          Container(
            height: h * 0.20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: const Center(
              child: Text(
                "Settings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap:
                controller.isOwner
                    ? () {
                      Get.to(() => const OwnerPostsPage());
                    }
                    : null,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage:
                        controller.profileImage.value.isNotEmpty
                            ? NetworkImage(controller.profileImage.value)
                            : null,
                    child:
                        controller.profileImage.value.isEmpty
                            ? const Icon(Icons.person, size: 32)
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${controller.firstName} ${controller.lastName}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              controller.isOwner ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // سهم يظهر فقط إذا Owner
                  if (controller.isOwner)
                    const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text("Language"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _languageDialog(controller),
                ),
                Obx(
                  () => SwitchListTile(
                    secondary: const Icon(Icons.dark_mode),
                    title: const Text("Dark Mode"),
                    value: controller.isDarkMode.value,
                    onChanged: controller.toggleTheme,
                  ),
                ),

                const Divider(),

                // LOGOUT
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _logoutDialog(controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
void _languageDialog(SettingsController controller) {
  Get.defaultDialog(
    title: "Choose Language",
    content: Column(
      children: [
        ListTile(
          title: const Text("English"),
          onTap: () {
            Get.updateLocale(const Locale('en'));
            Get.back();
          },
        ),
        ListTile(
          title: const Text("العربية"),
          onTap: () {
            Get.updateLocale(const Locale('ar'));
            Get.back();
          },
        ),
      ],
    ),
  );
}
void _logoutDialog(SettingsController controller) {
  Get.defaultDialog(
    title: "Logout",
    middleText: "Are you sure you want to logout?",
    textConfirm: "Yes",
    textCancel: "Cancel",
    confirmTextColor: Colors.white,
    onConfirm: () async {
      await ApiService.logout();
      controller.logout();
    },
  );
}