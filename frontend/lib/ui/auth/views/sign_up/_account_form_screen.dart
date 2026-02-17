import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Account form screen with additional fields
class AccountFormScreen extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController dateOfBirthController;
  final TextEditingController villageController;
  final TextEditingController districtController;
  final TextEditingController countryController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final VoidCallback? onDatePickerTap;

  const AccountFormScreen({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneNumberController,
    required this.dateOfBirthController,
    required this.villageController,
    required this.districtController,
    required this.countryController,
    required this.usernameController,
    required this.passwordController,
    required this.onSubmit,
    required this.onBack,
    this.onDatePickerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDF71), // Yellow background
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
                  color: const Color(0xFF0F62FE), // Blue text
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

              // Phone Number Field
              CustomTextField(
                controller: phoneNumberController,
                hintText: 'Phone Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Date of Birth Field
              GestureDetector(
                onTap: () {
                  // We'll need to pass the viewModel callback
                  if (onDatePickerTap != null) {
                    onDatePickerTap!();
                  }
                },
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: dateOfBirthController,
                    hintText: 'Date of Birth (Optional)',
                    suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF0F62FE)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Village Field
              CustomTextField(
                controller: villageController,
                hintText: 'Village (Optional)',
              ),
              const SizedBox(height: 16),

              // District Field
              CustomTextField(
                controller: districtController,
                hintText: 'District (Optional)',
              ),
              const SizedBox(height: 16),

              // Country Field
              CustomTextField(
                controller: countryController,
                hintText: 'Country (Optional)',
              ),
              const SizedBox(height: 16),

              // Username Field
              CustomTextField(
                controller: usernameController,
                hintText: 'Username',
              ),
              const SizedBox(height: 16),

              // Password Field
              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // Submit Button
              CustomButton(
                text: 'Submit',
                backgroundColor: const Color(0xFF0F62FE), // Blue button
                textColor: Colors.white,
                onPressed: onSubmit,
              ),
              const SizedBox(height: 16),

              // Back Button
              GestureDetector(
                onTap: onBack,
                child: Text(
                  'Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF0F62FE), // Blue text
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
