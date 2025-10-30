import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trang quản trị")),
      body: const Center(
        child: Text("Xin chào, bạn đang đăng nhập với quyền ADMIN 👑"),
      ),
    );
  }
}
