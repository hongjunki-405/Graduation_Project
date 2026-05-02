import 'package:flutter/material.dart';
import 'main_board_page.dart';
import 'my_posts_page.dart';   
import 'my_page.dart';
class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    MainBoardPage(), 
    MyPage(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.orange[800], 
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled), 
            label: '홈'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_ind), 
            label: '마이페이지'
          ),
        ],
      ),
    );
  }
}