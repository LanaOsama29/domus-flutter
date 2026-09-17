import 'package:domus/view/component/color.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
 final String text;

  const CustomText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.darkBackground,
        fontFamily: "Nunito",
      ),
    );
  }
}
