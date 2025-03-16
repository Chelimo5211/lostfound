import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportLostScreen extends StatefulWidget {
  const ReportLostScreen({super.key});

  @override
  _ReportLostScreenState createState() => _ReportLostScreenState();
}

class _ReportLostScreenState extends State<ReportLostScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _lastSeenLocationController = TextEditingController();

  final List<String> categories = ['Electronics', 'Clothing', 'Documents'];

  Future<void> saveLostItem() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser; // Get logged-in user

      if (user != null) {
        await FirebaseFirestore.instance.collection('lost_items').add({
          'category': _selectedCategory,
          'item_name': _itemNameController.text,
          'description': _descriptionController.text,
          'last_seen_location': _lastSeenLocationController.text,
          'reported_by': user.email ?? user.uid, // Use email if available, otherwise UID
          'date_reported': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lost item reported successfully!')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Lost Item"), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text("Select Category"),
                items: categories.map((String category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: "Item Name"),
                validator: (value) => value!.isEmpty ? 'Please enter item name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lastSeenLocationController,
                decoration: const InputDecoration(labelText: "Last Seen Location"),
                validator: (value) => value!.isEmpty ? 'Please enter last seen location' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveLostItem,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Submit Report", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
