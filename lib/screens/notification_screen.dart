import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart'; // Bạn có thể dùng package này để format thời gian đẹp hơn
import 'event_detail_screen.dart'; // Import trang chi tiết sự kiện của bạn

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;
    final String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Thông báo")),
        body: const Center(child: Text("Vui lòng đăng nhập để xem thông báo.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông báo"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 1. Truy vấn collection 'notifications'
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: currentUserId) // 2. Lọc theo ID người dùng
            .orderBy('createdAt', descending: true) // 3. Sắp xếp mới nhất lên trên
            .limit(50) // Giới hạn 50 thông báo gần nhất
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Có lỗi xảy ra khi tải thông báo."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Bạn chưa có thông báo nào."),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;

              // Đánh dấu đã đọc/chưa đọc
              final bool isRead = data['read'] ?? false;

              // Hiển thị thông báo
              return _buildNotificationTile(context, doc.id, data, isRead);
            },
          );
        },
      ),
    );
  }

  // Widget con để hiển thị từng thông báo
  Widget _buildNotificationTile(BuildContext context, String docId, Map<String, dynamic> data, bool isRead) {
    final theme = Theme.of(context);

    // Lấy thông tin cơ bản
    final String title = data['title'] ?? 'Thông báo';
    final String body = data['body'] ?? 'Bạn có thông báo mới.';
    final String type = data['type'] ?? '';
    final Timestamp? timestamp = data['createdAt'] as Timestamp?;

    // Format thời gian (ví dụ đơn giản)
    String timeAgo = "Vừa xong";
    if (timestamp != null) {
      final difference = DateTime.now().difference(timestamp.toDate().toLocal());
      if (difference.inDays > 1) {
        timeAgo = "${difference.inDays} ngày trước";
      } else if (difference.inHours > 0) {
        timeAgo = "${difference.inHours} giờ trước";
      } else if (difference.inMinutes > 0) {
        timeAgo = "${difference.inMinutes} phút trước";
      }
    }

    // Chọn icon và màu dựa trên 'type'
    IconData iconData;
    Color iconColor;
    switch (type) {
      case 'CLUB_EVENT':
        iconData = Icons.event_note_rounded;
        iconColor = theme.colorScheme.primary;
        break;
      case 'BOOK_DUE': // Thông báo nhắc hạn
        iconData = Icons.timer_off_outlined;
        iconColor = theme.colorScheme.error;
        break;
      case 'BOOK_BORROW': // Thông báo mượn sách
        iconData = Icons.book_outlined;
        iconColor = Colors.green;
        break;
      case 'BOOK_RETURN': // Thông báo trả sách
        iconData = Icons.check_circle_outline;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.notifications_none_outlined;
        iconColor = Colors.orange;
    }

    return Container(
      // Làm nổi bật thông báo chưa đọc
      color: isRead ? Colors.transparent : theme.colorScheme.primary.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        title: Text(title, style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold
        )),
        subtitle: Text(body),
        trailing: Text(timeAgo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        onTap: () {
          // 1. Đánh dấu đã đọc
          _markAsRead(docId);

          // 2. Điều hướng (nếu có)
          _handleNotificationTap(context, data);
        },
      ),
    );
  }

  // Hàm đánh dấu đã đọc
  void _markAsRead(String docId) {
    FirebaseFirestore.instance.collection('notifications').doc(docId).update({
      'read': true,
    });
  }

  // Hàm xử lý khi nhấn vào thông báo
  void _handleNotificationTap(BuildContext context, Map<String, dynamic> data) {
    final String type = data['type'] ?? '';

    // Ví dụ: Điều hướng đến trang chi tiết sự kiện
    if (type == 'CLUB_EVENT') {
      final String? clubId = data['clubId'];
      final String? eventId = data['eventId'];

      if (clubId != null && eventId != null) {
        // (Bạn cần import 'event_detail_screen.dart' ở đầu file này)
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => EventDetailScreen(
        //       clubId: clubId,
        //       eventId: eventId,
        //     ),
        //   ),
        // );
        print("Điều hướng đến Event $eventId của Club $clubId");
      }
    }
    // Tương tự, bạn có thể thêm logic cho 'BOOK_DUE', 'BOOK_BORROW'
    // else if (type == 'BOOK_BORROW') {
    //   final String? bookId = data['relatedId']; // Giả sử bạn lưu ID sách
    //   if (bookId != null) {
    //     // Điều hướng đến trang chi tiết sách
    //   }
    // }
  }
}