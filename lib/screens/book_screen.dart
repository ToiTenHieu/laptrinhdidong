import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'cloudinary_service.dart';
import '../widgets/bottom_nav.dart';
class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final CollectionReference booksRef =
      FirebaseFirestore.instance.collection('books');

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _showBookDialog({DocumentSnapshot? book}) {
    final titleController = TextEditingController(text: book?['title'] ?? '');
    final authorController = TextEditingController(text: book?['author'] ?? '');
    final tagController = TextEditingController(text: book?['tag'] ?? '');
    final descriptionController =
        TextEditingController(text: book?['description'] ?? '');
    final priceController = TextEditingController(text: book?['price'] ?? '');
    final ratingController = TextEditingController(text: book?['rating'] ?? '');
    String imageUrl = book?['image'] ?? '';

    _selectedImage = null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            ImageProvider imageProvider;
            if (_selectedImage != null) {
              imageProvider = FileImage(_selectedImage!);
            } else if (imageUrl.startsWith('http')) {
              imageProvider = NetworkImage(imageUrl);
            } else if (imageUrl.isNotEmpty) {
              imageProvider = AssetImage(imageUrl);
            } else {
              imageProvider =
                  const AssetImage('assets/images/no_image.png');
            }

            return AlertDialog(
              title: Text(book == null ? "Thêm sách mới" : "Chỉnh sửa sách"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picked =
                            await _picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setStateDialog(() {
                            _selectedImage = File(picked.path);
                          });
                        }
                      },
                      child: Container(
                        width: 120,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          color: Colors.grey[300],
                        ),
                        child: (_selectedImage == null && imageUrl.isEmpty)
                            ? const Icon(Icons.add_a_photo,
                                size: 40, color: Colors.black54)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: "Tên sách")),
                    TextField(
                        controller: authorController,
                        decoration: const InputDecoration(labelText: "Tác giả")),
                    TextField(
                        controller: tagController,
                        decoration: const InputDecoration(labelText: "Thẻ (tag)")),
                    TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: "Giá")),
                    TextField(
                        controller: ratingController,
                        decoration: const InputDecoration(labelText: "Đánh giá")),
                    TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: "Mô tả")),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Hủy"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text(book == null ? "Thêm" : "Lưu"),
                  onPressed: () async {
                    String finalImageUrl = imageUrl;

                    // ✅ Nếu có chọn ảnh mới, upload Cloudinary
                    if (_selectedImage != null) {
                      final uploadedUrl =
                          await CloudinaryService.uploadImage(_selectedImage!);
                      if (uploadedUrl != null) {
                        finalImageUrl = uploadedUrl;
                      }
                    }

                    final data = {
                      "title": titleController.text.trim(),
                      "author": authorController.text.trim(),
                      "tag": tagController.text.trim(),
                      "image": finalImageUrl,
                      "description": descriptionController.text.trim(),
                      "price": priceController.text.trim(),
                      "rating": ratingController.text.trim(),
                    };

                    if (book == null) {
                      await booksRef.add(data);
                    } else {
                      await booksRef.doc(book.id).update(data);
                    }

                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteBook(DocumentSnapshot book) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa '${book['title']}' không?"),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Xóa"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await booksRef.doc(book.id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: const Text("Quản lý sách (Cloudinary)",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: booksRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Chưa có sách nào trong thư viện."));
          }

          final books = snapshot.data!.docs;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final data = book.data() as Map<String, dynamic>;

              final title = data['title'] ?? 'Không tên';
              final author = data['author'] ?? 'Không rõ';
              final image = data['image'] ?? '';
              final tag = data['tag'] ?? '';

              ImageProvider imageProvider;
              if (image.startsWith('http')) {
                imageProvider = NetworkImage(image);
              } else if (image.isNotEmpty) {
                imageProvider = AssetImage(image);
              } else {
                imageProvider =
                    const AssetImage('assets/images/no_image.png');
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image(
                      image: imageProvider,
                      width: 50,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text("Tác giả: $author"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _showBookDialog(book: book),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBook(book),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBookDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: buildBottomNav(context, 1),
    );
  }
}
