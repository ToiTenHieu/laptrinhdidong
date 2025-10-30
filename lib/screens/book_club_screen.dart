import 'package:flutter/material.dart';

class BookClubsScreen extends StatelessWidget {
  const BookClubsScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> clubs = const [
    {
      "name": "Hội văn học cổ điển",
      "description":
          "Khám phá những tác phẩm kinh điển vượt thời gian và thảo luận về những kiệt tác văn học",
      "members": 24,
      "role": "Thành viên",
      "color": Colors.blue,
    },
    {
      "name": "Người hâm mộ thể loại bí ẩn và ly kỳ",
      "description": "Thảo luận về những câu chuyện hồi hộp và những tình tiết bất ngờ",
      "members": 18,
      "role": "Quản trị viên",
      "color": Colors.purple,
    },
    {
      "name": "Những người đam mê khoa học viễn tưởng",
      "description": "Khám phá thế giới tương lai và những khái niệm khó hiểu",
      "members": 31,
      "role": "Người điều hành",
      "color": Colors.green,
    },
    {
      "name": "Câu lạc bộ tiểu thuyết đương đại",
      "description": "Khám phá những câu chuyện hiện đại và tác giả đương đại",
      "members": 15,
      "role": "Thành viên",
      "color": Colors.pink,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Câu lạc bộ sách",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "+ Tham gia/Tạo câu lạc bộ",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: clubs.length,
                itemBuilder: (context, index) {
                  final club = clubs[index];
                  return _buildClubCard(club);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubCard(Map<String, dynamic> club) {
    Color roleColor;
    switch (club["role"]) {
      case "Quản trị viên":
        roleColor = Colors.red[200]!;
        break;
      case "Người điều hành":
        roleColor = Colors.orange[200]!;
        break;
      default:
        roleColor = Colors.blue[200]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: club["color"],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(club["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  club["description"],
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text("${club["members"]} Thành viên",
                        style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        club["role"],
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
