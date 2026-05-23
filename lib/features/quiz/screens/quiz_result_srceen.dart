import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onRestart;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final percent = ((score / totalQuestions) * 100).round();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Giữ Logo và chữ Quiz ở góc trái
              children: [
                Image.asset("assets/LOGO1.png", height: 80),
                const Text(
                  "Quiz",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 96, 22),
                  ),
                ),

                // Phần này bọc lại để căn chỉnh mọi thành phần kết quả ra chính giữa màn hình
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 30,
                      ), // Giảm khoảng cách cho cân đối
                      // Cúp vàng kết quả
                      const Icon(
                        Icons.emoji_events,
                        size: 150,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 30),

                      // Tiêu đề hoàn thành
                      const Text(
                        "Bạn đã hoàn thành bài kiểm tra!",
                        style: TextStyle(
                          fontSize:
                              24, // Chỉnh lại kích thước chữ vừa vặn với mobile
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),

                      // Hiển thị số điểm
                      Text(
                        "Điểm của bạn: $score/$totalQuestions câu",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),

                      // Thanh Tiến Trình (Progress Bar)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ), // Tạo khoảng cách 2 bên thanh progress
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          backgroundColor: Colors.grey[300],
                          color: Colors.green,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Phần trăm điểm số
                      Text(
                        "$percent%",
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Lời nhắn động viên dựa trên số điểm
                      Text(
                        percent >= 70
                            ? "Xuất sắc! Bạn nhớ từ rất tốt! 💪"
                            : "Hãy tiếp tục học tập! Bạn sẽ tiến bộ hơn thôi!",
                        style: TextStyle(
                          fontSize: 18,
                          color: percent >= 70
                              ? Colors.green
                              : const Color.fromARGB(255, 255, 156, 34),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Thêm icon bắp tay ở dưới text (nếu có) theo Figma
                      if (percent < 70) ...[
                        const SizedBox(height: 10),
                        const Text("💪", style: TextStyle(fontSize: 30)),
                      ],

                      const SizedBox(height: 40),

                      // Nút làm bài Quiz mới
                      ElevatedButton.icon(
                        onPressed: onRestart,
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: const Text(
                          "Làm bài Quiz mới",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
