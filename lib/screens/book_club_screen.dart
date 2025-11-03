import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookClubsScreen extends StatefulWidget {
  const BookClubsScreen({super.key});

  @override
  State<BookClubsScreen> createState() => _BookClubsScreenState();
}

class _BookClubsScreenState extends State<BookClubsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Tham gia câu lạc bộ
  Future<void> _joinClub(String clubId) async {
    final uid = _auth.currentUser!.uid;
    final clubRef = _firestore.collection('book_clubs').doc(clubId);

    await clubRef.update({
      'members': FieldValue.arrayUnion([uid]),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("✅ Tham gia câu lạc bộ thành công!")));
  }

  // Tạo câu lạc bộ mới
  Future<void> _createClub() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tạo câu lạc bộ mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên CLB")),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Mô tả CLB")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              final uid = _auth.currentUser!.uid;
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              if (name.isEmpty || desc.isEmpty) return;

              await _firestore.collection('book_clubs').add({
                'name': name,
                'description': desc,
                'members': [uid],
                'createdBy': uid,
                'roleByUser': {uid: "Quản trị viên"}, // người tạo mặc định là Admin
                'createdAt': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("✅ Tạo câu lạc bộ thành công!")));
            },
            child: const Text("Tạo"),
          ),
        ],
      ),
    );
  }

  // Chọn màu cho CLB dựa trên index hoặc UID
  Color _getColor(String clubId) {
    final colors = [Colors.blue, Colors.purple, Colors.green, Colors.pink, Colors.orange];
    final hash = clubId.hashCode;
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Câu lạc bộ sách")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _createClub,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("+ Tham gia/Tạo câu lạc bộ",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('book_clubs')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Chưa có câu lạc bộ nào."));
                }

                final clubs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: clubs.length,
                  itemBuilder: (context, index) {
                    final club = clubs[index];
                    final clubId = club.id;
                    final members = List<String>.from(club['members'] ?? []);
                    final uid = _auth.currentUser!.uid;
                    final isMember = members.contains(uid);

                    // Lấy role của user trong CLB
                    final roleByUser = Map<String, dynamic>.from(club['roleByUser'] ?? {});
                    final role = roleByUser[uid] ?? "Thành viên";

                    Color roleColor;
                    switch (role) {
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
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _getColor(clubId),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(club['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  club['description'],
                                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.people, size: 16, color: Colors.black54),
                                    const SizedBox(width: 4),
                                    Text("${members.length} Thành viên",
                                        style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: roleColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        role,
                                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: isMember ? null : () => _joinClub(clubId),
                                      child: Text(isMember ? "Đã tham gia" : "Tham gia"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
