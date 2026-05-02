import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detail_page.dart'; 

class MyPostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("내가 쓴 글"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('writerUid', isEqualTo: user?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("❌ Firestore 에러 발생: ${snapshot.error}");
            return Center(child: Text("목록을 불러오는 중 오류가 발생했습니다."));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text("아직 작성한 글이 없습니다."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var post = docs[index].data() as Map<String, dynamic>;
              String docId = docs[index].id;
              
              bool isDone = post['isDone'] ?? false;
              bool isSettled = post['isSettled'] ?? false;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    docId, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("${post['martName']} | ${post['itemName']}"),
                  ),
                  trailing: _buildStatusBadge(isDone, isSettled),
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => DetailPage(post: post, title: docId)
                      )
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✨ 상태 배지 디자인
  Widget _buildStatusBadge(bool isDone, bool isSettled) {
    String label;
    Color bgColor;
    Color textColor;

    if (isSettled) {
      label = "최종 완료";
      bgColor = Colors.grey[200]!;
      textColor = Colors.grey[600]!;
    } else if (isDone) {
      label = "정산 중";
      bgColor = Colors.green[50]!;
      textColor = Colors.green[700]!;
    } else {
      label = "모집 중";
      bgColor = Colors.blue[50]!;
      textColor = Colors.blue[700]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}