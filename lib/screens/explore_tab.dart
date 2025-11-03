import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_detail_screen.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('books').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("📚 Chưa có sách nào trong thư viện."),
          );
        }

        final books = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Hiển thị tổng số sách
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "📖 Tổng số sách trong thư viện: ${books.length}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueAccent,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final data = books[index].data() as Map<String, dynamic>;

                  final title = data['title'] ?? 'Không tên';
                  final author = data['author'] ?? 'Không rõ';
                  final tag = data['tag'] ?? '';
                  final image = data['image'] ?? '';
                  final description = data['description'] ?? '';
                  final quantity = data['quantity'] ?? 0; // ✅ số lượng sách

                  ImageProvider imageProvider;
                  if (image.startsWith('http')) {
                    imageProvider = NetworkImage(image);
                  } else {
                    imageProvider = AssetImage(image);
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailScreen(
                            title: title,
                            author: author,
                            tag: tag,
                            imagePath: image,
                            description: description,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Ảnh bìa sách
                          Container(
                            width: 55,
                            height: 75,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Thông tin sách
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  author,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description.isNotEmpty
                                      ? description
                                      : "Chưa có mô tả",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black45,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Số lượng: $quantity cuốn",
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Tag (nếu có)
                          if (tag.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: tag == "Mới"
                                    ? Colors.blue[100]
                                    : Colors.red[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: tag == "Mới"
                                      ? Colors.blue
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
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
          ],
        );
      },
    );
  }
}
