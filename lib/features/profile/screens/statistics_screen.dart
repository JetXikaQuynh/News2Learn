import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Giả lập dữ liệu lịch sử làm bài Quiz để hiển thị lên UI giống Figma
  final List<Map<String, dynamic>> quizHistory = [
    {
      "title": "Quiz 8",
      "score": "18/20 câu đúng",
      "percent": 90,
      "date": "23/05/2026",
      "rank": "Xuất sắc",
      "color": Colors.green,
    },
    {
      "title": "Quiz 7",
      "score": "10/20 câu đúng",
      "percent": 50,
      "date": "22/05/2026",
      "rank": "Khá",
      "color": Colors.orange,
    },
    {
      "title": "Quiz 6",
      "score": "25/30 câu đúng",
      "percent": 80,
      "date": "22/05/2026",
      "rank": "Tốt",
      "color": Colors.yellow,
    },
    {
      "title": "Quiz 5",
      "score": "10/30 câu đúng",
      "percent": 33,
      "date": "19/04/2026",
      "rank": "Tệ",
      "color": Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Nền xám nhạt nhẹ nhàng
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thống kê",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 1. Chỉ số: Từ vựng đã học (Tiến trình ProgressBar)
            _buildStatCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Từ vựng đã học",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "9/30",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: const LinearProgressIndicator(
                      value: 9 / 30,
                      minHeight: 10,
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF2F92EC),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Chỉ số: Số bài quiz đã làm
            _buildStatCard(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Số bài quiz",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "${quizHistory.length + 3}", // Tổng 7 bài như Figma
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "bài đã hoàn thành",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Chỉ số: Tỷ lệ đạt (%)
            _buildStatCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tỷ lệ đạt",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text(
                        "85%",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "làm đúng quiz",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 4. Hệ thống TabBar tùy biến bo góc chuẩn thiết kế
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 135, 141, 148),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize
                    .tab, //Ép indicator kéo dài hết chiều rộng của một Tab (1/2 TabBar)
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF2F92EC), // Màu chủ đạo xanh biển
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                tabs: const [
                  Tab(text: "🕒 Lịch sử ôn tập"),
                  Tab(text: "🔥 Thành tích"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 5. Nội dung TabView bên dưới hiển thị List lịch sử làm bài
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Danh sách Lịch sử ôn tập
                  ListView.separated(
                    itemCount: quizHistory.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = quizHistory[index];
                      return _buildQuizHistoryItem(item);
                    },
                  ),
                  // Tab 2: Thành tích (Có thể phát triển thêm sau)
                  const Center(
                    child: Text("🏆 Các danh hiệu, huy hiệu của bạn ở đây!"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Khung Widget bọc ngoài các thẻ thống kê tổng quan
  Widget _buildStatCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FF), // Màu xanh dương pastel nhẹ nhàng
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  // Widget hiển thị từng hàng item trong lịch sử làm bài
  Widget _buildQuizHistoryItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          // Khối trái: Tên Quiz, số câu đúng và ngày làm bài
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item["score"],
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item["date"],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Khối phải: Phần trăm đạt được và Badge xếp loại tương ứng
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${item["percent"]}%",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (item["color"] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item["rank"],
                  style: TextStyle(
                    color: item["color"] == Colors.yellow
                        ? Colors.orange[800]
                        : item["color"],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
