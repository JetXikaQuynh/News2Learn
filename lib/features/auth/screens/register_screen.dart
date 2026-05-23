import 'package:flutter/material.dart';

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

  Future<void> register() async {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));

      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Đăng ký thành công")));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),

          child: Column(
            children: [
              const SizedBox(height: 30),

              Image.asset("assets/LOGO2.jpg", width: 140),

              const SizedBox(height: 40),

              const Text(
                "ĐĂNG KÝ",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 50),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nhập thông tin của bạn để tiếp tục",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

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

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton(
                  onPressed: isLoading ? null : register,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),

                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "ĐĂNG KÝ",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Bạn đã có tài khoản?"),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: const Text(
                      " Đăng nhập",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
