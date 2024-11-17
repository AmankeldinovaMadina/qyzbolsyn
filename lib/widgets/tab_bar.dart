import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  // List of pages you want to switch between when a tab is tapped
  final List<Widget> _pages = [
    Center(child: Text('Home Page')),
    Center(child: Text('Bot Page')),
    Center(child: Text('Podcasts Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the current page based on index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // To highlight the current tab
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current index
          });
        },
        selectedItemColor: Color(0xFFFA7BFD), // Accent color for the selected tab
        unselectedItemColor: Colors.grey, // Gray color for unselected tabs
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная', // Home label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Бот', // Bot label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Подкасты', // Podcasts label
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}
