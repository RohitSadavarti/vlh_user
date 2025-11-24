import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  final List<dynamic> cartItems; // Passed from MenuScreen

  CartScreen({required this.cartItems});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = await ApiService.getLocalUser();
    if (user != null) {
      setState(() {
        _nameController.text = user.fullName;
        _mobileController.text = user.mobile;
        _addressController.text = user.address;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _placeOrder() async {
    if (widget.cartItems.isEmpty) return;

    Map<String, dynamic> orderData = {
      'name': _nameController.text,
      'mobile': _mobileController.text,
      'address': _addressController.text,
      'cart_items': widget.cartItems
          .map(
            (item) => {
              'id': item['id'],
              'quantity': 1, // Simplify for demo, ideally handle qty
            },
          )
          .toList(),
    };

    var response = await ApiService.placeOrder(orderData);
    if (response['success'] == true) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Success"),
          content: Text(response['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to Menu
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error'] ?? "Order Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Confirm Order")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Your Details (Auto-filled)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: _mobileController,
                    decoration: InputDecoration(labelText: "Mobile"),
                  ),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: "Address"),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                  Text("Items in Cart: ${widget.cartItems.length}"),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _placeOrder,
                    child: Text("Place Order"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
