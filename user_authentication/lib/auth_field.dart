import 'package:flutter/material.dart';

class AuthFied extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isObscureText;
  final String? Function(String?)? validator;

  const AuthFied({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscureText,
      decoration: InputDecoration(
        hintText: hintText,
        errorMaxLines: 3,
      ),
      validator: validator,
    );
  }
}
