import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WritePage extends StatefulWidget {
  final Map<String, dynamic>? post;
  final String? docId;

  WritePage({this.post, this.docId});

  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  late TextEditingController titleController;      // 공고 제목
  late TextEditingController martController;       // 대상 마트
  late TextEditingController itemController;       // 소분할 품목
  late TextEditingController expectedPriceController; // 전체 예상 가격
  late TextEditingController expectedWeightController; // 전체 예상 무게
  late TextEditingController personCountController;   // 모집 인원
  late TextEditingController contentController;    // 추가 안내
  late TextEditingController kakaoController;      // 채팅방 링크

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.docId ?? "");
    martController = TextEditingController(text: widget.post?['martName'] ?? "");
    itemController = TextEditingController(text: widget.post?['itemName'] ?? "");
    expectedPriceController = TextEditingController(text: widget.post?['totalPrice']?.toString() ?? "");
    expectedWeightController = TextEditingController(text: widget.post?['totalWeight']?.toString() ?? "");
    personCountController = TextEditingController(text: widget.post?['personCount']?.toString() ?? "2");
    contentController = TextEditingController(text: widget.post?['content'] ?? "");
    kakaoController = TextEditingController(text: widget.post?['kakaoLink'] ?? "");
    expectedPriceController.addListener(() => setState(() {}));
    expectedWeightController.addListener(() => setState(() {}));
    personCountController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    int price = int.tryParse(expectedPriceController.text) ?? 0;
    double weight = double.tryParse(expectedWeightController.text) ?? 0;
    int people = int.tryParse(personCountController.text) ?? 1;
    if (people < 1) people = 1;

    return Scaffold(
      appBar: AppBar(title: Text("장보기 메이트 모집"), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInput(titleController, "공고 제목 (예: 트레이더스 연어 나누실 분!)", enabled: widget.post == null),
            _buildInput(martController, "방문할 마트 지점"),
            _buildInput(itemController, "함께 살 품목"),
            Row(
              children: [
                Expanded(child: _buildInput(expectedPriceController, "전체 예상 가격", isNumber: true, suffix: "원")),
                SizedBox(width: 10),
                Expanded(child: _buildInput(expectedWeightController, "전체 예상 무게", isNumber: true, suffix: "g")),
              ],
            ),
            _buildInput(personCountController, "희망 모집 인원 (본인 포함)", isNumber: true, suffix: "명"),
            
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPreviewText("1인당 예상 금액", "${(price / people).round()}원"),
                  _buildPreviewText("1인당 예상 무게", "${(weight / people).toStringAsFixed(0)}g"),
                ],
              ),
            ),
            
            _buildInput(kakaoController, "카카오톡 오픈채팅 링크"),
            _buildInput(contentController, "상세 안내 (만날 시간 등)", maxLines: 5),
            SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildPreviewText(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.orange[800])),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[900])),
      ],
    );
  }

  Widget _buildInput(TextEditingController controller, String label, {bool isNumber = false, String? suffix, int maxLines = 1, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _savePost,
          child: Text("모집 시작하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 60)),
        ),
      ),
    );
  }

  Future<void> _savePost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('posts').doc(titleController.text.trim()).set({
        "martName": martController.text,
        "itemName": itemController.text,
        "totalPrice": int.parse(expectedPriceController.text),
        "totalWeight": double.parse(expectedWeightController.text),
        "personCount": int.parse(personCountController.text),
        "content": contentController.text,
        "kakaoLink": kakaoController.text,
        "writerUid": user.uid,
        "status": "recruiting",
        "isDone": false,
        "timestamp": FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }
}