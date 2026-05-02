import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final String title;
  final double? distance;

  DetailPage({required this.post, required this.title, this.distance});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // 품목 입력을 위한 컨트롤러
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemWeightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').doc(widget.title).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        var livePost = snapshot.data!.data() as Map<String, dynamic>;
        bool isDone = livePost['isDone'] ?? false;         // 모집 완료 여부
        bool isSettled = livePost['isSettled'] ?? false;   // 정산 완료 여부
        bool isWriter = currentUser?.uid == livePost['writerUid'];
        int people = livePost['personCount'] ?? 1;
        List<dynamic> savedItems = livePost['settlementItems'] ?? [];

        return Scaffold(
          appBar: AppBar(title: Text(isSettled ? "거래 완료" : (isDone ? "실시간 정산" : "모집 상세")), centerTitle: true),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildStatusHeader(isDone, isSettled),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildParticipantInfo(people), // 참여 인원 배지
                      SizedBox(height: 10),
                      Text(widget.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Divider(height: 30),

                      // 1인당 상세 분담 결과 카드
                      _buildSummaryCard(savedItems, people), 
              
                      SizedBox(height: 25),
                      Text("🛒 전체 구매 품목", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildItemList(savedItems),

                      // 작성자이면서 정산 중일 때만 입력 폼 노출
                      if (isWriter && isDone && !isSettled) _buildAddItemForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomAction(isWriter, isDone, isSettled, livePost['kakaoLink']),
        );
      },
    );
  }

  // 1. 상태 헤더
  Widget _buildStatusHeader(bool isDone, bool isSettled) {
    Color bgColor = Colors.blue[600]!;
    String statusText = "👥 장보기 메이트 모집 중입니다.";

    if (isSettled) {
      bgColor = Colors.grey[700]!;
      statusText = "🏁 거래 및 정산이 모두 완료되었습니다.";
    } else if (isDone) {
      bgColor = Colors.green[600]!;
      statusText = "✅ 장보기 완료! 실시간 정산 중입니다.";
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12),
      color: bgColor,
      child: Center(child: Text(statusText, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }

  // 2. 참여 인원 정보 배지
  Widget _buildParticipantInfo(int people) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, size: 16, color: Colors.blueGrey[700]),
          SizedBox(width: 6),
          Text("참여 인원: $people명", style: TextStyle(color: Colors.blueGrey[700], fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  // 3. 나의 분담 결과 카드
  Widget _buildSummaryCard(List<dynamic> items, int people) {
    int totalPrice = 0;
    for (var item in items) {
      totalPrice += (item['price'] as num).toInt();
    }
    int myTotalPrice = (totalPrice / people).round();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[700]!, Colors.blue[400]!]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("나의 분담 상세 결과", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Divider(color: Colors.white30, height: 25),
          if (items.isEmpty)
            Center(child: Text("정산 내역이 아직 없습니다.", style: TextStyle(color: Colors.white70))),
          ...items.map((item) {
            double myWeight = (item['weight'] as num) / people;
            int myPrice = ((item['price'] as num) / people).round();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("• ${item['name']}", style: TextStyle(color: Colors.white, fontSize: 15)),
                  Text("${myWeight.toStringAsFixed(1)}g / ${myPrice}원", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            );
          }).toList(),
          Divider(color: Colors.white30, height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("총 지불 금액", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text("$myTotalPrice원", style: TextStyle(color: Colors.yellow[300], fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // 4. 품목 리스트
  Widget _buildItemList(List<dynamic> items) {
    if (items.isEmpty) return Padding(padding: EdgeInsets.all(20), child: Text("등록된 품목이 없습니다."));
    return Column(
      children: items.map((item) => Card(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          leading: Icon(Icons.shopping_bag_outlined, color: Colors.blue),
          title: Text(item['name']),
          subtitle: Text("전체: ${item['weight']}g"),
          trailing: Text("${item['price']}원", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      )).toList(),
    );
  }

  // 5. 품목 추가 폼
  Widget _buildAddItemForm() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🧾 새 품목 추가 (영수증 대로)", style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _itemNameController, decoration: InputDecoration(hintText: "품목명")),
          Row(
            children: [
              Expanded(child: TextField(controller: _itemPriceController, decoration: InputDecoration(hintText: "가격"), keyboardType: TextInputType.number)),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _itemWeightController, decoration: InputDecoration(hintText: "무게/개수"), keyboardType: TextInputType.number)),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addItemToFirestore, 
            child: Text("정산 리스트에 추가"),
            style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 45)),
          ),
        ],
      ),
    );
  }

  // 6. 하단 버튼 액션
  Widget _buildBottomAction(bool isWriter, bool isDone, bool isSettled, String? link) {
    if (isSettled) return SizedBox.shrink();

    if (isWriter) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: isDone ? _finishSettlement : _finishRecruitment,
            child: Text(isDone ? "최종 정산 완료하기" : "모집 완료 및 정산 시작"),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 60), 
              backgroundColor: isDone ? Colors.green[700] : Colors.blue, 
              foregroundColor: Colors.white
            ),
          ),
        ),
      );
    } else if (!isDone) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => _launchURL(link),
            child: Text("카카오톡으로 연락하기"),
            style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 60), backgroundColor: Colors.yellow[700], foregroundColor: Colors.black),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  // 7. 로직 함수들 (Firestore 업데이트 및 외부 링크)
  Future<void> _addItemToFirestore() async {
    if (_itemNameController.text.isEmpty || _itemPriceController.text.isEmpty) return;
    try {
      var newItem = {
        "name": _itemNameController.text.trim(),
        "price": int.parse(_itemPriceController.text),
        "weight": double.parse(_itemWeightController.text),
      };
      await FirebaseFirestore.instance.collection('posts').doc(widget.title).update({
        "settlementItems": FieldValue.arrayUnion([newItem])
      });
      _itemNameController.clear();
      _itemPriceController.clear();
      _itemWeightController.clear();
    } catch (e) {
      print("Error adding item: $e");
    }
  }

  Future<void> _finishRecruitment() async {
    await FirebaseFirestore.instance.collection('posts').doc(widget.title).update({'isDone': true});
  }

  Future<void> _finishSettlement() async {
    await FirebaseFirestore.instance.collection('posts').doc(widget.title).update({'isSettled': true});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("정산이 완료되었습니다.")));
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}