import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../services/hive_service.dart';
import '../../../models/quiz_result_model.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<QuizResultModel> _quizResults = [];
  int _totalVocab = 0;
  int _learnedVocab = 0;

  int get _totalQuizzes => _quizResults.length;

  double get _avgPercent {
    if (_quizResults.isEmpty) return 0;
    final sum = _quizResults.fold<double>(
      0,
      (s, r) =>
          s +
          (r.totalQuestions > 0 ? r.correctCount / r.totalQuestions * 100 : 0),
    );
    return sum / _quizResults.length;
  }

  QuizResultModel? get _bestResult {
    if (_quizResults.isEmpty) return null;
    return _quizResults.reduce((a, b) {
      final pA = a.totalQuestions > 0 ? a.correctCount / a.totalQuestions : 0;
      final pB = b.totalQuestions > 0 ? b.correctCount / b.totalQuestions : 0;
      return pA >= pB ? a : b;
    });
  }

  int _countByTier(int min, int max) => _quizResults.where((r) {
    if (r.totalQuestions == 0) return false;
    final p = (r.correctCount / r.totalQuestions * 100).round();
    return p >= min && p <= max;
  }).length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    try {
      final hive = HiveService.instance;
      _quizResults = hive.quizResultBox.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // mới nhất trước
      _totalVocab = hive.vocabBox.length;
      _learnedVocab = hive.userVocabBox.values.where((v) => v.isLearned).length;
    } catch (_) {
      // boxes chưa mở
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _toHistoryMap(QuizResultModel r, int index) {
    final percent = r.totalQuestions > 0
        ? (r.correctCount / r.totalQuestions * 100).round()
        : 0;
    String rank;
    Color color;
    if (percent >= 90) {
      rank = "Xuất sắc";
      color = const Color(0xFF10B981);
    } else if (percent >= 80) {
      rank = "Tốt";
      color = const Color(0xFF3B82F6);
    } else if (percent >= 50) {
      rank = "Khá";
      color = const Color(0xFFF59E0B);
    } else {
      rank = "Cần cố gắng";
      color = const Color(0xFFEF4444);
    }
    return {
      "title": "Quiz ${_quizResults.length - index}",
      "score": "${r.correctCount}/${r.totalQuestions} câu đúng",
      "percent": percent,
      "date": DateFormat('dd/MM/yyyy').format(r.createdAt),
      "rank": rank,
      "color": color,
    };
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
              backgroundColor: Colors.white.withValues(alpha: 0.9),
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
            "Thống kê học tập",
            style: GoogleFonts.inter(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _buildDashboardCard(
                        title: "Số bài Quiz",
                        value: "$_totalQuizzes",
                        subtitle: "Đã hoàn thành",
                        icon: Icons.assignment_turned_in_rounded,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDashboardCard(
                        title: "Tỷ lệ đúng TB",
                        value: _totalQuizzes > 0
                            ? "${_avgPercent.round()}%"
                            : "—",
                        subtitle: "Trung bình các bài",
                        icon: Icons.track_changes_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: DesignTokens.softShadow,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF8B5CF6,
                                  ).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  color: Color(0xFF8B5CF6),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Từ vựng đã học",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _totalVocab > 0
                                ? "$_learnedVocab / $_totalVocab"
                                : "Chưa có dữ liệu",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _totalVocab > 0
                              ? _learnedVocab / _totalVocab
                              : 0,
                          minHeight: 10,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF8B5CF6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: DesignTokens.softShadow,
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: DesignTokens.primaryAccentGradient,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF64748B),
                    labelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: "Lịch sử ôn tập"),
                      Tab(text: "Thành tích"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _quizResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.quiz_outlined,
                                    size: 56,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Chưa có lịch sử làm bài",
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _quizResults.length,
                              itemBuilder: (context, index) {
                                return _buildQuizHistoryCard(
                                  _toHistoryMap(_quizResults[index], index),
                                );
                              },
                            ),

                      _buildAchievementTab(),
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

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: DesignTokens.softShadow,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTab() {
    if (_totalQuizzes == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 56,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            Text(
              "Làm quiz để xem thành tích của bạn",
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final best = _bestResult!;
    final bestPercent = best.totalQuestions > 0
        ? (best.correctCount / best.totalQuestions * 100).round()
        : 0;

    final countExcellent = _countByTier(90, 100);
    final countGood = _countByTier(80, 89);
    final countOk = _countByTier(50, 79);
    final countPoor = _countByTier(0, 49);

    List<PieChartSectionData> sections = [];
    void addSection(int count, Color color, String label) {
      if (count == 0) return;
      final pct = (count / _totalQuizzes * 100).round();
      sections.add(
        PieChartSectionData(
          color: color,
          value: count.toDouble(),
          title: '$pct%',
          radius: 20,
          titleStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    addSection(countExcellent, const Color(0xFF10B981), 'Xuất sắc');
    addSection(countGood, const Color(0xFF3B82F6), 'Tốt');
    addSection(countOk, const Color(0xFFF59E0B), 'Khá');
    addSection(countPoor, const Color(0xFFEF4444), 'Cần cố gắng');

    if (sections.isEmpty) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFFE2E8F0),
          value: 1,
          title: '',
          radius: 20,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFF59E0B),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Điểm cao nhất",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "$bestPercent%",
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "(${best.correctCount}/${best.totalQuestions} câu · ${DateFormat('dd/MM/yyyy').format(best.createdAt)})",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF3B82F6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              boxShadow: DesignTokens.softShadow,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  "Phân bố kết quả",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  "Tỉ lệ phần trăm các mức điểm đạt được",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 50,
                          startDegreeOffset: -90,
                          sections: sections,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${_avgPercent.round()}%",
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            "Trung bình",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildLegendChip(
                      "Xuất sắc (≥90%)",
                      const Color(0xFF10B981),
                    ),
                    _buildLegendChip("Tốt (80-89%)", const Color(0xFF3B82F6)),
                    _buildLegendChip("Khá (50-79%)", const Color(0xFFF59E0B)),
                    _buildLegendChip(
                      "Cần cố gắng (<50%)",
                      const Color(0xFFEF4444),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              boxShadow: DesignTokens.softShadow,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Phân tích chi tiết",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  "Thống kê số lượng bài quiz theo từng mức điểm",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailProgressBar(
                  "Xuất sắc (≥90%)",
                  "$countExcellent bài",
                  _totalQuizzes > 0 ? countExcellent / _totalQuizzes : 0,
                  const Color(0xFF10B981),
                ),
                _buildDetailProgressBar(
                  "Tốt (80-89%)",
                  "$countGood bài",
                  _totalQuizzes > 0 ? countGood / _totalQuizzes : 0,
                  const Color(0xFF3B82F6),
                ),
                _buildDetailProgressBar(
                  "Khá (50-79%)",
                  "$countOk bài",
                  _totalQuizzes > 0 ? countOk / _totalQuizzes : 0,
                  const Color(0xFFF59E0B),
                ),
                _buildDetailProgressBar(
                  "Cần cố gắng (<50%)",
                  "$countPoor bài",
                  _totalQuizzes > 0 ? countPoor / _totalQuizzes : 0,
                  const Color(0xFFEF4444),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildQuizHistoryCard(Map<String, dynamic> item) {
    final rankColor = item["color"] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignTokens.softShadow,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: rankColor, width: 6)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["title"],
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item["score"],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item["date"],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
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
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: rankColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item["rank"],
                      style: GoogleFonts.inter(
                        color: rankColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
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

  Widget _buildLegendChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailProgressBar(
    String label,
    String trailingText,
    double progressValue,
    Color barColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              Text(
                trailingText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
