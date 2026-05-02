import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final String shadowDomain = "@sobun.com"; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("로그인"), elevation: 0),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: idController, 
              decoration: InputDecoration(labelText: "아이디", border: OutlineInputBorder())
            ),
            SizedBox(height: 15),
            TextField(
              controller: pwController, 
              decoration: InputDecoration(labelText: "비밀번호", border: OutlineInputBorder()), 
              obscureText: true
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                String fakeEmail = "${idController.text.trim()}$shadowDomain";
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: fakeEmail,
                    password: pwController.text.trim(),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("아이디 또는 비밀번호 오류")));
                }
              },
              child: Text("로그인"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text("계정이 없으신가요? 회원가입"),
            ),
          ],
        ),
      ),
    );
  }
}