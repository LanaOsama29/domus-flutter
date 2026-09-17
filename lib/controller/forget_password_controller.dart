import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
class ForgetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (newPassword.text != confirmPassword.text) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final response = await ApiService.forgetPassword(
        newPassword: newPassword.text,
        confirmPassword: confirmPassword.text,
      );
      Get.back();
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.snackbar("Success", data['message']);
        Get.offAllNamed("/login");
      } else {
        Get.snackbar("Error", data['message'] ?? "Failed");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Server error");
    }
  }

  @override
  void onClose() {
    newPassword.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
