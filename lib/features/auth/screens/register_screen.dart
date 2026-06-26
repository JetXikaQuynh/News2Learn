import 'package:flutter/material.dart';
import '../../../shared/theme/design_tokens.dart';
import '../services/auth_service.dart';
import '../widgets/auth_textfield.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  //- kiểm tra tính hợp lệ của họ tên và gmail
  String? _validateNameAndEmail(String name, String email) {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty || trimmedEmail.isEmpty) {
      return 'Vui lòng nhập Email và Họ tên';
    }

    final hasNameLeadingOrTrailingSpace = trimmedName != name;
    final hasNameMultipleSpaces = trimmedName.contains(RegExp(r'\s{2,}'));
    final hasEmailWhitespace = email.contains(' ') || trimmedEmail != email;

    if (hasNameLeadingOrTrailingSpace ||
        hasNameMultipleSpaces ||
        hasEmailWhitespace) {
      return 'Email / Họ tên không được chứa khoảng trắng dư thừa hoặc đầu/cuối.';
    }

    if (RegExp(r'\d').hasMatch(trimmedName)) {
      return 'Họ tên phải là các chữ cái';
    }

    final nameRegex = RegExp(r'^[A-Za-zÀ-ỹ\s]+$');
    if (!nameRegex.hasMatch(trimmedName)) {
      return 'Họ tên không được chứa ký tự đặc biệt';
    }

    final invalidEmailChar = RegExp(r'[^A-Za-z0-9._@\-]');
    if (invalidEmailChar.hasMatch(trimmedEmail)) {
      return 'Email không được chứa ký tự đặc biệt';
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9](?:[A-Za-z0-9._-]*[A-Za-z0-9])?@gmail\.com$',
    );
    if (!emailRegex.hasMatch(trimmedEmail)) {
      return 'Địa chỉ Gmail không hợp lệ. Vui lòng kiểm tra lại.';
    }

    return null;
  }

  Future<void> register() async {
    final validationError = _validateNameAndEmail(
      nameController.text,
      emailController.text,
    );
    if (validationError != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(validationError)));
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    final error = await AuthService().register(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đăng ký thành công")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient:
            DesignTokens.pastelBackgroundGradient, //- hình nền gradient mượt mà
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, //- trong suốt để hiện nền gradient
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  //- logo bo góc đồng nhất màn Login
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      "assets/LOGO2.jpg",
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 32),

                  //- tiêu đề chữ gradient cao cấp
                  Text(
                    "ĐĂNG KÝ",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      foreground: Paint()
                        ..shader = DesignTokens.primaryAccentGradient
                            .createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Nhập thông tin của bạn để tiếp tục",
                    style: DesignTokens.bodyStyle.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 40),

                  AuthTextField(
                    controller: nameController,
                    hint: "Họ tên",
                    icon: Icons.person_outline,
                  ),

                  AuthTextField(
                    controller: emailController,
                    hint: "Email",
                    icon: Icons.email_outlined,
                  ),

                  AuthTextField(
                    controller: passwordController,
                    hint: "Mật khẩu",
                    icon: Icons.lock_outline,
                    obscure: true,
                  ),

                  const SizedBox(height: 16),

                  //- nút đăng ký gradient có bóng đổ
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: DesignTokens.primaryAccentGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: DesignTokens.accentShadow,
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "ĐĂNG KÝ",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  //- liên kết chuyển sang màn đăng nhập
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bạn đã có tài khoản?",
                        style: DesignTokens.bodyStyle.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          " Đăng nhập",
                          style: DesignTokens.bodyStyle.copyWith(
                            color: const Color(0xFF8B5CF6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
