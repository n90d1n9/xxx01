/* // ignore_for_file: library_private_types_in_public_api, unused_element

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
//import 'package:file_picker/file_picker.dart';

class CompleteForm extends StatefulWidget {
  const CompleteForm({super.key});

  @override
  _CompleteFormState createState() => _CompleteFormState();
}

class _CompleteFormState extends State<CompleteForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _socialIdController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  XFile? _selectedImage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _socialIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        // _messages.add(ChatMessage(image: pickedFile.path, isSentByMe: true));
      });
    }
  }

  Future<void> _pickFile() async {
    /* String? filePath = await FilePicker.platform.pickFiles().then((value) => value!.files.first.path);
    if (filePath != null) {
      setState(() {
        //_messages.add(ChatMessage(file: filePath, isSentByMe: true));
      });
    } */
  }

  Future<void> _selectImage() async {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email Input
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Input
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Social ID Input
                TextFormField(
                  controller: _socialIdController,
                  decoration: const InputDecoration(
                    labelText: 'Social ID',
                    hintText: 'Enter your social ID',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your social ID';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Date Input
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : 'Select Date',
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          hintText: 'Select your date of birth',
                        ),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Photo Upload
                ElevatedButton(
                  onPressed: _selectImage,
                  child: const Text('Upload Photo'),
                ),

                const SizedBox(height: 16),

                if (_selectedImage != null)
                  Image.file(
                    File(_selectedImage!.path),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),

                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process the form data
                      // You can access the values using:
                      // _nameController.text
                      // _emailController.text
                      // _passwordController.text
                      // _socialIdController.text
                      // _selectedDate
                      // _selectedImage
                      // ...
                      // Do something with the data, like send it to a server
                      print('Form submitted!');
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 */