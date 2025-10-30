import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// Màn hình hiển thị danh sách sách mà người dùng đã mượn
class BorrowedBooksTab extends StatelessWidget {
  const BorrowedBooksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Nếu người dùng chưa đăng nhập
    if (user == null) {
      return const Center(
        child: Text(
          "Vui lòng đăng nhập để xem danh sách mượn.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    // Stream dữ liệu sách mượn của người dùng hiện tại
    final borrowedBooksStream = FirebaseFirestore.instance
        .collection('borrowed_books')
        .where('user_id', isEqualTo: user.uid)
        .orderBy('borrow_date', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: borrowedBooksStream,
      builder: (context, snapshot) {
        // Đang tải dữ liệu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Không có dữ liệu
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Bạn chưa mượn quyển sách nào.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        final books = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final data = books[index].data() as Map<String, dynamic>;

            // Đọc dữ liệu an toàn
            final title = data['book_title']?.toString() ?? "Không có tên";
            final author = data['book_author']?.toString() ?? "Không rõ tác giả";
            final imageUrl = data['book_image']?.toString() ?? '';
            final description = data['description']?.toString() ?? "Chưa có mô tả";
            final status = data['status']?.toString() ?? "đang mượn";

            final borrowDate = (data['borrow_date'] is Timestamp)
                ? (data['borrow_date'] as Timestamp).toDate()
                : null;
            final dueDate = (data['due_date'] is Timestamp)
                ? (data['due_date'] as Timestamp).toDate()
                : null;

            final formattedBorrow = borrowDate != null
                ? DateFormat('dd/MM/yyyy').format(borrowDate)
                : 'Không rõ';
            final formattedDue = dueDate != null
                ? DateFormat('dd/MM/yyyy').format(dueDate)
                : 'Không rõ';

            return _buildBorrowedBookCard(
              title: title,
              author: author,
              imageUrl: imageUrl,
              description: description,
              borrowDate: formattedBorrow,
              dueDate: formattedDue,
              status: status,
            );
          },
        );
      },
    );
  }

  /// Widget hiển thị từng sách trong danh sách mượn
  Widget _buildBorrowedBookCard({
    required String title,
    required String author,
    required String imageUrl,
    required String description,
    required String borrowDate,
    required String dueDate,
    required String status,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookImage(imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Ngày mượn: $borrowDate",
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  Text(
                    "Hạn trả: $dueDate",
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Trạng thái: $status",
                    style: TextStyle(
                      color: status == "đang mượn"
                          ? Colors.blueAccent
                          : Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
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

  /// Widget hiển thị ảnh bìa sách hoặc icon mặc định
  Widget _buildBookImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          image: imageUrl.startsWith('http')
              ? NetworkImage(imageUrl)
              : AssetImage(imageUrl) as ImageProvider,
          width: 55,
          height: 75,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const Icon(
        Icons.book,
        size: 55,
        color: Colors.grey,
      );
    }
  }
}
