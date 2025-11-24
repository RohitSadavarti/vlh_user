import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> _menuItems = [];
  List<dynamic> _cart = [];
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadMenu();
    _checkUserLoggedIn();
  }

  Future<void> _checkUserLoggedIn() async {
    final user = await ApiService.getLocalUser();
    setState(() {
      _user = user;
    });
  }

  void _loadMenu() async {
    var items = await ApiService.getMenu();
    if (mounted) {
      setState(() {
        _menuItems = items;
      });
    }
  }

  void _navigateToCartOrLogin() async {
    await _checkUserLoggedIn();
    if (_user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CartScreen(cartItems: _cart)),
      );
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
      if (result == true) {
        _checkUserLoggedIn();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vanita Lunch Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: _navigateToCartOrLogin,
          ),
          if (_user == null)
            TextButton(
              child: Text('Login', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
                if (result == true) {
                  _checkUserLoggedIn();
                }
              },
            )
          else
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await ApiService.logout();
                _checkUserLoggedIn();
              },
            ),
          if (_user == null)
            TextButton(
              child: Text('Register', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: _menuItems.length,
        itemBuilder: (ctx, index) {
          final item = _menuItems[index];
          return ListTile(
            title: Text(item['item_name']),
            subtitle: Text("₹${item['price']}"),
            trailing: ElevatedButton(
              child: Text("Add"),
              onPressed: () {
                setState(() => _cart.add(item));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Added to cart")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
