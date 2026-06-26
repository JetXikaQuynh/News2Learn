import 'package:flutter/material.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../articles/screens/article_list_screen.dart';
import '../services/auth_service.dart';
import '../widgets/auth_textfield.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    final error = await AuthService().login(
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ArticleListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: DesignTokens
            .pastelBackgroundGradient, //- hình nền gradient đồng bộ nhẹ nhàng
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

                  //- bọc logo bo góc tròn tinh tế hơn
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

                  //- tiêu đề dùng text gradient cực kỳ cao cấp
                  Text(
                    "ĐĂNG NHẬP",
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
                    "Nhập email và mật khẩu của bạn để tiếp tục",
                    style: DesignTokens.bodyStyle.copyWith(
                      color: const Color(0xFF64748B), //- Slate 500
                    ),
                  ),

                  const SizedBox(height: 40),

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

                  //- nút đăng nhập màu gradient kèm bóng đổ tím
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: DesignTokens.primaryAccentGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: DesignTokens.accentShadow,
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
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
                              "ĐĂNG NHẬP",
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

                  //- liên kết chuyển sang màn hình đăng ký
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bạn chưa có tài khoản?",
                        style: DesignTokens.bodyStyle.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          " Đăng ký ngay",
                          style: DesignTokens.bodyStyle.copyWith(
                            color: const Color(
                              0xFF8B5CF6,
                            ), //- màu tím Violet 500
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
