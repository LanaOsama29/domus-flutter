import 'dart:convert';
import 'package:domus/controller/favorite_controller.dart';
import 'package:domus/controller/mybooking_controller.dart';
import 'package:domus/view/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final phone = TextEditingController();
  final password = TextEditingController();

  final box = GetStorage();

  void goToSignup() {
    Get.offNamed("/signup");
  }

  void goToForgetPassword() {
    Get.toNamed("/password");
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await ApiService.login(
        phone: phone.text,
        password: password.text,
      );

      Get.back();

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final token = data['token'];
        final user = data['User'] ?? {};
        final box = GetStorage();
        await box.write("token", token);
        await box.write("isLoggedIn", true);
        await box.write("userData", user);
        await box.save();
        Get.offAll(() => MainPage());
        Future.delayed(Duration(milliseconds: 500), () {
          try {
            final bookingsController = Get.find<BookingsController>();
            bookingsController.refreshRoleAndBookings();

            final favoriteController = Get.find<FavoriteController>();
            favoriteController.loadFavoriteApartments();
          } catch (e) {
            print("❌ Error loading data after login: $e");
          }
        });
      } else {
        Get.snackbar("Error", data['message'] ?? "Login failed");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Server error: $e");
    }
  }
}
