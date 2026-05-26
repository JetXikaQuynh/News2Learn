import 'package:fl_chart/fl_chart.dart'; // 1. Import thư viện biểu đồ
import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dữ liệu mẫu lịch sử Quiz
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
      backgroundColor: const Color(0xFFF8FAFC),
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

            // 1. Chỉ số: Từ vựng đã học
            _buildStatCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Từ vựng đã học",
                        style: TextStyle(fontSize: 15, color: Colors.black87),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Số bài quiz",
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text(
                        "7",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "bài đã hoàn thành",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Chỉ số: Tỷ lệ đạt
            _buildStatCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tỷ lệ đạt",
                    style: TextStyle(fontSize: 15, color: Colors.black87),
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
                      SizedBox(width: 6),
                      Text(
                        "làm đúng quiz",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 4. TabBar với indicator full 1/2 chiều rộng
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 152, 158, 165),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF2F92EC),
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

            // 5. Nội dung các Tab
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
                      return _buildQuizHistoryItem(quizHistory[index]);
                    },
                  ),

                  // Tab 2: Thành tích (Đã thiết kế chuẩn Figma với Biểu đồ tròn)
                  _buildAchievementTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET TAB THÀNH TÍCH (CHUẨN FIGMA) ---
  Widget _buildAchievementTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Khối Điểm cao nhất
          Center(
            child: Column(
              children: const [
                SizedBox(height: 5),
                Text(
                  "Điểm cao nhất",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "90%",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  "Quiz 8",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // const SizedBox(height: 25),
          const Divider(thickness: 1),
          const SizedBox(height: 10),

          // Khối Phân bố kết quả (Biểu đồ)
          const Center(
            child: Text(
              "Phân bố kết quả",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Center(
            child: Text(
              "Tỷ lệ phần trăm các mức điểm đạt được",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 10),

          // 📊 KHU VỰC VẼ BIỂU ĐỒ TRÒN (DONUT CHART)
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2, // Khoảng cách giữa các miếng bánh
                centerSpaceRadius: 45, // Bán kính rỗng ở giữa để tạo hình Donut
                startDegreeOffset: -90, // Bắt đầu vẽ từ góc 12 giờ
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: 14, // Phần trăm Xuất sắc
                    title: '14%',
                    radius: 22,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.blue,
                    value: 57, // Phần trăm Tốt
                    title: '57%',
                    radius: 22,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.orange,
                    value: 20, // Phần trăm Khá
                    title: '20%',
                    radius: 22,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: 9, // Phần trăm Tệ (Bổ sung mới)
                    title: '9%',
                    radius: 22,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Chú thích các màu sắc của biểu đồ (Thêm mức Tệ màu đỏ)
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem("Xuất sắc (≥90%)", Colors.green),
              _buildLegendItem("Tốt (80-89%)", Colors.blue),
              _buildLegendItem("Khá (50-79%)", Colors.orange),
              _buildLegendItem("Cần cải thiện (<50%)", Colors.red),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(thickness: 1),
          const SizedBox(height: 15),

          // Khối Phân tích chi tiết (Progress Bars hình chữ nhật phẳng)
          const Text(
            "Phân tích chi tiết",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Thống kê số lượng bài quiz theo từng mức điểm",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),

          const SizedBox(height: 15),

          // List danh sách Progress bar thống kê số bài cụ thể
          _buildDetailProgressBar(
            "Xuất sắc (≥90%)",
            "1 bài",
            1 / 7,
            Colors.green,
          ),
          _buildDetailProgressBar("Tốt (80-89%)", "4 bài", 4 / 7, Colors.blue),
          _buildDetailProgressBar(
            "Khá (50-79%)",
            "2 bài",
            2 / 7,
            Colors.orange,
          ),
          _buildDetailProgressBar(
            "Cần cải thiện (<50%)",
            "0 bài",
            0 / 7,
            Colors.red,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- CÁC WIDGET PHỤ TRỢ (HELPER WIDGETS) ---

  Widget _buildStatCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildQuizHistoryItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
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

  // Widget tạo dòng chú thích màu dưới biểu đồ tròn
  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.rectangle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  // Widget tạo thanh Progress Bar phẳng ngang cho mục Phân tích chi tiết
  Widget _buildDetailProgressBar(
    String label,
    String trailingText,
    double progressValue,
    Color barColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                trailingText,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(
              2,
            ), // Bo góc vuông phẳng nhẹ theo style Figma
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
