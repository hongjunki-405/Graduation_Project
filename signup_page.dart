import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController(); // 1. 이름 입력기 추가
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final String shadowDomain = "@sobun.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("회원가입")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "이름 (닉네임)", border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: "아이디", border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              controller: pwController,
              decoration: InputDecoration(labelText: "비밀번호 (6자 이상)", border: OutlineInputBorder()),
              obscureText: true,
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text.trim();
                String fakeEmail = "${idController.text.trim()}$shadowDomain";
                
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("이름을 입력해주세요.")));
                  return;
                }

                try {
                  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: fakeEmail,
                    password: pwController.text.trim(),
                  );

                  if (userCredential.user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userCredential.user!.uid) 
                        .set({
                          'name': name,
                          'email': fakeEmail,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("반갑습니다, $name님!")));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("가입 실패: $e")));
                }
              },
              child: Text("가입 완료"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}