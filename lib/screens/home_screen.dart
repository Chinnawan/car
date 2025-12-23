import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Icon(
            Icons.search,
            color: Colors.purple,
            size: 24.0,
          ),
          SizedBox(width: 16.0),
          Icon(
            Icons.exit_to_app,
            color: Colors.purple,
            size: 24.0,
          ),
          SizedBox(width: 16.0),
        ],
        title: const Center(child: const Text('Demo Mobile App')),
        leading: const Icon(
          Icons.menu, 
          color: Colors.purple,
          size: 24.0,
          ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "First Line",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 16),
          Icon(
            Icons.settings,
            color: Colors.purple,
            size: 48.0,
          ),
          SizedBox(height: 16,),
          Row(
            children: [
              Container(
                width: 200,
                height: 200,
                color: Colors.pinkAccent,
                child: const Text("Hello"),
              ),
              Container(
                width: 200,
                height: 200,
                color: Colors.brown,
                child: const Text("Hello"),
              ),
              Container(
                width: 200,
                height: 200,
                color: Colors.yellowAccent,
                child: const Text("Hello"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 54,
            backgroundColor: Colors.red,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1509991225007-88c1e9466510?q=80&w=1471&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
            ),
          ),
        ],)
      ),

      bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.green[50],
        items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: "School"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
      ),
    );
  }
}