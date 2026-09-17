import 'package:domus/controller/login_controller.dart';
import 'package:domus/view/component/color.dart';
import 'package:domus/view/component/text.dart';
import 'package:domus/view/component/textfield.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Login extends GetView<LoginController> {
  const Login({super.key});

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
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              height: 350,
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
                      const CustomText(text: "Phone number"),
                      const SizedBox(height: 10),
                      CustomTextField(
                        hintText: "+96300000000",
                        myController: controller.phone,
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
                      GestureDetector(
                        onTap: controller.goToForgetPassword,
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Forget Password",
                            style: TextStyle(
                              color: AppColors.thirdly,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MaterialButton(
                        onPressed: controller.login,
                        height: 50,
                        minWidth: double.infinity,
                        color: AppColors.button,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          "Log In",
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
                            text: "Don't have an account? ",
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign up",
                                style: const TextStyle(
                                  color: AppColors.thirdly,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = controller.goToSignup,
                              ),
                            ],
                          ),
                        ),
                      ),
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
