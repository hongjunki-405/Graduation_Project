import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: false),
      home: LoginPage(),
    ));

// 전역 변수 데이터
List<Map<String, dynamic>> allPosts = [
  {"title": "쪽문 근처 삼겹살 소분", "lat": 37.2945, "lon": 126.9750, "price": "10,000", "content": "자취방 근처에서 나눠요!", "temp": 37.5},
  {"title": "복사 용지 한 박스 나눔", "lat": 37.2930, "lon": 126.9740, "price": "2,000", "content": "공학관에서 거래 가능합니다.", "temp": 36.5},
];

// 1. 로그인 페이지 
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("나눔의 즐거움, 소분", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange)),
            SizedBox(height: 50),
            TextField(decoration: InputDecoration(labelText: "이메일", border: OutlineInputBorder())),
            SizedBox(height: 10),
            TextField(obscureText: true, decoration: InputDecoration(labelText: "비밀번호", border: OutlineInputBorder())),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavigationPage())),
              child: Text("로그인"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. 하단 탭 네비게이션 (홈 / 내 정보 전환) 
class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [MainBoardPage(), MyProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
        ],
      ),
    );
  }
}

// 3. 메인 게시판 페이지 
class MainBoardPage extends StatefulWidget {
  @override
  _MainBoardPageState createState() => _MainBoardPageState();
}

class _MainBoardPageState extends State<MainBoardPage> {
  final double myLat = 37.2935; 
  final double myLon = 126.9748;

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    final nearPosts = allPosts.where((post) => calculateDistance(myLat, myLon, post['lat'], post['lon']) <= 1.0).toList();

    return Scaffold(
      appBar: AppBar(title: Text("내 주변 소분 매물")),
      body: ListView.builder(
        itemCount: nearPosts.length,
        itemBuilder: (context, index) {
          double dist = calculateDistance(myLat, myLon, nearPosts[index]['lat'], nearPosts[index]['lon']);
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.orange),
              title: Text(nearPosts[index]['title']),
              subtitle: Text("${(dist * 1000).toInt()}m 거리 | 신뢰도 ${nearPosts[index]['temp']}°C"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(post: nearPosts[index], distance: dist))),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => WritePage()));
          setState(() {}); 
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

// 4. 내 정보 보기 (MyPage)
class MyProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("내 정보")),
      body: Column(
        children: [
          SizedBox(height: 30),
          Center(child: CircleAvatar(radius: 50, backgroundColor: Colors.orange[100], child: Icon(Icons.person, size: 50, color: Colors.orange))),
          SizedBox(height: 15),
          Text("준기님", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("서울시 중구 태평로1가", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.thermostat, color: Colors.orange),
                title: Text("나의 매너 온도"),
                trailing: Text("37.5°C", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
              ),
            ),
          ),
          ListTile(leading: Icon(Icons.history), title: Text("거래 내역"), trailing: Icon(Icons.chevron_right)),
          ListTile(leading: Icon(Icons.favorite_border), title: Text("관심 목록"), trailing: Icon(Icons.chevron_right)),
          ListTile(leading: Icon(Icons.settings), title: Text("설정"), trailing: Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}

// 5. 글쓰기 페이지
class WritePage extends StatelessWidget {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("소분 모집하기")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "글 제목")),
            TextField(controller: priceController, decoration: InputDecoration(labelText: "총 가격", suffixText: "원")),
            TextField(controller: contentController, decoration: InputDecoration(labelText: "상세 내용"), maxLines: 3),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                allPosts.add({
                  "title": titleController.text,
                  "lat": 37.2938, // 자과캠 내 다른 건물 좌표 (약 35~40m 거리)
                  "lon": 126.9751,
                  "price": priceController.text,
                  "content": contentController.text,
                  "temp": 36.5
                });
                Navigator.pop(context);
              },
              child: Text("작성 완료"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }
}

// 6. 상세 페이지
class DetailPage extends StatelessWidget {
  final Map<String, dynamic> post;
  final double distance;
  DetailPage({required this.post, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("상세 보기")),
      body: Column(
        children: [
          Container(height: 150, color: Colors.grey[200], child: Center(child: Icon(Icons.image, size: 50))),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post['title'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text("${(distance * 1000).toInt()}m 근처 | 모집자 신뢰도 ${post['temp']}°C", style: TextStyle(color: Colors.orange)),
                Divider(height: 30),
                Text("예상 가격: ${post['price']}원", style: TextStyle(fontSize: 18, color: Colors.blue)),
                SizedBox(height: 10),
                Text(post['content']),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {}, 
                  child: Text("카카오톡 오픈채팅으로 연락하기"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700], foregroundColor: Colors.black, minimumSize: Size(double.infinity, 55)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}