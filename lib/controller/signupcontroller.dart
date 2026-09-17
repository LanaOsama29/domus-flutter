import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';
class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final box = GetStorage();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phoneNumber = TextEditingController();
  final password = TextEditingController();
  final rePassword = TextEditingController();
  final birthDate = TextEditingController();
  Rx<File?> profileImage = Rx<File?>(null);
  Rx<File?> identityImage = Rx<File?>(null);
  RxString selectedRole = "None".obs;
  void changeRole(String value) {
    selectedRole.value = value;
  }
  Future<void> pickBirthDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      birthDate.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    }
  }
  Future<void> signup() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedRole.value == "None") {
      Get.snackbar("Error", "Select account type");
      return;
    }
    if (password.text != rePassword.text) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final response = await ApiService.signup(
        firstName: firstName.text,
        lastName: lastName.text,
        phone: phoneNumber.text,
        password: password.text,
        role: selectedRole.value,
        birthDate: birthDate.text,
        profile: profileImage.value,
        identity: identityImage.value,
      );
      print("STATUS CODE => ${response.statusCode}");
      print("BODY => ${response.body}");
      print("Profile image => ${profileImage.value}");
      print("Identity image => ${identityImage.value}");
      Get.back();
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", data['message']);
        box.write("last_role", selectedRole.value);
        Get.offAllNamed("/login");
      } else {
        Get.snackbar("Error", "Signup failed");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Server error");
    }
  }
  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    phoneNumber.dispose();
    password.dispose();
    rePassword.dispose();
    birthDate.dispose();
    super.onClose();
  }
}