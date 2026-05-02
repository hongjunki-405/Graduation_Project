import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_posts_page.dart'; 

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("마이페이지"), centerTitle: true),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.orange[100],
                  child: Icon(Icons.person, size: 40, color: Colors.orange),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("안녕하세요,", style: TextStyle(fontSize: 14)),
                    Text(user?.email ?? "사용자", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Divider(thickness: 8, color: Colors.grey[100]),

          _buildMenuTile(
            context, 
            icon: Icons.list_alt, 
            title: "내가 쓴 글 관리", 
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyPostsPage()));
            }
          ),
          _buildMenuTile(
            context, 
            icon: Icons.logout, 
            title: "로그아웃", 
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            }
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}