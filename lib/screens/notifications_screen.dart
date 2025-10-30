import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MonthSection(
              month: 'Tháng 10, 2025',
              notifications: [
                _NotificationItem(
                  icon: Iconsax.calendar_1,
                  iconColor: Colors.redAccent,
                  title: 'Lời nhắc trả sách',
                  description: "Bạn còn 2 ngày để trả lại 'Việt Nam sử lược'",
                  book: 'Việt Nam sử lược',
                  date: '31-10',
                ),
                _NotificationItem(
                  icon: Iconsax.star,
                  iconColor: Colors.amber,
                  title: 'Đánh giá',
                  description: 'Nguyễn Đăng Hiếu đã thích đánh giá của bạn',
                  book: 'Tôi thấy hoa vàng trên cỏ xanh',
                  date: '29-10',
                ),
                _NotificationItem(
                  icon: Iconsax.activity,
                  iconColor: Colors.purpleAccent,
                  title: 'Hoạt động câu lạc bộ sách',
                  description:
                      'Quản trị viên đã thêm một hoạt động mới bắt đầu từ ngày 25 tháng 10.',
                  date: '20-10',
                ),
                _NotificationItem(
                  icon: Iconsax.warning_2,
                  iconColor: Colors.red,
                  title: 'Cảnh báo quá hạn',
                  description: 'Bạn đã quá hạn trả lại 2 ngày',
                  book: 'Pride and Prejudice',
                  date: '15-10',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MonthSection(
              month: 'Tháng 9, 2025',
              notifications: [
                _NotificationItem(
                  icon: Iconsax.book,
                  iconColor: Colors.deepPurple,
                  title: 'Đã có bản phát hành mới',
                  description:
                      'Một cuốn sách mới của F. Scott Fitzgerald hiện đã có sẵn',
                  book: 'The Beautiful and Damned',
                  date: '30-9',
                ),
                _NotificationItem(
                  icon: Iconsax.tick_circle,
                  iconColor: Colors.green,
                  title: 'Trả sách',
                  description: "Bạn đã trả sách 'Thần điêu đại hiệp'",
                  book: 'Thần điêu đại hiệp',
                  date: '22-9',
                ),
                _NotificationItem(
                  icon: Iconsax.people,
                  iconColor: Colors.purple,
                  title: 'Yêu cầu tham gia câu lạc bộ',
                  description: 'Có 1 lời yêu cầu tham gia câu lạc bộ của bạn',
                  date: '20-9',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Section hiển thị theo tháng
class _MonthSection extends StatelessWidget {
  final String month;
  final List<_NotificationItem> notifications;

  const _MonthSection({required this.month, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Iconsax.calendar_1, color: Colors.deepPurple, size: 18),
            const SizedBox(width: 6),
            Text(
              month,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...notifications,
      ],
    );
  }
}

// Item thông báo
class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String? book;
  final String date;

  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.book,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          // Nội dung
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
                if (book != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Iconsax.book, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          book!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          // Nút xóa
          IconButton(
            icon: const Icon(Iconsax.trash, size: 18, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
