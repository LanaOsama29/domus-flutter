import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? myController;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPassword;
  final String? fieldType;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.myController,
    this.inputFormatters,
    this.isPassword = false,
    this.fieldType,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword; 
  }

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }

    if (widget.fieldType == "password" && value.length < 8) {
      return "Password must be at least 8 characters";
    }

    if (widget.fieldType == "phone" && value.length != 10) {
      return "Phone number must be 10 digits";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.myController,
      inputFormatters: widget.inputFormatters,
      obscureText: widget.isPassword ? _obscure : false,
      validator: validator,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 203, 205, 209)),
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
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                )
                : null,
      ),
    );
  }
}
