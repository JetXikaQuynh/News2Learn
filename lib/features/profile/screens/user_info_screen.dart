import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _auth = FirebaseAuth.instance;

  // Các Controller quản lý nhập liệu
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  bool _isEditing = false; // Biến trạng thái: false = Xem, true = Sửa

  @override
  void initState() {
    super.initState();
    // Lấy dữ liệu hiện tại từ Firebase Auth gắn vào ô nhập
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

  // Hàm xử lý cập nhật thông tin lên Firebase Auth
  Future<void> _saveProfileInformation() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Cập nhật tên hiển thị
        await user.updateDisplayName(_nameController.text.trim());
        // Lưu ý: Nếu muốn cập nhật email, Firebase yêu cầu xác thực lại,
        // tạm thời ta cập nhật UI profile thành công trước.

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công!')),
        );
        setState(() {
          _isEditing = false; // Quay lại chế độ xem thông tin
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header nền xanh có nút Back và Avatar (Giữ đồng bộ thiết kế Figma)
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: const Color(0xFFE8F4FF), // Màu xanh nhạt theo Figma
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
                // Khối Avatar bo tròn viền trắng đè mép
                Positioned(
                  bottom: -50,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _auth.currentUser?.photoURL != null
                              ? NetworkImage(_auth.currentUser!.photoURL!)
                              : const AssetImage("assets/LOGO1.png")
                                    as ImageProvider,
                        ),
                      ),
                      // Nếu đang ở chế độ chỉnh sửa, hiện thêm icon máy ảnh góc dưới bên phải avatar
                      if (_isEditing)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // Tên cố định ở giữa màn hình bên dưới ảnh đại diện
            Center(
              child: Text(
                _nameController.text,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6016), // Màu cam chuẩn thiết kế
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. Khu vực Form nhập liệu / xem thông tin cá nhân
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nhãn Họ và tên
                  Row(
                    children: [
                      const Text(
                        "Họ tên:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_isEditing)
                        const Text(
                          " *",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Ô nhập Họ và Tên
                  _buildCustomTextField(
                    controller: _nameController,
                    icon: Icons.person_outline,
                    enabled: _isEditing,
                  ),

                  const SizedBox(height: 20),

                  // Nhãn Email
                  Row(
                    children: [
                      const Text(
                        "Email:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_isEditing)
                        const Text(
                          " *",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Ô nhập Email
                  _buildCustomTextField(
                    controller: _emailController,
                    icon: Icons.mail_outline,
                    enabled: _isEditing,
                  ),

                  const SizedBox(height: 40),

                  // 3. Khối Nút xử lý chuyển đổi giao diện động (SỬA THÔNG TIN <-> LƯU)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF2F92EC,
                        ), // Màu xanh biển chuẩn Figma
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (_isEditing) {
                          _saveProfileInformation(); // Đang chỉnh sửa -> bấm sẽ Lưu
                        } else {
                          setState(() {
                            _isEditing =
                                true; // Đang xem -> bấm sẽ bật chế độ Chỉnh sửa
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isEditing ? Icons.check : Icons.edit_note,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEditing ? "LƯU" : "SỬA THÔNG TIN",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget sinh thiết kế ô Input bọc khung bo góc xám mờ theo Figma
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? Colors.white
            : Colors.grey[50], // Làm mờ nhẹ nền khi chỉ xem
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
