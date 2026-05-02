import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'detail_page.dart';
import 'write_page.dart';

class MainBoardPage extends StatefulWidget {
  @override
  _MainBoardPageState createState() => _MainBoardPageState();
}

class _MainBoardPageState extends State<MainBoardPage> {
  // 기준 위치 (기본: 성균관대역 인근)
  double myLat = 37.2935;
  double myLon = 126.9748;

  // 거리 계산 함수 (Haversine 공식)
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p) / 2 +
            cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("내 주변 소분 매물", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              setState(() {
                if ((myLat - 37.2935).abs() < 0.001) {
                  myLat = 37.2660; // 수원역
                  myLon = 127.0000;
                } else {
                  myLat = 37.2935; // 성대역
                  myLon = 126.9748;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("기준 위치가 변경되었습니다."), duration: Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("등록된 매물이 없습니다."));
          }

          final nearPosts = snapshot.data!.docs.where((doc) {
            var post = doc.data() as Map<String, dynamic>;
            double lat = (post['latitude'] ?? 0.0).toDouble();
            double lon = (post['longitude'] ?? 0.0).toDouble();
            
            double dist = calculateDistance(myLat, myLon, lat, lon);
            return dist <= 50.0; 
          }).toList();

          if (nearPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 80, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text("주변 10km 이내에 매물이 없어요.\n상단 지도 아이콘을 눌러 위치를 전환해 보세요."),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              itemCount: nearPosts.length,
              itemBuilder: (context, index) {
                var doc = nearPosts[index];
                var post = doc.data() as Map<String, dynamic>;
                String title = doc.id;
                double lat = (post['latitude'] ?? 0.0).toDouble();
                double lon = (post['longitude'] ?? 0.0).toDouble();
                double dist = calculateDistance(myLat, myLon, lat, lon);

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[50],
                      child: Icon(Icons.location_on, color: Colors.orange[800]),
                    ),
                    title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${post['martName']} | ${dist.toStringAsFixed(1)}km 거리"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(post: post, title: title, distance: dist)
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WritePage())),
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}