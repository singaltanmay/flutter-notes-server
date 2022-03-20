import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  Icon? prefixIcon;
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  Widget? suffixIcon;

  InputField(
      {Key? key,
      this.prefixIcon,
      this.suffixIcon,
      required this.hintText,
      this.isPassword = false,
      required this.controller})
      : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 25,
            offset: Offset(0, 5),
            spreadRadius: -25,
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 25),
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Color(0xffA6B0BD),
          ),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: widget.prefixIcon,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 75,
          ),
          suffixIcon: widget.suffixIcon,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 75,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
