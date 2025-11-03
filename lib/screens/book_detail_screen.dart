import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookDetailScreen extends StatefulWidget {
  final String title;
  final String author;
  final String tag;
  final String imagePath;
  final String? description;

  const BookDetailScreen({
    super.key,
    required this.title,
    required this.author,
    required this.tag,
    required this.imagePath,
    this.description,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool isFavorite = false;
  String? favoriteDocId;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("favorites")
        .where("book_title", isEqualTo: widget.title)
        .where("user_id", isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        isFavorite = true;
        favoriteDocId = snapshot.docs.first.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = widget.imagePath.startsWith("http")
        ? NetworkImage(widget.imagePath)
        : AssetImage(widget.imagePath) as ImageProvider;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title:
            const Text("Chi tiết sách", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image(
                    image: imageProvider,
                    width: 110,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(widget.author,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black54)),
                      const SizedBox(height: 8),
                      const Text("✅ Có sẵn",
                          style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.redAccent : Colors.black45,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text("Mô tả",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              widget.description ?? "Chưa có mô tả cho quyển sách này!",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _borrow(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Mượn ngay",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showReviewDialog(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline,
                        color: Colors.black87),
                    label: const Text("Đánh giá",
                        style: TextStyle(color: Colors.black87)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _reviewList(),
          ],
        ),
      ),
    );
  }

  /// ❤️ Thêm / xóa yêu thích
  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack("Vui lòng đăng nhập để thêm vào yêu thích!");
      return;
    }

    final favorites = FirebaseFirestore.instance.collection("favorites");

    if (isFavorite && favoriteDocId != null) {
      await favorites.doc(favoriteDocId).delete();
      setState(() => isFavorite = false);
      _snack("❌ Đã xóa khỏi yêu thích");
    } else {
      final doc = await favorites.add({
        "book_title": widget.title,
        "book_author": widget.author,
        "book_image": widget.imagePath,
        "user_id": user.uid,
        "created_at": Timestamp.now(),
      });
      setState(() {
        isFavorite = true;
        favoriteDocId = doc.id;
      });
      _snack("💖 Đã thêm vào yêu thích!");
    }
  }

  /// ✅ Mượn sách (1 người chỉ được mượn 1 bản của cùng sách)
  Future<void> _borrow(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack("Vui lòng đăng nhập để mượn sách!");
      return;
    }

    final borrowedBooks = FirebaseFirestore.instance.collection("borrowed_books");
    final userId = user.uid;

    // 🔹 1. Kiểm tra xem user đã mượn quyển này mà chưa trả chưa
    final existingBorrow = await borrowedBooks
        .where("user_id", isEqualTo: userId)
        .where("book_title", isEqualTo: widget.title)
        .where("status", whereIn: ["đang mượn", "pending"])
        .get();

    if (existingBorrow.docs.isNotEmpty) {
      _snack("❌ Bạn đã mượn quyển này rồi, vui lòng trả trước khi mượn lại!");
      return;
    }

    // 🔹 2. Kiểm tra số lượng sách còn không
    final booksRef = FirebaseFirestore.instance.collection("books");
    final bookSnapshot = await booksRef.where("title", isEqualTo: widget.title).limit(1).get();

    if (bookSnapshot.docs.isEmpty) {
      _snack("Không tìm thấy thông tin sách trong hệ thống!");
      return;
    }

    final bookDoc = bookSnapshot.docs.first;
    final currentQuantity = (bookDoc["quantity"] ?? 0) as int;

    if (currentQuantity <= 0) {
      _snack("📚 Sách đã hết, không thể mượn!");
      return;
    }

    // 🔹 3. Giảm số lượng sách đi 1
    await booksRef.doc(bookDoc.id).update({"quantity": currentQuantity - 1});

    // 🔹 4. Tạo phiếu mượn mới
    await borrowedBooks.add({
      "book_title": widget.title,
      "book_author": widget.author,
      "book_image": widget.imagePath,
      "borrow_date": Timestamp.now(),
      "due_date": Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      "status": "đang mượn",
      "user_id": user.uid,
    });

    _snack("✅ Mượn thành công!");
  }

  /// 📋 Danh sách đánh giá
  Widget _reviewList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("reviews")
          .where("book_title", isEqualTo: widget.title)
          .orderBy("created_at", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final reviews = snapshot.data!.docs;
        if (reviews.isEmpty) {
          return const Text("📭 Chưa có đánh giá nào");
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: reviews.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _reviewItem(
              username: data["username"] ?? "Người dùng",
              comment: data["comment"] ?? "Không có nội dung",
              rating: (data["rating"] ?? 0).toDouble(),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _reviewItem({
    required String username,
    required String comment,
    required double rating,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(username,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(comment,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    final commentCtrl = TextEditingController();
    double rating = 5;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đánh giá sách"),
        content: StatefulBuilder(
          builder: (context, setSB) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    onPressed: () => setSB(() => rating = i + 1.0),
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: "Nhập cảm nhận của bạn..."),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveReview(rating, commentCtrl.text);
              Navigator.pop(context);
            },
            child: const Text("Gửi"),
          )
        ],
      ),
    );
  }

  Future<void> _saveReview(double rating, String comment) async {
    if (comment.trim().isEmpty) {
      _snack("Hãy nhập nội dung trước khi gửi!");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection("reviews").add({
      "book_title": widget.title,
      "rating": rating,
      "comment": comment,
      "created_at": Timestamp.now(),
      "user_id": user?.uid,
      "username": user?.displayName ?? user?.email ?? "Người dùng",
    });

    _snack("✅ Gửi đánh giá thành công!");
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
