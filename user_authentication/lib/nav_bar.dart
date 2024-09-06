import 'package:flutter/material.dart';
import 'package:flutter_application/firebase_auth_services.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.navigateToTab});
  final Function(String) navigateToTab;
  
  @override
  Widget build(BuildContext context) { 
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: (){
                navigateToTab('Home');
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Profile"),
            onTap: (){
              navigateToTab('Profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text("Map"),
            onTap: (){
              navigateToTab('Map');
            },
          ),
          ListTile(
            leading: Icon(Icons.bluetooth),
            title: Text("Bluetooth"),
            onTap: (){
              navigateToTab('Bluetooth');
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("Camera"),
            onTap: (){
              navigateToTab('Camera');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: (){
              logoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void logoutDialog(BuildContext context) {
    FirebaseAuthService firebaseAuthService =FirebaseAuthService();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                firebaseAuthService.logOut();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}

