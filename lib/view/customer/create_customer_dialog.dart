import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/customer_model.dart';
import '../../provider/customer_provider.dart';

class CreateCustomerPage extends StatefulWidget {
  const CreateCustomerPage({Key? key}) : super(key: key);

  @override
  State<CreateCustomerPage> createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends State<CreateCustomerPage> {
  final _formKey = GlobalKey<FormState>();

  // Scroll controller
  final ScrollController _scrollCtrl = ScrollController();

  // Basic
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'Bangladesh');
  final _cityCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();

  // Address
  final _streetCtrl = TextEditingController();
  final _street2Ctrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  // Extra
  final _vatCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  bool _isCompany = true;

  // 👇 NEW: image picker state
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImageFile;
  String? _imageBase64; // this will go to createCustomer(...imageBase64: _imageBase64)

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _mobileCtrl.dispose();
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    _companyNameCtrl.dispose();
    _streetCtrl.dispose();
    _street2Ctrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    _vatCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  // 👇 NEW: pick image from gallery (you can also add camera)
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedImageFile = picked;
      _imageBase64 = base64Encode(bytes);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CustomerProvider>();

    final created = await provider.createCustomer(
      name: _nameCtrl.text.trim(),
      isCompany: _isCompany,
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim().isEmpty ? null : _mobileCtrl.text.trim(),
      companyName: _companyNameCtrl.text.trim().isEmpty
          ? null
          : _companyNameCtrl.text.trim(),
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),

      // 👇 pass the base64 image (can be null if user didn’t pick)
      imageBase64: _imageBase64,

      street: _streetCtrl.text.trim().isEmpty ? null : _streetCtrl.text.trim(),
      street2:
      _street2Ctrl.text.trim().isEmpty ? null : _street2Ctrl.text.trim(),
      vat: _vatCtrl.text.trim().isEmpty ? null : _vatCtrl.text.trim(),
      website:
      _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
    );

    if (!mounted) return;

    if (created != null) {
      Navigator.of(context).pop<Customer>(created);
    } else {
      final error = provider.createError ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create customer: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = context.watch<CustomerProvider>().isCreating;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Customer"),
        actions: [
          TextButton(
            onPressed: isCreating ? null : _submit,
            child: isCreating
                ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              "SAVE",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Scrollbar(
        controller: _scrollCtrl,
        thumbVisibility: true,
        interactive: true,
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 👇 NEW: image avatar + upload button
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _pickedImageFile != null
                          ? FileImage(File(_pickedImageFile!.path))
                          : null,
                      child: _pickedImageFile == null
                          ? const Icon(Icons.person, size: 32, color: Colors.white70)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Upload Customer Image'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ==== BASIC INFO ====
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 8),

                SwitchListTile(
                  title: const Text('Is Company'),
                  value: _isCompany,
                  onChanged: (v) => setState(() => _isCompany = v),
                ),

                TextFormField(
                  controller: _companyNameCtrl,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _mobileCtrl,
                  decoration: const InputDecoration(labelText: 'Mobile'),
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 20),

                // ==== ADDRESS ====
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Address",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 6),

                TextFormField(
                  controller: _streetCtrl,
                  decoration: const InputDecoration(labelText: 'Street'),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _street2Ctrl,
                  decoration: const InputDecoration(labelText: 'Street 2'),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _cityCtrl,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _stateCtrl,
                  decoration: const InputDecoration(labelText: 'State'),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _zipCtrl,
                  decoration: const InputDecoration(labelText: 'ZIP'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _countryCtrl,
                  decoration: const InputDecoration(labelText: 'Country'),
                ),

                const SizedBox(height: 20),

                // ==== EXTRA ====
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Extra",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 6),

                TextFormField(
                  controller: _vatCtrl,
                  decoration: const InputDecoration(labelText: 'VAT'),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _websiteCtrl,
                  decoration: const InputDecoration(labelText: 'Website'),
                  keyboardType: TextInputType.url,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

