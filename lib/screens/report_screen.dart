import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _confirmReturn(String docId) async {
    try {
    await _firestore.collection('borrowed_books').doc(docId).update({
      'status': 'đã trả',
    });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Đã xác nhận trả sách")),
      );
    } catch (e) {
      print("❌ Lỗi khi cập nhật trạng thái: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi khi cập nhật: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;
    print("🟢 UID hiện tại: $userId");

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Phiếu mượn của tôi"),
        backgroundColor: Colors.blue[600],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('borrowed_books')
            .orderBy('borrow_date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Debug log để xem trạng thái stream
          print("📡 Kết nối: ${snapshot.connectionState}");
          if (snapshot.hasError) {
            print("❌ Lỗi Firestore: ${snapshot.error}");
            return Center(
              child: Text("Lỗi Firestore: ${snapshot.error}"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Không có dữ liệu
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print("📭 Không có phiếu mượn nào trong Firestore cho user $userId");
            return const Center(
              child: Text(
                "📭 Bạn chưa có phiếu mượn nào",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final tickets = snapshot.data!.docs;
          print("✅ Tổng số phiếu mượn: ${tickets.length}");

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final data = tickets[index].data() as Map<String, dynamic>;
              print("📘 Dữ liệu phiếu $index: $data");

              final title = data['book_title'] ?? 'Không rõ';
              final author = data['book_author'] ?? 'Không rõ';
              final status = data['status'] ?? 'đang mượn';

              DateTime? borrowDate;
              DateTime? dueDate;
              try {
                borrowDate = (data['borrow_date'] as Timestamp).toDate();
                dueDate = (data['due_date'] as Timestamp).toDate();
              } catch (e) {
                print("⚠️ Lỗi chuyển đổi ngày: $e");
              }

              final image = data['book_image'];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: image != null && image.toString().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image,
                            width: 55,
                            height: 75,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, __) {
                              print("⚠️ Lỗi load ảnh: $image");
                              return const Icon(Icons.book,
                                  color: Colors.blue);
                            },
                          ),
                        )
                      : const Icon(Icons.book, color: Colors.blue),
                  title: Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "Tác giả: $author\n"
                      "📅 ${borrowDate != null ? _formatDate(borrowDate) : '?'} → ${dueDate != null ? _formatDate(dueDate) : '?'}\n"
                      "Trạng thái: ${status.toUpperCase()}",
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                  trailing: status == 'đang mượn'
                      ? ElevatedButton(
                          onPressed: () =>
                              _confirmReturn(tickets[index].id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Xác nhận\ntrả",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      : const Icon(Icons.check_circle,
                          color: Colors.grey, size: 28),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: buildBottomNav(context, 2),
    );
  }
}
