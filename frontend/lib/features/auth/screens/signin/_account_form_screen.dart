import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Account form screen with additional fields
class AccountFormScreen extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController dateOfBirthController;
  final TextEditingController villageController;
  final TextEditingController districtController;
  final TextEditingController provinceController;
  final TextEditingController nationController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const AccountFormScreen({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.dateOfBirthController,
    required this.villageController,
    required this.districtController,
    required this.provinceController,
    required this.nationController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F62FE),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Complete Your Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // First Name Field
              CustomTextField(
                controller: firstNameController,
                hintText: 'First Name',
              ),
              const SizedBox(height: 16),

              // Last Name Field
              CustomTextField(
                controller: lastNameController,
                hintText: 'Last Name',
              ),
              const SizedBox(height: 16),

              // Date of Birth Field
              CustomTextField(
                controller: dateOfBirthController,
                hintText: 'Date of Birth (MM/DD/YYYY)',
              ),
              const SizedBox(height: 16),

              // Village Field
              CustomTextField(
                controller: villageController,
                hintText: 'Village',
              ),
              const SizedBox(height: 16),

              // District Field
              CustomTextField(
                controller: districtController,
                hintText: 'District',
              ),
              const SizedBox(height: 16),

              // Province Field
              CustomTextField(
                controller: provinceController,
                hintText: 'Province',
              ),
              const SizedBox(height: 16),

              // Nation Field
              CustomTextField(
                controller: nationController,
                hintText: 'Nation',
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: emailController,
                hintText: 'Email',
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
              ),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: 'Submit',
                backgroundColor: const Color(0xFFFFDF71),
                textColor: const Color(0xFF0F62FE),
                onPressed: onSubmit,
              ),
              const SizedBox(height: 16),

              // Back Button
              GestureDetector(
                onTap: onBack,
                child: Text(
                  'back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Anonymous Pro',
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
