import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditAccountPage extends StatefulWidget {
  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load the current user's name if available
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
    }
  }

  // Update display name in Firebase
  Future<void> _updateName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _formKey.currentState?.validate() == true) {
      await user.updateDisplayName(_nameController.text);
      // After updating, pop the page and go back to the account page
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Display Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateName,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
