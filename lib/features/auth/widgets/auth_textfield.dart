import 'package:flutter/material.dart';
import '../../../shared/theme/design_tokens.dart';

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
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignTokens.softShadow, //- bóng đổ nhẹ nhàng tạo chiều sâu
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: isObscure,
        style: DesignTokens.bodyStyle.copyWith(
          fontSize: 15,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: DesignTokens.bodyStyle.copyWith(
            color: const Color(0xFF94A3B8), //- màu xám nhẹ Slate 400
            fontSize: 15,
          ),
          prefixIcon: Icon(
            widget.icon,
            size: 22,
            color: const Color(0xFF64748B), //- màu icon Slate 500
          ),

          //- nút bật tắt ẩn hiện mật khẩu
          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(
                    isObscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: const Color(0xFF64748B),
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      isObscure = !isObscure;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF8B5CF6),
              width: 1.5,
            ), //- viền màu tím khi focus gõ chữ
          ),
        ),
      ),
    );
  }
}
