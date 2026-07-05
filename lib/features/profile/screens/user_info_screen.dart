import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/design_tokens.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _auth = FirebaseAuth.instance;

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  bool _isEditing = false; // Biến trạng thái: false = Xem, true = Sửa

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: _auth.currentUser?.displayName ?? "Phuong Quynh",
    );
    _emailController = TextEditingController(
      text: _auth.currentUser?.email ?? "abc@gmail.com",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

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
      return 'Email / Họ tên không được chứa khoảng trắng thừa ở đầu/cuối hoặc giữa các chữ.';
    }

    if (RegExp(r'\d').hasMatch(trimmedName)) {
      return 'Họ và tên phải là chữ cái';
    }

    final nameRegex = RegExp(r'^[A-Za-zÀ-ỹ\s]+ ');
    if (!nameRegex.hasMatch('$trimmedName ')) {
      return 'Email / Họ tên không được chứa ký tự đặc biệt';
    }

    final invalidEmailChar = RegExp(r'[^A-Za-z0-9._@\-]');
    if (invalidEmailChar.hasMatch(trimmedEmail)) {
      return 'Email / Họ tên không được chứa ký tự đặc biệt';
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9](?:[A-Za-z0-9._-]*[A-Za-z0-9])?@gmail\.com$',
    );
    if (!emailRegex.hasMatch(trimmedEmail)) {
      return 'Địa chỉ Gmail không hợp lệ. Vui lòng kiểm tra lại.';
    }

    return null;
  }

  Future<void> _saveProfileInformation() async {
    final validationError = _validateNameAndEmail(
      _nameController.text,
      _emailController.text,
    );
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            validationError,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(_nameController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cập nhật thông tin thành công!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          setState(() {
            _isEditing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Có lỗi xảy ra: $e',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            "Thông tin cá nhân",
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Glowing Profile Photo Container
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
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
                            radius: 54,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _auth.currentUser?.photoURL != null
                                ? NetworkImage(_auth.currentUser!.photoURL!)
                                : const AssetImage("assets/LOGO1.png")
                                      as ImageProvider,
                          ),
                        ),
                      ),
                      if (_isEditing)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: DesignTokens.softShadow,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _nameController.text,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 32),

                // Info Cards Container
                Container(
                  padding: const EdgeInsets.all(24.0),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Họ và tên",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          if (_isEditing)
                            const Text(
                              " *",
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildCustomTextField(
                        controller: _nameController,
                        icon: Icons.person_outline_rounded,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            "Email",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          if (_isEditing)
                            const Text(
                              " *",
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildCustomTextField(
                        controller: _emailController,
                        icon: Icons.mail_outline_rounded,
                        enabled: _isEditing,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action Button
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    gradient: _isEditing
                        ? const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF34D399)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : DesignTokens.primaryAccentGradient,
                    boxShadow: DesignTokens.accentShadow,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    onPressed: () {
                      if (_isEditing) {
                        _saveProfileInformation();
                      } else {
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isEditing
                              ? Icons.check_circle_outline
                              : Icons.edit_note_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isEditing ? "LƯU THAY ĐỔI" : "SỬA THÔNG TIN",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
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

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
          width: enabled ? 1.5 : 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: enabled ? const Color(0xFF1E293B) : const Color(0xFF64748B),
          fontWeight: enabled ? FontWeight.w500 : FontWeight.w400,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: enabled ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
