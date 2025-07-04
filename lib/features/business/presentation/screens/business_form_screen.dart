import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/business_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/business.dart';

class BusinessFormScreen extends StatefulWidget {
  final Business? business; // null for create, non-null for edit

  const BusinessFormScreen({
    super.key,
    this.business,
  });

  @override
  State<BusinessFormScreen> createState() => _BusinessFormScreenState();
}

class _BusinessFormScreenState extends State<BusinessFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.business != null) {
      // Edit mode - populate fields
      _nameController.text = widget.business!.name;
      _descriptionController.text = widget.business!.description ?? '';
      _addressController.text = widget.business!.address ?? '';
      _phoneController.text = widget.business!.phone ?? '';
      _emailController.text = widget.business!.email ?? '';
      _websiteController.text = widget.business!.website ?? '';
      _isActive = widget.business!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final businessProvider = context.read<BusinessProvider>();
    final businessData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      'address': _addressController.text.trim().isEmpty 
          ? null 
          : _addressController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty 
          ? null 
          : _phoneController.text.trim(),
      'email': _emailController.text.trim().isEmpty 
          ? null 
          : _emailController.text.trim(),
      'website': _websiteController.text.trim().isEmpty 
          ? null 
          : _websiteController.text.trim(),
      'isActive': _isActive,
    };

    bool success;
    if (widget.business != null) {
      // Edit mode
      success = await businessProvider.updateBusiness(widget.business!.id, businessData);
    } else {
      // Create mode
      success = await businessProvider.createBusiness(businessData);
    }

    if (success && mounted) {
      if (widget.business != null) {
        // Go back to business detail
        context.go('/businesses/${widget.business!.id}');
      } else {
        // Go back to business list
        context.go('/businesses');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(businessProvider.error ?? 'Operation failed'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.business != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Business' : 'Create Business'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Business Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name *',
                  hintText: 'Enter business name',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Business name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Business name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter business description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter business address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: 'Enter phone number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Basic phone validation
                    final phoneRegex = RegExp(r'^[\+]?[1-9][\d]{0,15}$');
                    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email address',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Website
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  hintText: 'Enter website URL',
                  prefixIcon: Icon(Icons.language),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final urlRegex = RegExp(
                      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
                    );
                    if (!urlRegex.hasMatch(value)) {
                      return 'Please enter a valid URL';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Active Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Active'),
                        subtitle: const Text('Business is currently active'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              Consumer<BusinessProvider>(
                builder: (context, businessProvider, child) {
                  return ElevatedButton(
                    onPressed: businessProvider.isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: businessProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(isEditMode ? 'Update Business' : 'Create Business'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 