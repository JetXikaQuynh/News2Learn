import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../auth/screens/login_screen.dart';
import 'user_info_screen.dart';
import 'statistics_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    String joinDate = "Tham gia từ ngày 24 tháng 5, 2026";
    if (user?.metadata.creationTime != null) {
      joinDate =
          "Tham gia từ ngày ${DateFormat('d/M/yyyy').format(user!.metadata.creationTime!)}";
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: DesignTokens.pastelBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF1E293B),
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          title: Text(
            "Cá nhân",
            style: GoogleFonts.inter(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Profile Card Container
                Container(
                  // margin: const EdgeInsets.all(16.0),
                  // padding: const EdgeInsets.all(24.0),
                  // decoration: BoxDecoration(
                  //   color: Colors.white.withOpacity(0.9),
                  //   borderRadius: BorderRadius.circular(24),
                  //   boxShadow: DesignTokens.softShadow,
                  //   border: Border.all(
                  //     color: Colors.white.withOpacity(0.6),
                  //     width: 1.5,
                  //   ),
                  // ),
                  child: Column(
                    children: [
                      // Glowing Avatar Border
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: DesignTokens.primaryAccentGradient,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : const AssetImage("assets/LOGO1.png")
                                    as ImageProvider,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.displayName ?? "Phuong Quynh",
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? "",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          joinDate,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF3B82F6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Statistics Dashboard Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: DesignTokens.softShadow,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.menu_book_rounded,
                        value: "9/30",
                        label: "Từ vựng",
                        color: const Color(0xFF3B82F6),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: const Color(0xFFE2E8F0),
                      ),
                      _buildStatItem(
                        icon: Icons.quiz_rounded,
                        value: "7",
                        label: "Bài Quiz",
                        color: const Color(0xFF8B5CF6),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: const Color(0xFFE2E8F0),
                      ),
                      _buildStatItem(
                        icon: Icons.stars_rounded,
                        value: "85%",
                        label: "Tỷ lệ đạt",
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),

                // Menu Items Container
                Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: DesignTokens.softShadow,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        context: context,
                        icon: Icons.badge_outlined,
                        iconColor: const Color(0xFF3B82F6),
                        title: "Thông tin cá nhân",
                        subtitle: "Xem và cập nhật hồ sơ của bạn",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserInfoScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: Colors.grey[200]),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.lock_outline,
                        iconColor: const Color(0xFFF59E0B),
                        title: "Đổi mật khẩu",
                        subtitle: "Bảo mật tài khoản của bạn",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: Colors.grey[200]),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.language_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        title: "Ngôn ngữ",
                        subtitle: "Tiếng Việt (Mặc định)",
                        onTap: () {},
                      ),
                      Divider(height: 1, color: Colors.grey[200]),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.analytics_outlined,
                        iconColor: const Color(0xFF10B981),
                        title: "Thống kê học tập",
                        subtitle: "Tiến trình học và kết quả kiểm tra",
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

                // Logout Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "ĐĂNG XUẤT",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.exit_to_app,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF94A3B8),
        size: 22,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }
}
