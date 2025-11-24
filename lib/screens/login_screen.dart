import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import 'map_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  Future<void> _login() async {
    final user = await ApiService.login(
      _userController.text,
      _passController.text,
    );

    if (user != null) {
      if (user.address.isEmpty) {
        final locationResult = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MapScreen()),
        );

        if (locationResult != null) {
          await ApiService.updateUserAddress(user.id!, {
            'address': locationResult['address'],
            'lat': locationResult['lat'],
            'lng': locationResult['lng'],
          });
        }
      }
      Navigator.pop(context, true); // Return true to indicate successful login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: InputDecoration(labelText: "Mobile or Email"),
            ),
            TextField(
              controller: _passController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text("Login"),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegisterScreen()),
              ),
              child: Text("New User? Register here"),
            ),
          ],
        ),
      ),
    );
  }
}
