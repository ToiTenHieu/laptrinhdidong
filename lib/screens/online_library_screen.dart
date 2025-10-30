import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class OnlineLibraryScreen extends StatefulWidget {
  const OnlineLibraryScreen({super.key});

  @override
  State<OnlineLibraryScreen> createState() => _OnlineLibraryScreenState();
}

class _OnlineLibraryScreenState extends State<OnlineLibraryScreen> {
  String selectedFilter = 'All';

  // 📚 Dữ liệu mẫu
  final List<Map<String, dynamic>> books = [
    {
      "title": "Tây du ký",
      "author": "Ngô Thừa Ân",
      "image": "lib/assets/images/tayduky.jpg",
      "status": "Đang đọc",
      "currentPage": 650,
      "totalPage": 1000,
      "lastRead": "2 tiếng trước",
    },
    {
      "title": "Tôi thấy hoa vàng trên cỏ xanh",
      "author": "Nguyễn Nhật Ánh",
      "image": "lib/assets/images/hoavang.jpg",
      "status": "Đang đọc",
      "currentPage": 45,
      "totalPage": 100,
      "lastRead": "2 ngày trước",
    },
    {
      "title": "Thiên Long bát bộ",
      "author": "Kim Dung",
      "image": "lib/assets/images/thienlong.jpg",
      "status": "Hoàn thành",
      "currentPage": 388,
      "totalPage": 388,
      "lastRead": "2 tuần trước",
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredBooks = books.where((book) {
      if (selectedFilter == 'All') return true;
      if (selectedFilter == 'Reading') return book["status"] == "Đang đọc";
      if (selectedFilter == 'Completed') return book["status"] == "Hoàn thành";
      return true;
    }).toList();

    int readingCount =
        books.where((b) => b["status"] == "Đang đọc").length;
    int completedCount =
        books.where((b) => b["status"] == "Hoàn thành").length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thư viện trực tuyến"),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📊 Thống kê
            Row(
              children: [
                Expanded(
                  child: _buildStatCard("Reading", readingCount.toString(),
                      Colors.blueAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                      "Completed", completedCount.toString(), Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🟦 Bộ lọc
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ["All", "Reading", "Completed"]
                  .map((f) => _buildFilterButton(f))
                  .toList(),
            ),
            const SizedBox(height: 12),

            // 📚 Danh sách sách
            Expanded(
              child: ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  var book = filteredBooks[index];
                  double percent =
                      book["currentPage"] / book["totalPage"];
                  return _buildBookCard(book, percent);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧱 Widget con
  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book, double percent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                book["image"],
                width: 55,
                height: 75,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book["title"],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(book["author"],
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 6),

                  // Trạng thái đọc
                  Row(
                    children: [
                      Icon(
                        book["status"] == "Đang đọc"
                            ? Icons.auto_stories
                            : Icons.check_circle,
                        color: book["status"] == "Đang đọc"
                            ? Colors.blue
                            : Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        book["status"],
                        style: TextStyle(
                          color: book["status"] == "Đang đọc"
                              ? Colors.blue
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Tiến độ đọc
                  Text(
                    "Trang ${book["currentPage"]}/${book["totalPage"]}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  LinearPercentIndicator(
                    lineHeight: 6,
                    percent: percent,
                    progressColor: Colors.blueAccent,
                    backgroundColor: Colors.grey.shade200,
                    barRadius: const Radius.circular(10),
                  ),
                  const SizedBox(height: 6),

                  // Lần đọc cuối
                  Text(
                    "Lần đọc cuối cùng: ${book["lastRead"]}",
                    style:
                        const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Nút hành động
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${(percent * 100).toInt()}%",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        book["status"] == "Hoàn thành"
                            ? Colors.green
                            : Colors.blueAccent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(
                    book["status"] == "Hoàn thành"
                        ? Icons.book
                        : Icons.play_arrow,
                    size: 16,
                  ),
                  label: Text(
                    book["status"] == "Hoàn thành" ? "Đọc" : "Tiếp tục",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
