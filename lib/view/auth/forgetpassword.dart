import 'package:domus/controller/forget_password_controller.dart';
import 'package:domus/view/component/color.dart';
import 'package:domus/view/component/text.dart';
import 'package:domus/view/component/textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassword extends GetView<ForgetPasswordController> {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(200, 219, 241, 243),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: controller.formKey,
            child: ListView(
              children: [
                const SizedBox(height: 150),

                Text(
                  "DOMUS",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightBackground,
                    fontFamily: "Nunito",
                  ),
                ),

                const SizedBox(height: 30),

                const CustomText(
                  text:
                      "Enter a new password. When you enter a new password, the old one will be erased and the new one will be adopted.",
                ),

                const SizedBox(height: 30),

                CustomTextField(
                  hintText: "********",
                  myController: controller.newPassword,
                  isPassword: true,
                ),

                const SizedBox(height: 30),

                CustomTextField(
                  hintText: "********",
                  myController: controller.confirmPassword,
                  isPassword: true,
                ),

                const SizedBox(height: 200),

                MaterialButton(
                  onPressed: controller.submit, // 🔥 هون الفرق الوحيد
                  height: 50,
                  minWidth: double.infinity,
                  color: AppColors.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      color: AppColors.lightBackground,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
