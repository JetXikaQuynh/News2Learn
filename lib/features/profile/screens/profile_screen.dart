import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../auth/screens/login_screen.dart';
import 'user_info_screen.dart';
import 'statistics_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    String joinDate = "Tham gia từ ngày 24 tháng 5, 2026";
    if (user?.metadata.creationTime != null) {
      joinDate =
          "Tham gia từ ngày ${DateFormat('d tháng M, yyyy').format(user!.metadata.creationTime!)}";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Header có nền xanh nhạt chứa nút Back và Avatar
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                color: const Color(0xFFE8F4FF),
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage("assets/LOGO1.png") as ImageProvider,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          // 2. Thông tin User
          Text(
            user?.displayName ?? "Phuong Quynh",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6016),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            joinDate,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),

          const SizedBox(height: 30),

          // 3. Danh sách Menu điều hướng
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMenuItem(
                  icon: Icons.badge_outlined,
                  title: "Thông tin cá nhân",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserInfoScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.lock_open_outlined,
                  title: "Đổi mật khẩu",
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.language_outlined,
                  title: "Ngôn ngữ",
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.analytics_outlined,
                  title: "Thống kê",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StatisticsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 4. Nút Đăng xuất (Đã cập nhật Logic điều hướng xóa Stack)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  // Bước 1: Đăng xuất khỏi Firebase Auth
                  await FirebaseAuth.instance.signOut();

                  // Bước 2: Điều hướng về LoginScreen và xóa toàn bộ các màn hình trước đó
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false, // Xóa sạch lịch sử các màn hình cũ
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "ĐĂNG XUẤT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.exit_to_app, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.black87, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black54,
        size: 16,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
