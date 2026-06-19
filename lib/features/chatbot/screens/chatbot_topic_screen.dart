// import 'package:flutter/material.dart';
// import 'chat_screen.dart';

// class ChatbotTopicScreen extends StatelessWidget {
//   const ChatbotTopicScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // 1. Đồng bộ chính xác danh sách Icon và Màu sắc theo Figma
//     final topics = [
//       'PHÒNG VẤN XIN VIỆC',
//       'GỌI MÓN TẠI NHÀ HÀNG',
//       'ĐẶT PHÒNG KHÁCH SẠN',
//       'DU LỊCH & HƯỚNG DẪN',
//       'MUA SẮM',
//       'TRÒ CHUYỆN HÀNG NGÀY',
//     ];

//     // Thay đổi bộ Icon hệ thống bằng các Icon có dạng "Khối đặc" (Filled) để giống Figma nhất
//     final icons = [
//       Icons.business_center, // job
//       Icons.restaurant, // restaurant (hoặc dùng Custom SVG nếu có)
//       Icons.apartment, // hotel
//       Icons.flight_takeoff, // travel
//       Icons.local_mall, // shopping
//       Icons.forum, // daily
//     ];

//     final buttonColors = [
//       const Color(0xFFFF9233), // Cam phòng vấn
//       const Color(0xFFA8A8A8), // Xám gọi món
//       const Color(0xFF46F5F5), // Cyan đặt phòng
//       const Color(0xFF4172F5), // Blue du lịch
//       const Color(0xFF4CEB34), // Green mua sắm
//       const Color(0xFF1A1A1A), // Đen trò chuyện
//     ];

//     return Scaffold(
//       // 2. Sửa lại màu nền tổng thể thành màu xám trắng siêu nhẹ giống Figma
//       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       appBar: AppBar(
//         title: const Text(
//           'CHATBOT AI',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: const Color(0xFF53A7FF), // Màu xanh AppBar sáng
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.maybePop(context),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//         children: [
//           _buildBotIntroBubble(
//             'Xin chào! Tôi sẽ giúp bạn luyện giao tiếp tiếng Anh cùng AI theo ngữ cảnh hiệu quả',
//           ),
//           const SizedBox(height: 10),
//           _buildBotIntroBubble(
//             'Hãy chọn một trong những chủ đề ở dưới đây để bắt đầu nhé!',
//           ),

//           const SizedBox(height: 24),

//           // Danh sách các nút chọn Topic bài học
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: topics.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 14),
//             itemBuilder: (context, index) {
//               return SizedBox(
//                 height: 60, // Tăng nhẹ chiều cao nút cho thoáng như Figma
//                 child: OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     // Đổi màu viền mảnh và nhẹ hơn
//                     side: BorderSide(color: Colors.grey.shade200, width: 1.5),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 1, // Tạo bóng đổ nhẹ cho nút thêm nổi bật
//                     shadowColor: Colors.black12,
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ChatScreen(topic: topics[index]),
//                       ),
//                     );
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     child: Row(
//                       children: [
//                         // Vòng tròn chứa Icon - Đậm nét đổi màu theo từng loại danh mục
//                         Icon(
//                           icons[index],
//                           color: buttonColors[index],
//                           size: 32, // Tăng kích thước Icon lên để nhìn rõ khối
//                         ),
//                         const SizedBox(width: 16),
//                         // Chữ Tiêu đề nút: Ép màu Đen Tuyền và tăng độ đậm font chữ lên tối đa
//                         Expanded(
//                           child: Text(
//                             topics[index],
//                             style: const TextStyle(
//                               color: Colors.black, // Màu đen chữ
//                               fontSize: 15,
//                               fontWeight: FontWeight
//                                   .w900, // Tăng từ w700 lên w800 để nét chữ dày dặn
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // Hàm bổ trợ viết gọn gọn phần Bubble Chat của Bot đầu trang
//   Widget _buildBotIntroBubble(String text) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CircleAvatar(
//           backgroundColor: const Color(0xFFFFF3EB),
//           radius: 18,
//           child: Icon(
//             Icons.sentiment_satisfied_alt,
//             color: Colors.orange.shade700,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey.shade100),
//             ),
//             child: Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.black87,
//                 height: 1.3,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatbotTopicScreen extends StatelessWidget {
  const ChatbotTopicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = [
      'PHÒNG VẤN XIN VIỆC',
      'GỌI MÓN TẠI NHÀ HÀNG',
      'ĐẶT PHÒNG KHÁCH SẠN',
      'DU LỊCH & HƯỚNG DẪN',
      'MUA SẮM',
      'TRÒ CHUYỆN HÀNG NGÀY',
    ];

    final icons = [
      Icons.business_center,
      Icons.restaurant,
      Icons.apartment,
      Icons.flight_takeoff,
      Icons.local_mall,
      Icons.forum,
    ];

    final buttonColors = [
      const Color(0xFFFF9233), // Cam
      const Color(0xFFA8A8A8), // Xám
      const Color(0xFF46F5F5), // Cyan
      const Color(0xFF4172F5), // Blue
      const Color(0xFF4CEB34), // Green
      const Color(0xFF1A1A1A), // Đen
    ];

    return Scaffold(
      backgroundColor: Colors.white, // Figma sử dụng nền trắng tinh tế
      appBar: AppBar(
        title: const Text(
          'Chatbot AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF53A7FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ListView(
        // Thiết lập padding tổng thể cho toàn màn hình theo tỷ lệ Figma
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // Hai dòng tin nhắn chào mừng của Bot đầu trang
          _buildBotIntroBubble(
            'Xin chào! Tôi sẽ giúp bạn luyện giao tiếp tiếng Anh cùng AI theo ngữ cảnh hiệu quả',
          ),
          const SizedBox(height: 12),
          _buildBotIntroBubble(
            'Hãy chọn một trong những chủ đề ở dưới đây để bắt đầu nhé!',
          ),

          const SizedBox(height: 28),

          // Khối danh sách các Topic được đẩy dịch sang phải để CĂN THẲNG HÀNG TRÁI với bong bóng tin nhắn
          Padding(
            // 52px = 36px (độ rộng avatar bot) + 16px (khoảng cách giữa avatar và bong bóng)
            padding: const EdgeInsets.only(left: 52),
            child: Align(
              alignment:
                  Alignment.centerLeft, // Đảm bảo khối luôn ôm sát về bên trái
              child: SizedBox(
                width:
                    250, // Định giới hạn độ dài khung cố định giống hệt thiết kế Figma
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topics.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 52, // Độ cao khối thu gọn vừa vặn
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          elevation: 0.5,
                          shadowColor: Colors.black12,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(topic: topics[index]),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              icons[index],
                              color: buttonColors[index],
                              size: 26,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                topics[index],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight
                                      .w800, // Độ dày chữ in đậm mạnh mẽ
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm xây dựng bong bóng chat của Bot ứng dụng hình ảnh tùy biến mới
  Widget _buildBotIntroBubble(String text) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center, // Căn giữa avatar theo chiều dọc hộp thoại
      children: [
        // THAY THẾ: Sử dụng hình ảnh tùy chọn có sẵn từ Assets thay cho icon mặt cười cũ
        Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(
                'assets/bot_avatar.png',
              ), // Đường dẫn ảnh của bạn
              //fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 10), // Khoảng cách chuẩn từ avatar đến hộp thoại
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1.2),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.w700, // Đậm đà sắc nét như figma
                  height: 1.35,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
