import 'package:domus/controller/signupcontroller.dart';
import 'package:domus/view/component/color.dart';
import 'package:domus/view/component/image.dart';
import 'package:domus/view/component/text.dart';
import 'package:domus/view/component/textfield.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Signup extends GetView<SignupController> {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                'images/icon2.png',
                height: 150,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            const Text(
              "DOMUS",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.lightBackground,
                fontFamily: "Nunito",
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              height: 550,
              width: 330,
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const CustomText(text: "Your first name "),
                      const SizedBox(height: 10),
                      CustomTextField(
                        hintText: "E.g.Lana",
                        myController: controller.firstName,
                      ),
                      const SizedBox(height: 10),
                      const CustomText(text: "Your last name"),
                      const SizedBox(height: 10),
                      CustomTextField(
                        hintText: "E.g.Osama",
                        myController: controller.lastName,
                      ),
                      const SizedBox(height: 10),
                      const CustomText(text: "Phone number"),
                      const SizedBox(height: 10),
                      CustomTextField(
                        hintText: "+96300000000",
                        myController: controller.phoneNumber,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        fieldType: "phone",
                      ),
                      const SizedBox(height: 10),
                      const CustomText(text: "Password"),
                      const SizedBox(height: 10),
                      CustomTextField(
                        hintText: "********",
                        myController: controller.password,
                        isPassword: true,
                        fieldType: "password",
                      ),
                      const SizedBox(height: 10),
                      const CustomText(text: "Confirm Password"),
                      const SizedBox(height: 10),
                      CustomTextField(
                        hintText: "********",
                        myController: controller.rePassword,
                        isPassword: true,
                        fieldType: "password",
                      ),
                      const SizedBox(height: 10),
                      const CustomText(text: "Your date of birth"),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: controller.birthDate,
                        readOnly: true,
                        onTap: () => controller.pickBirthDate(context),
                        decoration: InputDecoration(
                          hintText: "DD/MM/YYYY", // Date format hint
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 203, 205, 209),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          fillColor: const Color.fromARGB(255, 249, 249, 251),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          suffixIcon: const Icon(Icons.calendar_month),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const CustomText(text: "Your profile picture"),
                      const SizedBox(height: 10),
                      Center(
                        child: ProfileImagePicker(
                          onImagePicked: (file) {
                            controller.profileImage.value = file;
                          },
                        ),
                      ),

                      const SizedBox(height: 10),
                      const CustomText(text: "Your personal identity"),
                      const SizedBox(height: 10),
                      Center(
                        child: ProfileImagePicker(
                          onImagePicked: (file) {
                            controller.identityImage.value = file;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const CustomText(text: "Choose your account type"),
                      const SizedBox(height: 10),

                      /// Radio Buttons
                      Obx(
                        () => Row(
                          children: [
                            RadioMenuButton(
                              value: "renter",
                              groupValue: controller.selectedRole.value,
                              onChanged:
                                  (value) => controller.changeRole(value!),
                              child: const Text("Tenant"),
                            ),
                            RadioMenuButton(
                              value: "owner",
                              groupValue: controller.selectedRole.value,
                              onChanged:
                                  (value) => controller.changeRole(value!),
                              child: const Text("Owner"),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      MaterialButton(
                        onPressed: controller.signup,
                        height: 50,
                        minWidth: double.infinity,
                        color: AppColors.button,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: AppColors.lightBackground,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: "Log in",
                                style: const TextStyle(
                                  color: AppColors.thirdly,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        Get.offNamed("/login");
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
