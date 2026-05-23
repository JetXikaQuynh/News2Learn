import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool isObscure;

  @override
  void initState() {
    super.initState();

    isObscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),

      child: TextField(
        controller: widget.controller,

        obscureText: isObscure,

        decoration: InputDecoration(
          hintText: widget.hint,

          prefixIcon: Icon(widget.icon, size: 28),

          // 👁️ ICON MẮT
          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                  ),

                  onPressed: () {
                    setState(() {
                      isObscure = !isObscure;
                    });
                  },
                )
              : null,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),

          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
