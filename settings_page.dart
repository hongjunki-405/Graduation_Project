import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("설정"), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("앱 버전"),
            trailing: Text("v 1.0.0"),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text("오픈소스 라이선스"),
            trailing: Icon(Icons.chevron_right),
            onTap: () { /* 나중에 필요하면 연결 */ },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("로그아웃", style: TextStyle(color: Colors.red)),
            onTap: () async {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("로그아웃"),
                  content: Text("정말 로그아웃 하시겠습니까?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text("취소")),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pop(context); 
                        Navigator.pop(context); 
                      }, 
                      child: Text("확인", style: TextStyle(color: Colors.red))
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}