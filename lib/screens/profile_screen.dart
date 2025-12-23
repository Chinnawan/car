import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1509991225007-88c1e9466510?q=80&w=1471&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                      
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          
            SizedBox(height: 20),
            Text(
              'Onyour Prai',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[200],
              ),
              onPressed: () {}, 
              child: Text('pray41811@gmail.com'),
            ),
          ],
        ),
      ) ,
    );
  }
}