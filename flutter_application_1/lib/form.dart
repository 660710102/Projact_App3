import 'package:flutter/material.dart';

class RegisterFormPage extends StatefulWidget {
  const RegisterFormPage({super.key});

  @override
  State<RegisterFormPage> createState() => _RegisterFormPageState();
}

class _RegisterFormPageState extends State<RegisterFormPage> {
  final _formKey = GlobalKey<FormState>();

  String? _gender;
  String? _province;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registration Form")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Full Name
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Full Name",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your full name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Email",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  if (!value.contains("@")) {
                    return "Invalid email format";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gender label
              const Text("Gender"),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Male"),
                      value: "Male",
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() => _gender = value);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Female"),
                      value: "Female",
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() => _gender = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Province Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Province",
                ),
                value: _province,
                items: const [
                  DropdownMenuItem(value: "Bangkok", child: Text("Bangkok")),
                  DropdownMenuItem(value: "Chiang Mai", child: Text("Chiang Mai")),
                  DropdownMenuItem(value: "Phuket", child: Text("Phuket")),
                  DropdownMenuItem(value: "Khon Kaen", child: Text("Khon Kaen")),
                ],
                onChanged: (value) {
                  setState(() => _province = value);
                },
                validator: (value) {
                  if (value == null) return "Please select a province";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Accept Terms
              CheckboxListTile(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() => _acceptTerms = value ?? false);
                },
                title: const Text("Accept Terms & Conditions"),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _gender != null &&
                        _acceptTerms) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Form Submitted Successfully!")),
                      );
                    }
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
