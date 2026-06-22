import 'package:flutter/material.dart';
import 'chat_screen.dart';
import '../../../shared/theme/design_tokens.dart';

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
      Icons.business_center_rounded,
      Icons.restaurant_rounded,
      Icons.apartment_rounded,
      Icons.flight_takeoff_rounded,
      Icons.local_mall_rounded,
      Icons.forum_rounded,
    ];

    // Accent gradients per topic
    final List<List<Color>> gradients = [
      [const Color(0xFFFF8C42), const Color(0xFFFF5F57)],
      [const Color(0xFF43C6AC), const Color(0xFF3B82F6)],
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      [const Color(0xFF4172F5), const Color(0xFF00C9FF)],
      [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      [const Color(0xFF8B5CF6), const Color(0xFF3B82F6)],
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: DesignTokens.pastelBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // HEADER
              Text(
                "AI Chatbot",
                style: DesignTokens.headingStyle.copyWith(
                  fontSize: 28,
                  foreground: Paint()
                    ..shader =
                        DesignTokens.primaryAccentGradient.createShader(
                      const Rect.fromLTWH(0, 0, 200, 70),
                    ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Luyện giao tiếp tiếng Anh cùng AI",
                style: DesignTokens.bodyStyle,
              ),
              const SizedBox(height: 28),

              // BOT GREETING
              _buildBotIntroBubble(
                'Xin chào! Tôi sẽ giúp bạn luyện giao tiếp tiếng Anh cùng AI theo ngữ cảnh hiệu quả 🚀',
              ),
              const SizedBox(height: 12),
              _buildBotIntroBubble(
                'Hãy chọn một trong những chủ đề ở dưới đây để bắt đầu nhé!',
              ),
              const SizedBox(height: 28),

              // TOPIC GRID
              Text(
                "Chọn chủ đề",
                style: DesignTokens.subheadingStyle.copyWith(
                  color: const Color(0xFF334155),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topics.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  return _buildTopicCard(
                    context,
                    topic: topics[index],
                    icon: icons[index],
                    gradientColors: gradients[index],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard(
    BuildContext context, {
    required String topic,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(topic: topic),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.35),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Text(
                topic,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotIntroBubble(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/bot_avatar.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: DesignTokens.softShadow,
            ),
            child: Text(
              text,
              style: DesignTokens.bodyStyle.copyWith(
                fontSize: 14,
                color: const Color(0xFF334155),
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
