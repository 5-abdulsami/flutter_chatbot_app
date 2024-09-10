import 'package:flutter/material.dart';
import 'package:flutter_chatbot_app/view/chat_history_screen.dart';
import 'package:flutter_chatbot_app/view/chat_screen.dart';
import 'package:flutter_chatbot_app/view/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = const [
    ChatScreen(),
    ChatHistoryScreen(),
    ProfileScreen()
  ];

  int currentIndex = 0;

  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
            pageController.jumpToPage(index);
          },
          elevation: 0,
          selectedItemColor: Colors.black,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: 'Chat History'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ]),
    );
  }
}
